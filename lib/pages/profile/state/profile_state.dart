import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileState {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // User info
  final RxString username = 'Archer'.obs;
  final RxString phoneNumber = '99001122'.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  
  // Stats
  final RxInt totalMatches = 0.obs;
  final RxInt totalArrows = 0.obs;
  final RxDouble averageScore = 0.0.obs;
  
  // Edit mode
  final RxBool isEditing = false.obs;
  final TextEditingController usernameController = TextEditingController();
}
