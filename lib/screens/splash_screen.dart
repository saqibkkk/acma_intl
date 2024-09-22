import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../API/realtime_crud.dart';
import '../Controllers/app_controller.dart';
import '../Controllers/theme_controller.dart';
import '../check_internet.dart';
import '../update_app_screen.dart';
import 'auth_screens/check_company_sign_in.dart';
import 'auth_screens/local_auth.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool biometricEnabled = false;
  late GetStorage box;
  bool showRetryButton = false;
  final ThemeController theme = Get.find();
  final AppController appController = Get.find();

  @override
  void initState() {
    super.initState();
    box = GetStorage();
    _initSwitchValues();
    _checkForUpdateAndNavigate();
  }

  void _initSwitchValues() {
    String key = 'fingerprintEnabled';
    biometricEnabled = box.read(key) ?? false;
  }

  Future<void> _checkForUpdateAndNavigate() async {
    try {
      await appController.checkLatestUpdate();
      await InternetAddress.lookup('google.com');
      if (appController.oldVersion.value !=
          appController.currentVersion.value) {
        Get.off(UpdateAppScreen(
          currentVersion: appController.currentVersion.value,
          newVersion: appController.oldVersion.value,
          onPress: () async {
            await appController.downloadNewVersion();
          },
        ));
      } else {
        await Future.delayed(const Duration(seconds: 2));
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: theme.appbarBottomNav.value,
          systemNavigationBarIconBrightness: Brightness.light,
        ));
        bool isBiometricAvailable = await LocalAuth.isBiometricAvailable();
        bool isAuthenticated = false;

        if (biometricEnabled &&
            isBiometricAvailable &&
            Api.auth.currentUser != null) {
          isAuthenticated = await LocalAuth.authenticate();
        }

        if (isAuthenticated) {
          _navigateToHome();
        } else if (biometricEnabled && isBiometricAvailable) {
          setState(() {
            showRetryButton = true;
          });
        } else {
          _navigateToHome();
        }
      }
    } catch (e) {
      Get.off(const CheckInternet());
    }
  }

  void _navigateToHome() {
    if (Api.auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckNtnPass(),
        ),
      );
    }
  }

  Future<void> _retryAuthentication() async {
    bool isAuthenticated = await LocalAuth.authenticate();

    if (isAuthenticated) {
      _navigateToHome();
    } else {
      setState(() {
        showRetryButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: theme.textLight.value,
        body: Stack(
          children: [
            Positioned(
              child: Center(
                child: Image.asset('assets/acmaLogo.png'),
              ),
            ),
            if (showRetryButton)
              Positioned(
                bottom: 50,
                left: MediaQuery.of(context).size.width * 0.4,
                child: TextButton(
                  onPressed: _retryAuthentication,
                  child: Text('Unlock',
                      style: TextStyle(
                          fontSize: 18,
                          color: theme.appbarBottomNav.value,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
