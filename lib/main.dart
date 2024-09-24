import 'package:acma_intl/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'Controllers/app_controller.dart';
import 'Controllers/internet.dart';
import 'Controllers/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AppController());
  Get.put(ThemeController());
  Get.put(InternetController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    themeController.theme.listen((themeValue) {
      _updateSystemChrome(themeValue);
    });

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.theme.value == "0"
            ? ThemeData.light()
            : ThemeData.dark(),
        title: 'ACMA INTL',
        home: const SplashScreen()
        );
  }

  void _updateSystemChrome(String themeValue) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          themeValue == "0" ? const Color(0xff123456) : const Color(0xff252734),
      systemNavigationBarIconBrightness:
          themeValue == "0" ? Brightness.dark : Brightness.light,
      statusBarColor:
          themeValue == "0" ? const Color(0xff123456) : const Color(0xff252734),
      statusBarIconBrightness:
          themeValue == "0" ? Brightness.dark : Brightness.light,
    ));
  }
}
