import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../rankings/controller/rankings_controller.dart';
import '../../rankings/view/rankings_view.dart';
import '../../history/controller/history_controller.dart';
import '../../history/view/history_view.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/view/profile_view.dart';
import '../controller/home_controller.dart';
import '../suite/components/stat_card.dart';
import '../suite/components/match_card.dart';
import '../suite/components/category_chip.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize other controllers
    Get.lazyPut(() => RankingsController());
    Get.lazyPut(() => HistoryController());
    Get.lazyPut(() => ProfileController());
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.state.selectedIndex.value,
        children: [
          _buildHomeContent(),
          const RankingsView(),
          const HistoryView(),
          const ProfileView(),
        ],
      )),
      floatingActionButton: Obx(() => controller.state.selectedIndex.value == 0
          ? FloatingActionButton.extended(
              onPressed: controller.createNewMatch,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              icon: const Icon(Icons.add),
              label: const Text('New Match'),
            )
          : const SizedBox.shrink()),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.state.selectedIndex.value,
          onDestinationSelected: controller.onBottomNavTap,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard),
              label: 'Rankings',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.state.userName.value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats section
            const Text('Your Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Matches',
                      value: controller.state.totalMatches.value.toString(),
                      icon: Icons.sports_score,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Avg Score',
                      value: controller.state.averageScore.value.toString(),
                      icon: Icons.analytics,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Best',
                      value: controller.state.bestScore.value.toString(),
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Categories section
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.state.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return CategoryChip(label: controller.state.categories[index], isSelected: index == 0, onTap: () {});
                },
              ),
            ),

            const SizedBox(height: 24),

            // Recent matches section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Matches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.state.recentMatches.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text(
                      'No matches yet.\nStart training!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(
                children:
                    controller.state.recentMatches
                        .map(
                          (match) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MatchCard(match: match, onTap: () => controller.viewMatchDetails(match)),
                          ),
                        )
                        .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
