import 'package:get/get.dart';

class AllMatchesState {
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'Range'.obs;
  final RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;
  
  // Categories
  final List<String> categories = [
    'Range',
    'Moving Object',
    'Horseback',
    'Long Distance',
    'Dynamic Shooting',
  ];
}
