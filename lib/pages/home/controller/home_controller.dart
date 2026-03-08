import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/home_state.dart';

class HomeController extends GetxController {
  final state = HomeState();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadRecentMatches();
  }

  void _loadUserData() {
    // TODO: Load actual user data
    state.userName.value = 'Archer';
    state.totalMatches.value = 12;
    state.averageScore.value = 184;
    state.bestScore.value = 198;
  }

  void _loadRecentMatches() {
    // TODO: Load actual match data
    state.recentMatches.value = [
      {
        'name': 'March 03 Morning Class',
        'category': 'Range',
        'date': '2026-03-03',
        'score': 186,
        'rank': 3,
      },
      {
        'name': 'March 05 Training',
        'category': 'Moving Object',
        'date': '2026-03-05',
        'score': 172,
        'rank': 1,
      },
    ];
  }

  void onBottomNavTap(int index) {
    state.selectedIndex.value = index;
  }

  void createNewMatch() {
    // TODO: Navigate to create match screen
    Get.snackbar(
      'Coming Soon',
      'Create match feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewMatchDetails(Map<String, dynamic> match) {
    // TODO: Navigate to match details
    Get.snackbar(
      match['name'],
      'Score: ${match['score']} | Rank: #${match['rank']}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    // TODO: Implement actual logout
    Get.offAllNamed(AppRoutes.auth);
  }
}
