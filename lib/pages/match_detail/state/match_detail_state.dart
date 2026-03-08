import 'package:get/get.dart';

class MatchDetailState {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Match info
  final RxString matchName = ''.obs;
  final RxString matchType = ''.obs;
  final Rx<DateTime> matchDate = DateTime.now().obs;
  final RxInt totalEnds = 10.obs;
  final RxInt arrowsPerEnd = 3.obs;
  
  // Current end (1-indexed)
  final RxInt currentEnd = 1.obs;
  
  // Currently selected arrow index within the current end (0-indexed)
  final RxInt selectedArrowIndex = 0.obs;
  
  // Scores: List of ends, each end is a list of arrow scores
  // e.g., [[10, 9, 8], [10, 10, 9], ...]
  final RxList<List<int>> scores = <List<int>>[].obs;
  
  // Total score
  final RxInt totalScore = 0.obs;
  
  // Match completed
  final RxBool isCompleted = false.obs;
}
