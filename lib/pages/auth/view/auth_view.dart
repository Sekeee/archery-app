import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import '../suite/components/auth_button.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
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
                const Icon(Icons.sports, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to continue',
                  style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
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
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.state.errorMessage.value,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),

                // Phone number field
                Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.state.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                  validator: controller.validatePhone,
                  decoration: InputDecoration(
                    hintText: '',
                    counterText: '',
                    hintStyle: TextStyle(color: context.textHintColor),
                    prefixIcon: Icon(Icons.phone_outlined, color: context.textSecondaryColor),
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                const SizedBox(height: 32),

                // Continue button
                Obx(
                  () => AuthButton(
                    text: 'Continue',
                    isLoading: controller.state.isLoading.value,
                    onPressed: controller.sendOtp,
                  ),
                ),

                const SizedBox(height: 24),

                // Info text
                Text(
                  'We will send you a verification code',
                  style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
