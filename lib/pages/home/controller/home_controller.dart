import 'package:get/get.dart';

import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/home_state.dart';

class HomeController extends GetxController {
  final state = HomeState();
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadRecentMatches();
  }

  Future<void> _loadUserData() async {
    state.isLoading.value = true;
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        state.currentUser.value = user;
        state.userName.value = user.username;
        state.photoUrl.value = user.photoUrl;
        
        // Load stats for selected category
        _updateCategoryStats();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      state.isLoading.value = false;
    }
  }

  void _updateCategoryStats() {
    final user = state.currentUser.value;
    if (user == null) return;
    
    final stats = user.getStats(state.selectedCategory.value);
    state.totalMatches.value = stats.totalMatches;
    state.avgAccuracy.value = stats.avgAccuracy;
    state.bestScore.value = stats.bestScore;
  }

  void onCategorySelected(String category) {
    state.selectedCategory.value = category;
    _updateCategoryStats();
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
    // Refresh user data when returning to home tab
    if (index == 0) {
      refreshUserData();
    }
  }

  void createNewMatch() {
    Get.toNamed(AppRoutes.newMatch);
  }

  void viewMatchDetails(Map<String, dynamic> match) {
    Get.toNamed(AppRoutes.matchDetail, arguments: match);
  }

  void viewAllMatches() {
    Get.toNamed(AppRoutes.allMatches, arguments: {
      'category': state.selectedCategory.value,
    });
  }

  /// Get recent matches filtered by selected category
  List<Map<String, dynamic>> get filteredRecentMatches {
    final category = state.selectedCategory.value;
    return state.recentMatches
        .where((match) => match['category'] == category)
        .toList();
  }

  Future<void> logout() async {
    await _userService.signOut();
    Get.offAllNamed(AppRoutes.auth);
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}
