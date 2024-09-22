import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  var theme = "0".obs;
  var scaffoldBg = const Color(0xff252734).obs;
  var bgLight1 = const Color(0xff333646).obs;
  var bgLight2 = const Color(0xff424657).obs;
  var textFieldBg = const Color(0xffC8C9CE).obs;
  var hintDark = const Color(0xff666874).obs;
  var yellowSecondary = const Color(0xffFFC25C).obs;
  var yellowPrimary = const Color(0xffFFAF29).obs;
  var greenPrimary = const Color(0xffFFAF29).obs;
  var iconColor = const Color(0xffC8C9CE).obs;
  var darkExtra = const Color(0xff252734).obs;
  var textDark = const Color(0xffF6EBBD).obs;
  var textLight = const Color(0xffF6EBBD).obs;
  var cardBtn = const Color(0xFFC9DFEC).obs;
  var appbarBottomNav = const Color(0xFFC9DFEC).obs;
  var multipleRows = const Color(0xFFC9DFEC).obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    await getTheme();
  }

  Future<void> getTheme() async {
    var storedTheme = box.read<String>('storageTheme');
    if (storedTheme == null) {
      theme.value = "0";
      await box.write('storageTheme', theme.value);
    } else {
      theme.value = storedTheme;
    }

    _applyTheme(theme.value);
  }

  void _applyTheme(String themeValue) {
    switch (themeValue) {
      case "0":
        appbarBottomNav.value = const Color(0xff123456);
        scaffoldBg.value = const Color(0xffE3EDF8);
        bgLight1.value = const Color(0xffEBF4FA);
        textDark.value = Colors.black;
        yellowPrimary.value = const Color(0xFFC9DFEC);
        greenPrimary.value = Colors.green;
        textLight.value = const Color(0xffFFFFFF);
        cardBtn.value = const Color(0xFFC9DFEC);
        iconColor.value = const Color(0xff123456);
        multipleRows.value = const Color(0xFFC9DFEC);
        break;
      case "1":
        appbarBottomNav.value = const Color(0xff252734);
        bgLight1.value = const Color(0xff333646);
        scaffoldBg.value = const Color(0xff333646);
        cardBtn.value = const Color(0xff424657);
        greenPrimary.value = const Color(0xffFFAF29);
        yellowPrimary.value = const Color(0xffFFAF29);
        textDark.value = const Color(0xffFFFFFF);
        textLight.value = const Color(0xffFFFFFF);
        iconColor.value = const Color(0xffFFAF29);
        multipleRows.value = const Color(0xff424657);
        break;
      default:
    }

    update();
  }

  void setTheme(String newTheme) async {
    theme.value = newTheme;
    await box.write('storageTheme', theme.value);
    _applyTheme(newTheme);
  }
}
