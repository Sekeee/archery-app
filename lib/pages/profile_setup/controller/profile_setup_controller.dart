import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/profile_setup_state.dart';

class ProfileSetupController extends GetxController {
  final state = ProfileSetupState();
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();

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
      }
    } catch (e) {
      state.errorMessage.value = 'Failed to pick image';
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

  Future<void> completeSetup() async {
    if (!state.formKey.currentState!.validate()) return;

    state.isLoading.value = true;
    state.errorMessage.value = '';

    try {
      // Create user in Firestore with optional profile image
      await _userService.createUser(
        username: state.usernameController.text.trim(),
        profileImage: state.profileImage.value,
      );
      
      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      state.errorMessage.value = 'Failed to save profile. Please try again.';
    } finally {
      state.isLoading.value = false;
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 2) {
      return 'Username must be at least 2 characters';
    }
    if (value.trim().length > 20) {
      return 'Username must be less than 20 characters';
    }
    return null;
  }

  @override
  void onClose() {
    state.usernameController.dispose();
    super.onClose();
  }
}
