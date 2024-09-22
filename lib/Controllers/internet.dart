import 'dart:io';
import 'package:get/get.dart';

class InternetController extends GetxController {
  RxBool internet = false.obs;

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      // If lookup is successful, return true (Google is accessible) and set the observable.
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        internet.value = true;
        return true;
      }
    } on SocketException catch (_) {
      // If an exception occurs, return false (Google is inaccessible) and set the observable.
      internet.value = false;
      return false;
    }

    // Default return false in case of any unexpected scenario.
    return false;
  }
}
