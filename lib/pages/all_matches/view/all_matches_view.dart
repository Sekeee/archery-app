import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/suite/components/match_card.dart';
import '../../home/suite/components/category_chip.dart';
import '../controller/all_matches_controller.dart';

class AllMatchesView extends GetView<AllMatchesController> {
  const AllMatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: context.textPrimaryColor),
          onPressed: controller.goBack,
        ),
        title: Obx(() => Text(
          '${controller.state.selectedCategory.value} Matches',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: SizedBox(
              height: 40,
              child: Obx(() {
                final selectedCategory = controller.state.selectedCategory.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = controller.state.categories[index];
                    return CategoryChip(
                      label: category,
                      isSelected: selectedCategory == category,
                      onTap: () => controller.onCategorySelected(category),
                    );
                  },
                );
              }),
            ),
          ),
          
          // Matches list
          Expanded(
            child: Obx(() {
              if (controller.state.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final matches = controller.state.matches;
              
              if (matches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_score_outlined,
                        size: 80,
                        color: context.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${controller.state.selectedCategory.value} matches yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start training to see your matches here!',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return MatchCard(
                    match: match,
                    onTap: () => controller.viewMatchDetails(match),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
