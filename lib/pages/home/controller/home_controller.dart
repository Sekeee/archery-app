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
        'matchType': 'Range',
        'category': 'Range',
        'date': DateTime(2026, 3, 3),
        'ends': 10,
        'arrowsPerEnd': 3,
        'score': 186,
        'rank': 3,
        'isCompleted': true,
      },
      {
        'name': 'March 05 Training',
        'matchType': 'Moving Object',
        'category': 'Moving Object',
        'date': DateTime(2026, 3, 5),
        'ends': 10,
        'arrowsPerEnd': 3,
        'score': 172,
        'rank': 1,
        'isCompleted': true,
      },
    ];
  }

  void onBottomNavTap(int index) {
    state.selectedIndex.value = index;
  }

  void createNewMatch() {
    Get.toNamed(AppRoutes.newMatch);
  }

  void viewMatchDetails(Map<String, dynamic> match) {
    Get.toNamed(AppRoutes.matchDetail, arguments: match);
  }

  void logout() {
    // TODO: Implement actual logout
    Get.offAllNamed(AppRoutes.auth);
  }
}
