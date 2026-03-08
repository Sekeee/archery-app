import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes/app_routes.dart';
import '../state/profile_state.dart';

class ProfileController extends GetxController {
  final state = ProfileState();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    // TODO: Load actual user profile from backend
    state.username.value = 'Archer';
    state.phoneNumber.value = '99001122';
    state.totalMatches.value = 24;
    state.totalArrows.value = 1250;
    state.averageScore.value = 8.4;
    
    state.usernameController.text = state.username.value;
  }

  void toggleEditMode() {
    if (state.isEditing.value) {
      // Save changes
      saveProfile();
    } else {
      state.usernameController.text = state.username.value;
    }
    state.isEditing.toggle();
  }

  Future<void> saveProfile() async {
    state.isLoading.value = true;
    try {
      // TODO: Save to backend
      await Future.delayed(const Duration(milliseconds: 500));
      state.username.value = state.usernameController.text;
      Get.snackbar(
        'Success',
        'Profile updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      state.isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        state.profileImage.value = File(image.path);
        // TODO: Upload to backend
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Clear user data
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
