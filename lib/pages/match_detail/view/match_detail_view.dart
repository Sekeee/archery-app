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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: context.textPrimaryColor),
          onPressed: controller.exitMatch,
        ),
        title: Obx(() => Text(
          controller.state.matchName.value,
          style: TextStyle(
            color: context.textPrimaryColor,
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
                : Icon(Icons.save_outlined, color: context.textPrimaryColor),
            onPressed: controller.state.isLoading.value ? null : controller.saveMatch,
          )),
          Obx(() => TextButton(
            onPressed: controller.state.isLoading.value ? null : controller.finishMatch,
            child: Text(
              'End Match',
              style: TextStyle(
                color: controller.state.isCompleted.value
                    ? AppColors.primary
                    : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
      body: Builder(
        builder: (context) => Column(
        children: [
          // Match info header
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: Row(
              children: [
                Obx(() => _buildInfoChip(
                  context,
                  icon: Icons.category,
                  label: controller.state.matchType.value,
                )),
                const SizedBox(width: 12),
                Obx(() => _buildInfoChip(
                  context,
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
            color: context.surfaceColor,
            child: Obx(() {
              final currentEnd = controller.state.currentEnd.value;
              final totalEnds = controller.state.totalEnds.value;
              final scores = controller.state.scores.toList();
              return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: totalEnds,
              itemBuilder: (context, index) {
                final isSelected = currentEnd == index + 1;
                final endScores = scores.isNotEmpty && index < scores.length
                    ? scores[index]
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
                              : context.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'End ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? AppColors.textOnPrimary : context.textPrimaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Current end scoring
          Expanded(
            child: Obx(() {
              final endIndex = controller.state.currentEnd.value - 1;
              final selectedArrow = controller.state.selectedArrowIndex.value;
              final allScores = controller.state.scores.toList();
              
              if (endIndex >= allScores.length) {
                return const Center(child: Text('Loading...'));
              }
              
              final endScores = allScores[endIndex];
              
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Current end header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'End ${endIndex + 1}',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(endScores.length, (arrowIndex) {
                          final score = endScores[arrowIndex];
                          final isSelected = selectedArrow == arrowIndex;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.selectArrow(arrowIndex),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSelected ? 66 : 56,
                                    height: isSelected ? 66 : 56,
                                    decoration: BoxDecoration(
                                      color: score >= 0 ? _getScoreColor(score) : context.backgroundColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryLight
                                            : score >= 0 ? _getScoreColor(score) : context.borderColor,
                                        width: isSelected ? 4 : 2,
                                      ),
                                      boxShadow: isSelected
                                          ? [BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.5),
                                              blurRadius: 12,
                                              spreadRadius: 3,
                                            )]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      score >= 0 ? score.toString() : '-',
                                      style: TextStyle(
                                        fontSize: isSelected ? 26 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: score >= 0 
                                            ? _getScoreTextColor(score, isMiss: score == 0)
                                            : context.textSecondaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Arrow label
                                  Text(
                                    '${arrowIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.primaryLight : context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    // Selected arrow indicator
                    const SizedBox(height: 8),
                    Text(
                      'Arrow ${selectedArrow + 1} selected',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Score input buttons
                    _buildScoreInputGrid(endIndex),
                    
                    const SizedBox(height: 24),
                    
                    // Running total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
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
              color: context.surfaceColor,
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
                        : context.textSecondaryColor,
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
                        backgroundColor: context.backgroundColor,
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
      )),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.textSecondaryColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildScoreInputGrid(int endIndex) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('10', 10, endIndex),
            _buildScoreButton('9', 9, endIndex),
            _buildScoreButton('8', 8, endIndex),
            _buildScoreButton('7', 7, endIndex),
            _buildScoreButton('6', 6, endIndex),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('5', 5, endIndex),
            _buildScoreButton('4', 4, endIndex),
            _buildScoreButton('3', 3, endIndex),
            _buildScoreButton('2', 2, endIndex),
            _buildScoreButton('1', 1, endIndex),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreButton('0', 0, endIndex, isMiss: true),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreButton(
    String label,
    int score,
    int endIndex, {
    bool isMiss = false,
  }) {
    return GestureDetector(
      onTap: () => controller.recordScore(endIndex, score),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMiss
              ? Colors.grey[300]
              : _getScoreColor(score),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getScoreTextColor(score, isMiss: isMiss),
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
    return Colors.grey;
  }

  Color _getScoreTextColor(int score, {bool isMiss = false}) {
    if (isMiss) return Colors.black;
    if (score >= 9) return Colors.black;
    if (score >= 3) return Colors.white;
    return Colors.black; // scores 1-2 have white background
  }
}
