import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(controller.state.isEditing.value ? Icons.check : Icons.edit, color: AppColors.primary),
              onPressed: controller.toggleEditMode,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              width: Get.width,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // Profile image
                  GestureDetector(
                    onTap: () => controller.showImagePickerOptions(context),
                    child: Obx(
                      () => Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.background,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                              image:
                                  controller.state.profileImage.value != null
                                      ? DecorationImage(
                                        image: FileImage(controller.state.profileImage.value!),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                controller.state.profileImage.value == null
                                    ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 16, color: AppColors.textOnPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Username
                  Obx(
                    () =>
                        controller.state.isEditing.value
                            ? SizedBox(
                              width: 200,
                              child: TextField(
                                controller: controller.state.usernameController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            )
                            : Text(
                              controller.state.username.value,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                  ),

                  const SizedBox(height: 4),

                  // Phone number
                  Obx(
                    () => Text(
                      controller.state.phoneNumber.value,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Obx(
                    () => Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.sports_score,
                          label: 'Matches',
                          value: controller.state.totalMatches.value.toString(),
                        ),
                        _buildStatItem(
                          icon: Icons.arrow_upward,
                          label: 'Arrows',
                          value: controller.state.totalArrows.value.toString(),
                        ),
                        _buildStatItem(
                          icon: Icons.analytics,
                          label: 'Avg Score',
                          value: controller.state.averageScore.value.toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings section
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // _buildSettingsItem(
                  //   icon: Icons.help_outline,
                  //   label: 'Help & Support',
                  //   onTap: () {
                  //     Get.snackbar('Coming Soon', 'Help & Support', snackPosition: SnackPosition.BOTTOM);
                  //   },
                  // ),
                  // const Divider(height: 1),
                  // _buildSettingsItem(
                  //   icon: Icons.info_outline,
                  //   label: 'About',
                  //   onTap: () {
                  //     Get.snackbar('Coming Soon', 'About', snackPosition: SnackPosition.BOTTOM);
                  //   },
                  // ),
                  const Divider(height: 1),
                  _buildSettingsItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    isDestructive: true,
                    onTap: controller.logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
