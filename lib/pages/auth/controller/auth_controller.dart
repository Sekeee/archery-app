import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/auth_state.dart';

class AuthController extends GetxController {
  final state = AuthState();

  Future<void> sendOtp() async {
    if (!state.formKey.currentState!.validate()) return;

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Implement actual Firebase phone auth
      await Future.delayed(const Duration(seconds: 2));
      
      final phoneNumber = state.phoneController.text;
      
      // Navigate to OTP screen
      Get.toNamed(AppRoutes.otp, arguments: {'phoneNumber': phoneNumber});
    } catch (e) {
      state.errorMessage.value = 'Failed to send OTP. Please try again.';
    } finally {
      state.isLoading.value = false;
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 8) {
      return 'Phone number must be exactly 8 digits';
    }
    return null;
  }

  @override
  void onClose() {
    state.phoneController.dispose();
    super.onClose();
  }
}
