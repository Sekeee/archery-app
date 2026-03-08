import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/user_model.dart';

class ProfileState {
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // User info (for display)
  final RxString username = 'Archer'.obs;
  final RxString phoneNumber = ''.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;

  // Aggregated stats across all categories
  final RxInt totalMatches = 0.obs;
  final RxDouble avgAccuracy = 0.0.obs;
  final RxInt bestScore = 0.obs;

  // Edit mode
  final RxBool isEditing = false.obs;
  final TextEditingController usernameController = TextEditingController();
}
