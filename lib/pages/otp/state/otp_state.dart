import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpState {
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  
  // OTP controllers (6 digits)
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  
  // Focus nodes
  final List<FocusNode> focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  
  // Phone number
  final RxString phoneNumber = ''.obs;
  
  // Error message
  final RxString errorMessage = ''.obs;
  
  // Resend timer
  final RxInt resendTimer = 60.obs;
  final RxBool canResend = false.obs;
  
  // Timer
  Timer? countdownTimer;
  
  String get otpCode => otpControllers.map((c) => c.text).join();
}
