import 'package:get/get.dart';

import '../pages/splash/controller/splash_controller.dart';
import '../pages/splash/view/splash_view.dart';
import '../pages/auth/controller/auth_controller.dart';
import '../pages/auth/view/auth_view.dart';
import '../pages/otp/controller/otp_controller.dart';
import '../pages/otp/view/otp_view.dart';
import '../pages/profile_setup/controller/profile_setup_controller.dart';
import '../pages/profile_setup/view/profile_setup_view.dart';
import '../pages/home/controller/home_controller.dart';
import '../pages/home/view/home_view.dart';
import '../pages/new_match/controller/new_match_controller.dart';
import '../pages/new_match/view/new_match_view.dart';
import '../pages/match_detail/controller/match_detail_controller.dart';
import '../pages/match_detail/view/match_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OtpController());
      }),
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileSetupController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.newMatch,
      page: () => const NewMatchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NewMatchController());
      }),
    ),
    GetPage(
      name: AppRoutes.matchDetail,
      page: () => const MatchDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MatchDetailController());
      }),
    ),
  ];
}
