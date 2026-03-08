import 'package:get/get.dart';

import '../pages/splash/controller/splash_controller.dart';
import '../pages/splash/view/splash_view.dart';
import '../pages/auth/controller/auth_controller.dart';
import '../pages/auth/view/auth_view.dart';
import '../pages/otp/controller/otp_controller.dart';
import '../pages/otp/view/otp_view.dart';
import '../pages/home/controller/home_controller.dart';
import '../pages/home/view/home_view.dart';
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
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
  ];
}
