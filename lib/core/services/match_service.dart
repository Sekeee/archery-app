import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MatchService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUserMatches(String userId) async {
    // Use createdBy equality filter (no composite index needed).
    // For multiplayer, switch to arrayContains on a playerIds field.
    final query = await _firestore
        .collection('matches')
        .where('createdBy', isEqualTo: userId)
        .get();
    final results = query.docs.map((doc) {
      final data = doc.data();
      final players = data['players'] as Map<String, dynamic>?;
      final player = players?[userId] as Map<String, dynamic>?;
      final createdAt = data['createdAt'];
      return {
        'name': data['name'],
        'matchType': data['matchType'],
        'category': data['matchType'],
        'date': createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
        'ends': data['ends'],
        'arrowsPerEnd': data['arrowsPerEnd'],
        'score': player?['totalScore'] ?? 0,
        'rank': player?['rank'],
        'isCompleted': player?['isComplete'] ?? false,
        'matchId': doc.id,
      };
    }).toList();
    // Sort newest first in Dart to avoid needing a composite index
    results.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return results;
  }

  /// Generate a unique 6-character join code
  String generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Create a new match in Firestore
  Future<String?> createMatch({
    required String matchType,
    required String name,
    required int ends,
    required int arrowsPerEnd,
    required String userId,
    required String username,
    required String photoUrl,
  }) async {
    final joinCode = generateJoinCode();
    final matchRef = _firestore.collection('matches').doc();
    final now = DateTime.now();

    final playerData = {
      'userId': userId,
      'username': username,
      'photoUrl': photoUrl,
      'joinedAt': now,
      'scores': [],
      'endScores': [],
      'currentEndArrows': [],
      'totalScore': 0,
      'accuracy': 0.0,
      'currentEnd': 1,
      'isComplete': false,
      'rank': null,
    };

    final matchData = {
      'matchType': matchType,
      'name': name,
      'joinCode': joinCode,
      'createdAt': now,
      'createdBy': userId,
      'ends': ends,
      'arrowsPerEnd': arrowsPerEnd,
      'isActive': true,
      'isCompleted': false,
      'players': {userId: playerData},
    };

    try {
      await matchRef.set(matchData);
      return matchRef.id;
    } catch (e) {
      print('Error creating match: $e');
      return null;
    }
  }

  /// Save match results to Firestore.
  /// Scores are flattened to a single flat array (no nested arrays).
  /// Unscored arrows (-1) are stored as 0.
  Future<void> saveFinalMatch({
    required String matchId,
    required String userId,
    required List<List<int>> scores,
    required int totalScore,
    required double accuracy,
  }) async {
    final List<int> flatScores = [];
    final List<int> endTotals = [];
    for (final end in scores) {
      int endTotal = 0;
      for (final s in end) {
        final safeScore = (s < 0) ? 0 : s;
        flatScores.add(safeScore);
        endTotal += safeScore;
      }
      endTotals.add(endTotal);
    }

    final matchRef = _firestore.collection('matches').doc(matchId);

    // Use set+merge with a proper nested map to avoid dot-notation
    // field path parsing issues in the native Firestore SDK.
    await matchRef.set({
      'isCompleted': true,
      'isActive': false,
      'players': {
        userId: {
          'scores': flatScores,
          'endScores': endTotals,
          'totalScore': totalScore,
          'accuracy': accuracy,
          'isComplete': true,
        },
      },
    }, SetOptions(merge: true));
  }
}
