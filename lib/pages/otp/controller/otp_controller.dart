import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/otp_state.dart';

class OtpController extends GetxController {
  final state = OtpState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    // Get arguments from auth screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      state.phoneNumber.value = args['phoneNumber'] ?? '';
      state.verificationId.value = args['verificationId'] ?? '';
      state.resendToken = args['resendToken'];
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
      // Create credential from verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId.value,
        smsCode: state.otpCode,
      );
      
      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user profile exists in Firestore
      final userExists = await _userService.userExists(userCredential.user!.uid);
      
      if (userExists) {
        // Existing user - go to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // New user - go to profile setup
        Get.offAllNamed(AppRoutes.profileSetup);
      }
    } on FirebaseAuthException catch (e) {
      state.errorMessage.value = _getErrorMessage(e.code);
      _clearOtp();
    } catch (e) {
      state.errorMessage.value = 'Verification failed. Please try again.';
      _clearOtp();
    } finally {
      state.isLoading.value = false;
    }
  }
  
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      default:
        return 'Verification failed. Please try again.';
    }
  }

  Future<void> resendOtp() async {
    if (!state.canResend.value) return;

    state.isResending.value = true;
    state.errorMessage.value = '';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: state.phoneNumber.value,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          final userExists = await _userService.userExists(userCredential.user!.uid);
          if (userExists) {
            Get.offAllNamed(AppRoutes.home);
          } else {
            Get.offAllNamed(AppRoutes.profileSetup);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          state.isResending.value = false;
          state.errorMessage.value = _getErrorMessage(e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          state.isResending.value = false;
          state.verificationId.value = verificationId;
          state.resendToken = resendToken;
          _clearOtp();
          _startResendTimer();
          
          Get.snackbar(
            'OTP Sent',
            'A new verification code has been sent',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state.verificationId.value = verificationId;
        },
        forceResendingToken: state.resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      state.errorMessage.value = 'Failed to resend OTP. Please try again.';
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
