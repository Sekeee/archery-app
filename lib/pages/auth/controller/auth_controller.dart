import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/auth_state.dart';

class AuthController extends GetxController {
  final state = AuthState();

  void toggleAuthMode() {
    state.isLoginMode.value = !state.isLoginMode.value;
    state.errorMessage.value = '';
    _clearForm();
  }

  void togglePasswordVisibility() {
    state.isPasswordVisible.value = !state.isPasswordVisible.value;
  }

  void _clearForm() {
    state.nameController.clear();
    state.emailController.clear();
    state.passwordController.clear();
    state.confirmPasswordController.clear();
  }

  Future<void> login() async {
    if (!state.formKey.currentState!.validate()) return;

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Implement actual login logic
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to home on success
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      state.errorMessage.value = 'Login failed. Please try again.';
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!state.formKey.currentState!.validate()) return;

    if (state.passwordController.text != state.confirmPasswordController.text) {
      state.errorMessage.value = 'Passwords do not match';
      return;
    }

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // TODO: Implement actual registration logic
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to home on success
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      state.errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      state.isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != state.passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void onClose() {
    state.nameController.dispose();
    state.emailController.dispose();
    state.passwordController.dispose();
    state.confirmPasswordController.dispose();
    super.onClose();
  }
}
