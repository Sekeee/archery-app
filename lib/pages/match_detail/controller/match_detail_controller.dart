import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/match_detail_state.dart';

class MatchDetailController extends GetxController {
  final state = MatchDetailState();

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
      
      // Check if loading existing match with scores
      if (args.containsKey('scores')) {
        state.scores.value = List<List<int>>.from(args['scores']);
        _calculateTotalScore();
        state.isCompleted.value = args['isCompleted'] ?? false;
      } else {
        // Initialize empty scores for new match
        _initializeScores();
      }
    } else {
      _initializeScores();
    }
  }

  void _initializeScores() {
    state.scores.value = List.generate(
      state.totalEnds.value,
      (_) => List.filled(state.arrowsPerEnd.value, -1), // -1 means not scored yet
    );
  }

  void recordScore(int endIndex, int arrowIndex, int score) {
    if (endIndex < state.scores.length && arrowIndex < state.scores[endIndex].length) {
      state.scores[endIndex][arrowIndex] = score;
      state.scores.refresh();
      _calculateTotalScore();
      
      // Auto advance to next arrow/end
      _autoAdvance(endIndex, arrowIndex);
    }
  }

  void _autoAdvance(int endIndex, int arrowIndex) {
    // Check if current end is complete
    final currentEndScores = state.scores[endIndex];
    final endComplete = currentEndScores.every((score) => score >= 0);
    
    if (endComplete && endIndex < state.totalEnds.value - 1) {
      // Move to next end
      state.currentEnd.value = endIndex + 2; // +2 because currentEnd is 1-indexed
    }
    
    // Check if all ends complete
    _checkMatchComplete();
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
    }
  }

  Future<void> saveMatch() async {
    state.isLoading.value = true;
    try {
      // TODO: Save to backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.snackbar(
        'Saved',
        'Match progress saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> finishMatch() async {
    if (!state.isCompleted.value) {
      Get.snackbar(
        'Incomplete',
        'Please score all arrows before finishing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    state.isLoading.value = true;
    try {
      // TODO: Save final match to backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Match Complete!',
        'Total Score: ${state.totalScore.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  void exitMatch() {
    Get.dialog(
      GetBuilder<MatchDetailController>(
        init: this,
        builder: (_) => AlertDialog(
          title: const Text('Exit Match'),
          content: const Text('Do you want to save your progress before leaving?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await saveMatch();
                Get.back();
              },
              child: const Text('Save & Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
