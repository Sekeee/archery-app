import 'dart:developer';

import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../state/splash_state.dart';

class SplashController extends GetxController {
  final state = SplashState();

  @override
  void onInit() {
    super.onInit();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 6));
    // TODO: Check if user is logged in
    // For now, always go to auth
    Get.offAllNamed(AppRoutes.auth);
  }
}
