import 'package:get/get.dart';

import '../../../core/services/match_service.dart';
import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/home_state.dart';

class HomeController extends GetxController {
  final state = HomeState();
  final UserService _userService = UserService();
  final MatchService _matchService = MatchService();

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadUserData();
    await _loadRecentMatches();
    _updateCategoryStats();
  }

  Future<void> _loadUserData() async {
    state.isLoading.value = true;
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        state.currentUser.value = user;
        state.userName.value = user.username;
        state.photoUrl.value = user.photoUrl;
        
        _updateCategoryStats();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      state.isLoading.value = false;
    }
  }

  void _updateCategoryStats() {
    final category = state.selectedCategory.value;
    final matches = state.recentMatches
        .where((m) => m['category'] == category)
        .toList();

    state.totalMatches.value = matches.length;

    if (matches.isEmpty) {
      state.avgAccuracy.value = 0.0;
      state.bestScore.value = 0;
      return;
    }

    int best = 0;
    int completedCount = 0;
    for (final m in matches) {
      final score = (m['score'] ?? 0) as int;
      if (score > best) best = score;
      if (m['isCompleted'] == true) completedCount++;
    }
    state.bestScore.value = best;
    state.avgAccuracy.value = matches.isEmpty
        ? 0.0
        : (completedCount / matches.length * 100);
  }

  void onCategorySelected(String category) {
    state.selectedCategory.value = category;
    _updateCategoryStats();
  }

  Future<void> _loadRecentMatches() async {
    final user = state.currentUser.value;
    if (user == null) {
      state.recentMatches.value = [];
      return;
    }
    try {
      final matches = await _matchService.fetchUserMatches(user.uid);
      state.recentMatches.value = matches;
    } catch (e) {
      print('Error loading matches: $e');
      state.recentMatches.value = [];
    }
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
    await _loadRecentMatches();
    _updateCategoryStats();
  }
}
