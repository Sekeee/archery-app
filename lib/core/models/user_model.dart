import 'package:cloud_firestore/cloud_firestore.dart';

/// Stats for a specific match category
class CategoryStats {
  final int totalMatches;
  final double avgAccuracy;
  final int bestScore;

  CategoryStats({
    this.totalMatches = 0,
    this.avgAccuracy = 0.0,
    this.bestScore = 0,
  });

  factory CategoryStats.fromMap(Map<String, dynamic>? data) {
    if (data == null) return CategoryStats();
    return CategoryStats(
      totalMatches: data['totalMatches'] ?? 0,
      avgAccuracy: (data['avgAccuracy'] ?? 0.0).toDouble(),
      bestScore: data['bestScore'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMatches': totalMatches,
      'avgAccuracy': avgAccuracy,
      'bestScore': bestScore,
    };
  }

  CategoryStats copyWith({
    int? totalMatches,
    double? avgAccuracy,
    int? bestScore,
  }) {
    return CategoryStats(
      totalMatches: totalMatches ?? this.totalMatches,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      bestScore: bestScore ?? this.bestScore,
    );
  }
}

/// All category types
class MatchCategories {
  static const String range = 'Range';
  static const String movingObject = 'Moving Object';
  static const String horseback = 'Horseback';
  static const String longDistance = 'Long Distance';
  static const String dynamicShooting = 'Dynamic Shooting';

  static const List<String> all = [
    range,
    movingObject,
    horseback,
    longDistance,
    dynamicShooting,
  ];
}

class UserModel {
  final String uid;
  final String phone;
  final String username;
  final String? photoUrl;
  final DateTime createdAt;
  
  /// Stats per category
  final Map<String, CategoryStats> categoryStats;

  UserModel({
    required this.uid,
    required this.phone,
    required this.username,
    this.photoUrl,
    required this.createdAt,
    Map<String, CategoryStats>? categoryStats,
  }) : categoryStats = categoryStats ?? {};

  /// Get stats for a specific category
  CategoryStats getStats(String category) {
    return categoryStats[category] ?? CategoryStats();
  }

  /// Get total matches across all categories
  int get totalMatches {
    return categoryStats.values.fold(0, (sum, stats) => sum + stats.totalMatches);
  }

  /// Get overall average accuracy
  double get overallAvgAccuracy {
    if (totalMatches == 0) return 0.0;
    double totalWeighted = 0;
    int totalCount = 0;
    for (final stats in categoryStats.values) {
      totalWeighted += stats.avgAccuracy * stats.totalMatches;
      totalCount += stats.totalMatches;
    }
    return totalCount > 0 ? totalWeighted / totalCount : 0.0;
  }

  /// Get overall best score
  int get overallBestScore {
    if (categoryStats.isEmpty) return 0;
    return categoryStats.values.map((s) => s.bestScore).reduce((a, b) => a > b ? a : b);
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse category stats
    final statsData = data['categoryStats'] as Map<String, dynamic>? ?? {};
    final categoryStats = <String, CategoryStats>{};
    for (final category in MatchCategories.all) {
      categoryStats[category] = CategoryStats.fromMap(
        statsData[category] as Map<String, dynamic>?,
      );
    }

    return UserModel(
      uid: data['uid'] ?? doc.id,
      phone: data['phone'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryStats: categoryStats,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final statsMap = <String, dynamic>{};
    for (final entry in categoryStats.entries) {
      statsMap[entry.key] = entry.value.toMap();
    }

    return {
      'uid': uid,
      'phone': phone,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'categoryStats': statsMap,
    };
  }

  /// Create a new user with minimal info
  factory UserModel.create({
    required String uid,
    required String phone,
    required String username,
    String? photoUrl,
  }) {
    // Initialize empty stats for all categories
    final categoryStats = <String, CategoryStats>{};
    for (final category in MatchCategories.all) {
      categoryStats[category] = CategoryStats();
    }

    return UserModel(
      uid: uid,
      phone: phone,
      username: username,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      categoryStats: categoryStats,
    );
  }

  UserModel copyWith({
    String? uid,
    String? phone,
    String? username,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, CategoryStats>? categoryStats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }
}
