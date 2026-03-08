import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/all_matches_state.dart';

class AllMatchesController extends GetxController {
  final state = AllMatchesState();

  @override
  void onInit() {
    super.onInit();
    // Get passed category from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['category'] != null) {
      state.selectedCategory.value = args['category'];
    }
    _loadMatches();
  }

  void _loadMatches() {
    state.isLoading.value = true;
    
    // TODO: Load actual matches from Firestore based on category
    // For now, using dummy data
    state.matches.value = _getDummyMatches();
    
    state.isLoading.value = false;
  }

  List<Map<String, dynamic>> _getDummyMatches() {
    final allMatches = [
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
        'name': 'March 01 Practice',
        'matchType': 'Range',
        'category': 'Range',
        'date': DateTime(2026, 3, 1),
        'ends': 10,
        'arrowsPerEnd': 3,
        'score': 201,
        'rank': 1,
        'isCompleted': true,
      },
      {
        'name': 'February 28 Training',
        'matchType': 'Range',
        'category': 'Range',
        'date': DateTime(2026, 2, 28),
        'ends': 8,
        'arrowsPerEnd': 3,
        'score': 165,
        'rank': 2,
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
      {
        'name': 'March 02 Moving Session',
        'matchType': 'Moving Object',
        'category': 'Moving Object',
        'date': DateTime(2026, 3, 2),
        'ends': 8,
        'arrowsPerEnd': 3,
        'score': 158,
        'rank': 2,
        'isCompleted': true,
      },
    ];
    
    return allMatches
        .where((match) => match['category'] == state.selectedCategory.value)
        .toList();
  }

  /// Get filtered matches based on selected category
  List<Map<String, dynamic>> get filteredMatches {
    return state.matches
        .where((match) => match['category'] == state.selectedCategory.value)
        .toList();
  }

  void onCategorySelected(String category) {
    state.selectedCategory.value = category;
    _loadMatches();
  }

  void viewMatchDetails(Map<String, dynamic> match) {
    Get.toNamed(AppRoutes.matchDetail, arguments: match);
  }

  void goBack() {
    Get.back();
  }
}
