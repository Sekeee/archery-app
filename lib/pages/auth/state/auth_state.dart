import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthState {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Error message
  final RxString errorMessage = ''.obs;
}
