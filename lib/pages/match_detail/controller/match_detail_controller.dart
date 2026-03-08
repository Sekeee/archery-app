import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/match_service.dart';
import '../../../routes/app_routes.dart';
import '../state/match_detail_state.dart';

class MatchDetailController extends GetxController {
  final state = MatchDetailState();
  final MatchService _matchService = MatchService();

  @override
  void onInit() {
    super.onInit();
    _loadMatchData();
  }

  void _loadMatchData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      state.matchName.value = args['name'] ?? 'Match';
      state.matchType.value = args['matchType'] ?? 'Range';
      state.matchDate.value = args['date'] ?? DateTime.now();
      state.totalEnds.value = args['ends'] ?? 10;
      state.arrowsPerEnd.value = args['arrowsPerEnd'] ?? 3;
      
      if (args.containsKey('scores')) {
        state.scores.value = List<List<int>>.from(args['scores']);
        _calculateTotalScore();
        state.isCompleted.value = args['isCompleted'] ?? false;
      } else {
        _initializeScores();
      }
    } else {
      _initializeScores();
    }
  }

  void _initializeScores() {
    state.scores.value = List.generate(
      state.totalEnds.value,
      (_) => List.filled(state.arrowsPerEnd.value, -1),
    );
  }

  void selectArrow(int arrowIndex) {
    state.selectedArrowIndex.value = arrowIndex;
  }

  void recordScore(int endIndex, int score) {
    final arrowIndex = state.selectedArrowIndex.value;
    if (endIndex < state.scores.length && arrowIndex < state.scores[endIndex].length) {
      final wasUnscored = state.scores[endIndex][arrowIndex] < 0;
      state.scores[endIndex][arrowIndex] = score;
      state.scores.refresh();
      _calculateTotalScore();
      // Only auto-advance when scoring a new arrow, not when editing
      if (wasUnscored) {
        _advanceToNextUnscored(endIndex);
      }
      _checkMatchComplete();
    }
  }

  void _advanceToNextUnscored(int endIndex) {
    final endScores = state.scores[endIndex];
    final nextUnscored = endScores.indexWhere((s) => s < 0);
    if (nextUnscored != -1) {
      state.selectedArrowIndex.value = nextUnscored;
    }
  }

  void _calculateTotalScore() {
    int total = 0;
    for (var end in state.scores) {
      for (var score in end) {
        if (score > 0) {
          total += score;
        }
      }
    }
    state.totalScore.value = total;
  }

  double calculateAccuracy() {
    int totalArrows = 0;
    int scoredArrows = 0;
    for (var end in state.scores) {
      for (var score in end) {
        totalArrows++;
        if (score > 0) scoredArrows++;
      }
    }
    if (totalArrows == 0) return 0.0;
    return scoredArrows / totalArrows;
  }

  void _checkMatchComplete() {
    bool allScored = true;
    for (var end in state.scores) {
      for (var score in end) {
        if (score < 0) {
          allScored = false;
          break;
        }
      }
      if (!allScored) break;
    }
    state.isCompleted.value = allScored;
  }

  int getEndTotal(int endIndex) {
    if (endIndex >= state.scores.length) return 0;
    int total = 0;
    for (var score in state.scores[endIndex]) {
      if (score > 0) total += score;
    }
    return total;
  }

  int getRunningTotal(int upToEndIndex) {
    int total = 0;
    for (int i = 0; i <= upToEndIndex && i < state.scores.length; i++) {
      total += getEndTotal(i);
    }
    return total;
  }

  void goToEnd(int endIndex) {
    if (endIndex >= 0 && endIndex < state.totalEnds.value) {
      state.currentEnd.value = endIndex + 1;
      // Select first unscored arrow, or first arrow if all scored
      final endScores = state.scores[endIndex];
      final firstUnscored = endScores.indexWhere((s) => s < 0);
      state.selectedArrowIndex.value = firstUnscored != -1 ? firstUnscored : 0;
    }
  }

  Future<void> saveMatch() async {
    state.isLoading.value = true;
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      final matchId = args?['matchId'] as String?;
      final userId = args?['userId'] as String?;

      if (matchId != null && userId != null) {
        final plainScores = state.scores
            .map((end) => List<int>.from(end))
            .toList();
        debugPrint('[saveMatch] Saving scores: $plainScores');
        await _matchService.saveFinalMatch(
          matchId: matchId,
          userId: userId,
          scores: plainScores,
          totalScore: state.totalScore.value,
          accuracy: calculateAccuracy(),
        );
        debugPrint('[saveMatch] Save succeeded');
      }

      Get.snackbar(
        'Saved',
        'Match progress saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('[saveMatch] Error: $e');
      Get.snackbar(
        'Error',
        'Failed to save match',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> finishMatch() async {
    if (!state.isCompleted.value) {
      // Ask for confirmation when not all arrows are scored
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('End Match Early?'),
          content: const Text(
            'Not all arrows have been scored. '
            'Unscored arrows will count as 0. End match anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('End Match', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    state.isLoading.value = true;
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      final matchId = args?['matchId'] as String?;
      final userId = args?['userId'] as String?;

      if (matchId != null && userId != null) {
        final plainScores = state.scores
            .map((end) => List<int>.from(end))
            .toList();
        final totalScore = state.totalScore.value;
        debugPrint('[finishMatch] Saving scores: $plainScores');
        await _matchService.saveFinalMatch(
          matchId: matchId,
          userId: userId,
          scores: plainScores,
          totalScore: totalScore,
          accuracy: calculateAccuracy(),
        );
        debugPrint('[finishMatch] Save succeeded');
        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          'Match Complete!',
          'Total Score: $totalScore',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Missing match or user ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[finishMatch] Error: $e');
      Get.snackbar(
        'Error',
        'Failed to save match: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  void exitMatch() {
    // Capture everything as local variables before showing dialog.
    // This prevents any access to possibly-disposed controller state.
    final matchService = _matchService;
    final plainScores = state.scores
        .map((end) => List<int>.from(end))
        .toList();
    final totalScore = state.totalScore.value;
    final accuracy = calculateAccuracy();
    final args = Get.arguments as Map<String, dynamic>?;
    final matchId = args?['matchId'] as String?;
    final userId = args?['userId'] as String?;

    debugPrint('[exitMatch] matchId=$matchId userId=$userId '
        'totalScore=$totalScore accuracy=$accuracy '
        'endsCount=${plainScores.length}');

    Get.dialog(
      AlertDialog(
        title: const Text('Exit Match'),
        content: const Text('Do you want to save your progress before leaving?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.home);
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              if (matchId != null && userId != null) {
                try {
                  debugPrint('[exitMatch] Saving scores: $plainScores');
                  await matchService.saveFinalMatch(
                    matchId: matchId,
                    userId: userId,
                    scores: plainScores,
                    totalScore: totalScore,
                    accuracy: accuracy,
                  );
                  debugPrint('[exitMatch] Save succeeded');
                } catch (e) {
                  debugPrint('[exitMatch] Save error: $e');
                }
              }
              Get.offAllNamed(AppRoutes.home);
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }
}
