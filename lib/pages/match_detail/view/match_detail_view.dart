import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/match_detail_controller.dart';

class MatchDetailView extends GetView<MatchDetailController> {
  const MatchDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          onPressed: controller.exitMatch,
        ),
        title: Obx(() => Text(
          controller.state.matchName.value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        )),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
            icon: controller.state.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, color: AppColors.textPrimary),
            onPressed: controller.state.isLoading.value ? null : controller.saveMatch,
          )),
        ],
      ),
      body: Column(
        children: [
          // Match info header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Obx(() => _buildInfoChip(
                  icon: Icons.category,
                  label: controller.state.matchType.value,
                )),
                const SizedBox(width: 12),
                Obx(() => _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: DateFormat('MMM d').format(controller.state.matchDate.value),
                )),
                const Spacer(),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${controller.state.totalScore.value}',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
              ],
            ),
          ),
          
          // End tabs
          Container(
            height: 50,
            color: AppColors.surface,
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: controller.state.totalEnds.value,
              itemBuilder: (context, index) {
                final isSelected = controller.state.currentEnd.value == index + 1;
                final endScores = controller.state.scores.isNotEmpty && index < controller.state.scores.length
                    ? controller.state.scores[index]
                    : <int>[];
                final isComplete = endScores.isNotEmpty && endScores.every((s) => s >= 0);
                
                return GestureDetector(
                  onTap: () => controller.goToEnd(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isComplete
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'End ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
          
          const SizedBox(height: 16),
          
          // Current end scoring
          Expanded(
            child: Obx(() {
              final endIndex = controller.state.currentEnd.value - 1;
              if (endIndex >= controller.state.scores.length) {
                return const Center(child: Text('Loading...'));
              }
              
              final endScores = controller.state.scores[endIndex];
              
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Current end header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'End ${controller.state.currentEnd.value}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'End Total: ${controller.getEndTotal(endIndex)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Arrow scores display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(endScores.length, (arrowIndex) {
                        final score = endScores[arrowIndex];
                        return Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: score >= 0 ? _getScoreColor(score) : AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: score >= 0 ? _getScoreColor(score) : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            score >= 0 ? (score == 0 ? 'M' : score.toString()) : '-',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: score >= 0 
                                  ? (score >= 9 ? Colors.black : AppColors.textOnPrimary)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Score input buttons
                    _buildScoreInputGrid(endIndex, endScores),
                    
                    const SizedBox(height: 24),
                    
                    // Running total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Running Total',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            controller.getRunningTotal(endIndex).toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous end
                Obx(() => IconButton(
                  onPressed: controller.state.currentEnd.value > 1
                      ? () => controller.goToEnd(controller.state.currentEnd.value - 2)
                      : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: controller.state.currentEnd.value > 1
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                )),
                
                // Progress indicator
                Expanded(
                  child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.state.currentEnd.value} / ${controller.state.totalEnds.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: controller.state.currentEnd.value / controller.state.totalEnds.value,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ],
                  )),
                ),
                
                // Next end / Finish
                Obx(() {
                  if (controller.state.currentEnd.value < controller.state.totalEnds.value) {
                    return IconButton(
                      onPressed: () => controller.goToEnd(controller.state.currentEnd.value),
                      icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                    );
                  } else {
                    return TextButton(
                      onPressed: controller.finishMatch,
                      child: const Text('Finish'),
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildScoreInputGrid(int endIndex, List<int> endScores) {
    // Find first unscored arrow
    int targetArrow = endScores.indexWhere((s) => s < 0);
    if (targetArrow == -1) targetArrow = endScores.length - 1; // All scored, allow edit of last
    
    return Column(
      children: [
        // Row 1: X, 10, 9, 8, 7
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('X', 10, endIndex, targetArrow, isX: true),
            _buildScoreButton('10', 10, endIndex, targetArrow),
            _buildScoreButton('9', 9, endIndex, targetArrow),
            _buildScoreButton('8', 8, endIndex, targetArrow),
            _buildScoreButton('7', 7, endIndex, targetArrow),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: 6, 5, 4, 3, 2
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('6', 6, endIndex, targetArrow),
            _buildScoreButton('5', 5, endIndex, targetArrow),
            _buildScoreButton('4', 4, endIndex, targetArrow),
            _buildScoreButton('3', 3, endIndex, targetArrow),
            _buildScoreButton('2', 2, endIndex, targetArrow),
          ],
        ),
        const SizedBox(height: 8),
        // Row 3: 1, M (miss)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('1', 1, endIndex, targetArrow),
            _buildScoreButton('M', 0, endIndex, targetArrow, isMiss: true),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreButton(
    String label,
    int score,
    int endIndex,
    int arrowIndex, {
    bool isX = false,
    bool isMiss = false,
  }) {
    return GestureDetector(
      onTap: () => controller.recordScore(endIndex, arrowIndex, score),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMiss
              ? Colors.grey[300]
              : isX
                  ? AppColors.gold
                  : _getScoreColor(score),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: score >= 9 ? Colors.black : AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 10) return AppColors.gold;
    if (score >= 9) return AppColors.gold.withValues(alpha: 0.8);
    if (score >= 7) return Colors.red;
    if (score >= 5) return Colors.blue;
    if (score >= 3) return Colors.black;
    if (score >= 1) return Colors.white;
    return Colors.grey; // Miss
  }
}
