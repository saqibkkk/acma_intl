import 'package:acma_intl/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controllers/theme_controller.dart';

class UpdateAppScreen extends StatelessWidget {
  final String currentVersion;
  final String newVersion;
  final VoidCallback onPress;

  const UpdateAppScreen(
      {super.key,
      required this.currentVersion,
      required this.newVersion,
      required this.onPress});

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
                SizedBox(height: 300, child: Image.asset('assets/update.png')),
                Text(
                  'Current Version: $currentVersion',
                  style: TextStyle(color: theme.textDark.value, fontSize: 16),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('Please update to new version $newVersion',
                    style:
                        TextStyle(color: theme.textDark.value, fontSize: 16)),
                const SizedBox(
                  height: 20,
                ),
                Utils.customElevatedButton(
                    btnName: 'Update Application',
                    onPress: onPress,
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
