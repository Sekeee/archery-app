import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetWidget<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: RiveWidgetBuilder(
                fileLoader: FileLoader.fromAsset('assets/no-background.riv', riveFactory: Factory.rive),
                builder: (context, state) {
                  if (state is RiveLoaded) {
                    return RiveWidget(controller: state.controller);
                  }
                  return const CircularProgressIndicator(color: AppColors.primary);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Archery Training',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text('Track your progress', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
