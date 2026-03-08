import 'dart:async';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/otp_state.dart';

class OtpController extends GetxController {
  final state = OtpState();

  @override
  void onInit() {
    super.onInit();
    // Get phone number from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('phoneNumber')) {
      state.phoneNumber.value = args['phoneNumber'];
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    state.resendTimer.value = 60;
    state.canResend.value = false;
    
    state.countdownTimer?.cancel();
    state.countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendTimer.value > 0) {
        state.resendTimer.value--;
      } else {
        state.canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      state.focusNodes[index + 1].requestFocus();
    }
    
    // Auto verify when all digits entered
    if (state.otpCode.length == 6) {
      verifyOtp();
    }
  }

  void onOtpBackspace(int index) {
    if (index > 0 && state.otpControllers[index].text.isEmpty) {
      state.focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> verifyOtp() async {
    if (state.otpCode.length != 6) {
      state.errorMessage.value = 'Please enter complete OTP';
      return;
    }

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Implement actual Firebase OTP verification
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Check if user exists in database
      // For now, always go to profile setup (new user flow)
      // When API is ready, check if user profile exists and navigate accordingly
      Get.offAllNamed(AppRoutes.profileSetup);
    } catch (e) {
      state.errorMessage.value = 'Invalid OTP. Please try again.';
      _clearOtp();
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!state.canResend.value) return;

    state.isResending.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Implement actual resend OTP logic
      await Future.delayed(const Duration(seconds: 2));
      
      _clearOtp();
      _startResendTimer();
      
      Get.snackbar(
        'OTP Sent',
        'A new verification code has been sent',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      state.errorMessage.value = 'Failed to resend OTP. Please try again.';
    } finally {
      state.isResending.value = false;
    }
  }

  void _clearOtp() {
    for (var controller in state.otpControllers) {
      controller.clear();
    }
    state.focusNodes[0].requestFocus();
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    state.countdownTimer?.cancel();
    for (var controller in state.otpControllers) {
      controller.dispose();
    }
    for (var node in state.focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
