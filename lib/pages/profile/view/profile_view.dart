import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/theme_service.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.state.isEditing.value ? 'Edit Profile' : 'Profile',
            style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: Obx(
          () =>
              controller.state.isEditing.value
                  ? IconButton(
                    icon: Icon(Icons.close, color: context.textSecondaryColor),
                    onPressed: controller.cancelEdit,
                  )
                  : const SizedBox.shrink(),
        ),
        actions: [
          Obx(
            () =>
                controller.state.isEditing.value
                    ? controller.state.isLoading.value
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                        : IconButton(
                          icon: const Icon(Icons.check, color: AppColors.primary),
                          onPressed: controller.saveAndExit,
                        )
                    : IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: controller.toggleEditMode,
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Profile header
        Container(
          width: Get.width,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // Profile image
                  GestureDetector(
                    onTap: controller.state.isEditing.value ? () => controller.showImagePickerOptions(context) : null,
                    child: Obx(
                      () => Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.backgroundColor,
                              border: Border.all(
                                color:
                                    controller.state.isEditing.value
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(alpha: 0.3),
                                width: 3,
                              ),
                              image:
                                  controller.state.profileImage.value != null
                                      ? DecorationImage(
                                        image: FileImage(controller.state.profileImage.value!),
                                        fit: BoxFit.cover,
                                      )
                                      : controller.state.profileImageUrl.value.isNotEmpty
                                      ? DecorationImage(
                                        image: NetworkImage(controller.state.profileImageUrl.value),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                controller.state.profileImage.value == null &&
                                        controller.state.profileImageUrl.value.isEmpty
                                    ? Icon(Icons.person, size: 50, color: context.textSecondaryColor)
                                    : null,
                          ),
                          if (controller.state.isEditing.value)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, size: 16, color: AppColors.textOnPrimary),
                              ),
                            ),
                          if (controller.state.isUploading.value)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                            ? Column(
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: TextField(
                                    controller: controller.state.usernameController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: 'Enter username',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap on profile image to change',
                                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor.withValues(alpha: 0.7)),
                                ),
                              ],
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
                      style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(16)),
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
                          icon: Icons.percent,
                          label: 'Avg Accuracy',
                          value: '${controller.state.avgAccuracy.value.toStringAsFixed(1)}%',
                        ),
                        _buildStatItem(
                          icon: Icons.emoji_events,
                          label: 'Best Score',
                          value: controller.state.bestScore.value.toString(),
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
              decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSettingsItem(icon: Icons.edit, label: 'Edit Profile', onTap: controller.toggleEditMode),
                  const Divider(height: 1),
                  _buildThemeToggle(),
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
        );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Builder(
      builder: (context) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : context.textSecondaryColor),
        title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : context.textPrimaryColor)),
        trailing: Icon(Icons.chevron_right, color: context.textSecondaryColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Builder(
      builder: (context) => Obx(() => ListTile(
        leading: Icon(
          ThemeService.to.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: context.textSecondaryColor,
        ),
        title: Text('Dark Mode', style: TextStyle(color: context.textPrimaryColor)),
        trailing: Switch(
          value: ThemeService.to.isDarkMode,
          onChanged: (_) => ThemeService.to.toggleTheme(),
          activeColor: AppColors.primary,
        ),
        onTap: () => ThemeService.to.toggleTheme(),
      )),
    );
  }
}
