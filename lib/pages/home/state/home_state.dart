import 'package:get/get.dart';

class HomeState {
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;
  
  // User info
  final RxString userName = 'Archer'.obs;
  
  // Stats
  final RxInt totalMatches = 0.obs;
  final RxInt averageScore = 0.obs;
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
