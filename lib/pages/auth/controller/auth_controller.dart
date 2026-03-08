import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/auth_state.dart';

class AuthController extends GetxController {
  final state = AuthState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<void> sendOtp() async {
    if (!state.formKey.currentState!.validate()) return;

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      final phoneNumber = '+976${state.phoneController.text}';

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification Failed: ${e.code} - ${e.message}');
          state.isLoading.value = false;
          state.errorMessage.value = _getErrorMessage(e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          state.isLoading.value = false;
          state.verificationId.value = verificationId;
          state.resendToken = resendToken;

          // Navigate to OTP screen
          Get.toNamed(
            AppRoutes.otp,
            arguments: {'phoneNumber': phoneNumber, 'verificationId': verificationId, 'resendToken': resendToken},
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state.verificationId.value = verificationId;
        },
        forceResendingToken: state.resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      log('Firebase Phone Auth Error: $e');
      state.errorMessage.value = 'Error: ${e.toString()}';
      state.isLoading.value = false;
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final userExists = await _userService.userExists(userCredential.user!.uid);
      
      if (userExists) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.profileSetup);
      }
    } catch (e) {
      state.errorMessage.value = 'Auto-verification failed.';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return 'Failed to send OTP. Please try again.';
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
