import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import '../suite/components/auth_text_field.dart';
import '../suite/components/auth_button.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.state.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Header
                const Icon(
                  Icons.sports_martial_arts,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Obx(() => Text(
                  controller.state.isLoginMode.value ? 'Welcome Back' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 8),
                Obx(() => Text(
                  controller.state.isLoginMode.value
                      ? 'Sign in to continue your training'
                      : 'Join the archery training community',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 40),

                // Error message
                Obx(() {
                  if (controller.state.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.state.errorMessage.value,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),

                // Name field (register only)
                Obx(() {
                  if (controller.state.isLoginMode.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      AuthTextField(
                        controller: controller.state.nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Email field
                AuthTextField(
                  controller: controller.state.emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password field
                Obx(() => AuthTextField(
                  controller: controller.state.passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: controller.state.isPasswordVisible.value,
                  onTogglePassword: controller.togglePasswordVisibility,
                  validator: controller.validatePassword,
                )),

                // Confirm password field (register only)
                Obx(() {
                  if (controller.state.isLoginMode.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: controller.state.confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: controller.state.isPasswordVisible.value,
                        onTogglePassword: controller.togglePasswordVisibility,
                        validator: controller.validateConfirmPassword,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Submit button
                Obx(() => AuthButton(
                  text: controller.state.isLoginMode.value ? 'Sign In' : 'Sign Up',
                  isLoading: controller.state.isLoading.value,
                  onPressed: controller.state.isLoginMode.value
                      ? controller.login
                      : controller.register,
                )),

                const SizedBox(height: 24),

                // Toggle auth mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Text(
                      controller.state.isLoginMode.value
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: const TextStyle(color: AppColors.textSecondary),
                    )),
                    Obx(() => GestureDetector(
                      onTap: controller.toggleAuthMode,
                      child: Text(
                        controller.state.isLoginMode.value ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
