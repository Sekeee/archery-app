import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSetupState {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  
  // Profile image
  final Rx<File?> profileImage = Rx<File?>(null);
  
  // Error message
  final RxString errorMessage = ''.obs;
}
