import 'package:get/get.dart';

import '../../../core/models/user_model.dart';

class HomeState {
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;
  
  // User info
  final RxString userName = ''.obs;
  final Rxn<String> photoUrl = Rxn<String>();
  
  // Current user model
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  
  // Selected category for stats
  final RxString selectedCategory = 'Range'.obs;
  
  // Stats (updates based on selected category)
  final RxInt totalMatches = 0.obs;
  final RxDouble avgAccuracy = 0.0.obs;
  final RxInt bestScore = 0.obs;
  
  // Recent matches
  final RxList<Map<String, dynamic>> recentMatches = <Map<String, dynamic>>[].obs;
  
  // Categories
  final List<String> categories = [
    'Range',
    'Moving Object',
    'Horseback',
    'Long Distance',
    'Dynamic Shooting',
  ];
}
