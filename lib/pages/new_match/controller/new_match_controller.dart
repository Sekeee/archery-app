import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/new_match_state.dart';

class NewMatchController extends GetxController {
  final state = NewMatchState();

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

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Save match to database
      await Future.delayed(const Duration(milliseconds: 500));
      
      final match = {
        'name': state.nameController.text,
        'date': DateTime.now(),
        'matchType': state.selectedMatchType.value,
        'ends': int.tryParse(state.endsController.text) ?? 10,
        'arrowsPerEnd': int.tryParse(state.arrowsPerEndController.text) ?? 3,
      };

      // Navigate to match detail (scoring screen)
      Get.offNamed(AppRoutes.matchDetail, arguments: match);
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
