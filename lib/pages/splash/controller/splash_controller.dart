import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/user_service.dart';
import '../../../routes/app_routes.dart';
import '../state/splash_state.dart';

class SplashController extends GetxController {
  final state = SplashState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));
    
    final user = _auth.currentUser;
    
    if (user == null) {
      // Not logged in - go to auth
      Get.offAllNamed(AppRoutes.auth);
    } else {
      // Logged in - check if profile exists
      final userExists = await _userService.userExists(user.uid);
      
      if (userExists) {
        // Has profile - go to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // No profile - go to profile setup
        Get.offAllNamed(AppRoutes.profileSetup);
      }
    }
  }
}
