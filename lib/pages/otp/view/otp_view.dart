import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/otp_controller.dart';
import '../suite/components/otp_input_field.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: controller.goBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header
              const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                'Enter the code sent to\n${controller.state.phoneNumber.value}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
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

              // OTP Input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => OtpInputField(
                    controller: controller.state.otpControllers[index],
                    focusNode: controller.state.focusNodes[index],
                    onChanged: (value) => controller.onOtpChanged(value, index),
                    onBackspace: () => controller.onOtpBackspace(index),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Verify button
              Obx(() => SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.state.isLoading.value
                      ? null
                      : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.state.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),

              const SizedBox(height: 24),

              // Resend code
              Center(
                child: Obx(() {
                  if (controller.state.canResend.value) {
                    return GestureDetector(
                      onTap: controller.state.isResending.value
                          ? null
                          : controller.resendOtp,
                      child: Text(
                        controller.state.isResending.value
                            ? 'Sending...'
                            : 'Resend Code',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return Text(
                    'Resend code in ${controller.state.resendTimer.value}s',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Change number
              Center(
                child: GestureDetector(
                  onTap: controller.goBack,
                  child: const Text(
                    'Change phone number',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
