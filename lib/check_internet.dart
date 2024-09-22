import 'package:acma_intl/screens/splash_screen.dart';
import 'package:acma_intl/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controllers/theme_controller.dart';

class CheckInternet extends StatelessWidget {
  const CheckInternet({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = Get.find();

    return Obx(() {
      return SafeArea(
        child: Scaffold(
          backgroundColor: theme.scaffoldBg.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 200, child: Image.asset('assets/no_internet.png')),
                const SizedBox(height: 10),
                Text(
                  'No Internet Connection. Please try again!',
                  style: TextStyle(fontSize: 16, color: theme.textDark.value),
                ),
                const SizedBox(height: 30),
                Utils.customElevatedButton(
                    btnName: 'Retry Again',
                    onPress: () {
                      Get.off(const SplashScreen());
                    },
                    bgColor: theme.appbarBottomNav.value,
                    textClr: theme.textLight.value)
              ],
            ),
          ),
        ),
      );
    });
  }
}
