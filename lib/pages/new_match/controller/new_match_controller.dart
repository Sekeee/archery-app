import 'package:get/get.dart';

import '../../../core/services/match_service.dart';
import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/new_match_state.dart';

class NewMatchController extends GetxController {
  final state = NewMatchState();
  final MatchService _matchService = MatchService();
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    // Add listeners to update total arrows
    state.endsController.addListener(_updateTotalArrows);
    state.arrowsPerEndController.addListener(_updateTotalArrows);
  }

  void _updateTotalArrows() {
    final ends = int.tryParse(state.endsController.text) ?? 0;
    final arrowsPerEnd = int.tryParse(state.arrowsPerEndController.text) ?? 0;
    state.totalArrows.value = ends * arrowsPerEnd;
  }

  void setMatchType(String? type) {
    if (type != null) {
      state.selectedMatchType.value = type;
    }
  }

  Future<void> createMatch() async {
    if (!state.formKey.currentState!.validate()) return;
    // Extra check: ensure all fields are filled
    final name = state.nameController.text.trim();
    final endsText = state.endsController.text.trim();
    final arrowsText = state.arrowsPerEndController.text.trim();
    if (name.isEmpty || endsText.isEmpty || arrowsText.isEmpty) {
      state.errorMessage.value = 'Please fill all fields.';
      return;
    }
    final ends = int.tryParse(endsText);
    final arrowsPerEnd = int.tryParse(arrowsText);
    if (ends == null || arrowsPerEnd == null) {
      state.errorMessage.value = 'Please enter valid numbers.';
      return;
    }

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // Get current user info
      final user = await _userService.getCurrentUser();
      if (user == null) {
        state.errorMessage.value = 'User not found.';
        state.isLoading.value = false;
        return;
      }

      final matchId = await _matchService.createMatch(
        matchType: state.selectedMatchType.value,
        name: name,
        ends: ends,
        arrowsPerEnd: arrowsPerEnd,
        userId: user.uid,
        username: user.username,
        photoUrl: user.photoUrl ?? '',
      );

      if (matchId == null) {
        state.errorMessage.value = 'Failed to create match. Please try again.';
        state.isLoading.value = false;
        return;
      }

      // Navigate to match detail (scoring screen)
      Get.offNamed(AppRoutes.matchDetail, arguments: {
        'matchId': matchId,
        'name': name,
        'matchType': state.selectedMatchType.value,
        'date': DateTime.now(),
        'ends': ends,
        'arrowsPerEnd': arrowsPerEnd,
        'userId': user.uid,
      });
    } catch (e) {
      state.errorMessage.value = 'Failed to create match. Please try again.';
    } finally {
      state.isLoading.value = false;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Match name is required';
    }
    return null;
  }

  String? validateEnds(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of ends is required';
    }
    final ends = int.tryParse(value);
    if (ends == null || ends < 1 || ends > 50) {
      return 'Enter a valid number (1-50)';
    }
    return null;
  }

  String? validateArrowsPerEnd(String? value) {
    if (value == null || value.isEmpty) {
      return 'Arrows per end is required';
    }
    final arrows = int.tryParse(value);
    if (arrows == null || arrows < 1 || arrows > 12) {
      return 'Enter a valid number (1-12)';
    }
    return null;
  }

  @override
  void onClose() {
    state.nameController.dispose();
    state.endsController.dispose();
    state.arrowsPerEndController.dispose();
    super.onClose();
  }
}
