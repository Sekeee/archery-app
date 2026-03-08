import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthState {
  // Auth mode
  final RxBool isLoginMode = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Error message
  final RxString errorMessage = ''.obs;
}
