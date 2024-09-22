import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/git_token.dart';
import '../utils.dart';

class AppController extends GetxController {
  RxString oldVersion = ''.obs;
  RxString currentVersion = ''.obs;
  RxString newAppUrl = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await _initPackageInfo();
    await checkLatestUpdate();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion.value = packageInfo.version;
  }

  Future<void> checkLatestUpdate() async {
    const repoOwner = 'saqibkkk';
    const repoName = 'acma_intl';
    final response = await http.get(
      Uri.parse("https://api.github.com/repos/$repoOwner/$repoName/releases"),
      headers: {
        'Authorization': 'token $personalAccessToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latestRelease = data.first;
        final tagName = latestRelease['tag_name'];
        oldVersion.value = tagName;
        final assets = latestRelease['assets'] as List<dynamic>;

        for (final asset in assets) {
          final assetDownloadUrl = asset['browser_download_url'];
          newAppUrl.value = assetDownloadUrl;
        }
      } else {}
    } else {
      Utils.showSnackBar('Error', 'Error getting update');
    }
  }

  Future<void> downloadNewVersion() async {
    if (await launchUrl(Uri.parse(newAppUrl.value),
        mode: LaunchMode.externalApplication)) {
      currentVersion.value = oldVersion.value;
      Get.back();
    } else {
      Get.snackbar('Error', 'Failed to launch the download link.');
    }
  }
}
