import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/profile_state.dart';

class ProfileController extends GetxController {
  final state = ProfileState();
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state.isLoading.value = true;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final user = await _userService.getUser(currentUser.uid);
        if (user != null) {
          state.currentUser.value = user;
          state.username.value = user.username;
          state.phoneNumber.value = user.phone;
          state.profileImageUrl.value = user.photoUrl ?? '';
          state.usernameController.text = user.username;

          // Calculate aggregated stats across all categories
          _calculateAggregatedStats(user);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      state.isLoading.value = false;
    }
  }

  void _calculateAggregatedStats(UserModel user) {
    int totalMatches = 0;
    double totalAccuracy = 0;
    int categoriesWithMatches = 0;
    int bestScore = 0;

    for (final stats in user.categoryStats.values) {
      totalMatches += stats.totalMatches;
      if (stats.totalMatches > 0) {
        totalAccuracy += stats.avgAccuracy;
        categoriesWithMatches++;
      }
      if (stats.bestScore > bestScore) {
        bestScore = stats.bestScore;
      }
    }

    state.totalMatches.value = totalMatches;
    state.avgAccuracy.value = categoriesWithMatches > 0 ? totalAccuracy / categoriesWithMatches : 0.0;
    state.bestScore.value = bestScore;
  }

  void toggleEditMode() {
    if (!state.isEditing.value) {
      // Enter edit mode
      state.usernameController.text = state.username.value;
      state.profileImage.value = null; // Reset any unsaved image
    }
    state.isEditing.toggle();
  }

  void cancelEdit() {
    // Reset to original values
    state.usernameController.text = state.username.value;
    state.profileImage.value = null;
    state.isEditing.value = false;
  }

  Future<void> saveAndExit() async {
    await saveProfile();
    state.isEditing.value = false;
  }

  Future<void> saveProfile() async {
    state.isLoading.value = true;
    try {
      state.isUploading.value = state.profileImage.value != null;

      // Update user in Firestore (handles image upload internally)
      await _userService.updateUser(username: state.usernameController.text, profileImage: state.profileImage.value);

      state.username.value = state.usernameController.text;

      // Reload to get updated photoUrl if image was uploaded
      if (state.profileImage.value != null) {
        await _loadProfile();
        state.profileImage.value = null; // Clear local file
      }

      Get.snackbar('Success', 'Profile updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Error saving profile: $e');
      Get.snackbar('Error', 'Failed to update profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      state.isLoading.value = false;
      state.isUploading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (image != null) {
        state.profileImage.value = File(image.path);
        // Image will be uploaded when user saves profile
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a photo'),
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                  ),
                  if (state.profileImage.value != null)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        state.profileImage.value = null;
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed(AppRoutes.auth);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    state.usernameController.dispose();
    super.onClose();
  }
}
