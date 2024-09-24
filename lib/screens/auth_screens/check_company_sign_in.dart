import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../API/realtime_crud.dart';
import '../../Controllers/internet.dart';
import '../../Controllers/theme_controller.dart';
import '../../utils.dart';
import '../home_screen.dart';

class CheckNtnPass extends StatefulWidget {
  const CheckNtnPass({super.key});

  @override
  State<CheckNtnPass> createState() => _CheckNtnPassState();
}

class _CheckNtnPassState extends State<CheckNtnPass> {
  final ntnController = TextEditingController();
  final passController = TextEditingController();
  final InternetController internet = Get.find();
  final ThemeController theme = Get.find();
  bool isVerified = false;
  bool isLoading = false;
  bool isVisible = true;

  @override
  void dispose() {
    ntnController.dispose();
    passController.dispose();
    super.dispose();
  }

  _handleGoogleBtnClick(BuildContext context) async {
    if (isVerified) {
      UserCredential? user = await _signInWithGoogle();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (user != null) {
        if (!mounted) return;

        if (await Api.userExists()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          await Api.createUser();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        Utils.showSnackBar('Error', 'Google sign-in failed. Please try again.');
      }
    } else {
      Utils.showSnackBar('Error', 'Please verify your company details first.');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      bool hasInternet = await internet.checkInternet();
      if (!hasInternet) {
        Utils.showSnackBar('Error', 'Not Internet Connection');
        ntnController.clear();
        passController.clear();
        return null;
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await Api.auth.signInWithCredential(credential);
    } catch (e) {
      Utils.showSnackBar('Error', "An unknown error occurred  ${e.toString()}");
      print('An unknown error occurred  ${e.toString()}');
      return null;
    }
  }

  _verifyDetails() async {
    String ntn = ntnController.text.trim();
    String pass = passController.text.trim();

    setState(() {
      isLoading = true;
    });

    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'Not Internet Connection');
      ntnController.clear();
      passController.clear();
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (ntn.isEmpty || pass.isEmpty) {
      Utils.showSnackBar('Error', 'NTN and Password cannot be empty.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final isVerifiedDetails = await Api.checkNtn(ntn: ntn, pass: pass);

    setState(() {
      isLoading = false;
      isVerified = isVerifiedDetails;
    });
    if (isVerified == true) {
      Utils.showSnackBar('Successful', 'Details Verified! You can sign In now');
      ntnController.clear();
      passController.clear();
    } else {
      Utils.showSnackBar('Error', 'Wrong Credentials!');
      ntnController.clear();
      passController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white60,
          body: Stack(
            children: [
              Opacity(
                  opacity: .1,
                  child: Center(child: Image.asset('assets/acmaLogo.png'))),
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 100),
                            Column(
                              children: [
                                TextFormField(
                                  onTap: () {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  controller: ntnController,
                                  cursorColor: Colors.black87,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'NTN',
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  onTap: () {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  controller: passController,
                                  cursorColor: Colors.black87,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isVisible = !isVisible;
                                        });
                                      },
                                      icon: isVisible
                                          ? const Icon(
                                              CupertinoIcons.eye_slash,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              CupertinoIcons.eye,
                                              color: Colors.red,
                                            ),
                                    ),
                                    labelText: 'Password',
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.black87,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: isVisible,
                                ),
                                const SizedBox(height: 20),
                                isVerified
                                    ? const Text(
                                        'Details are verified',
                                        style: TextStyle(
                                            color: Colors.greenAccent),
                                      )
                                    : const Text(
                                        'Please Verify Company detail before Signing In',
                                        style: TextStyle(color: Colors.red)),
                                const SizedBox(height: 20),
                                isLoading == false
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              const Color(0xff123456),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 30),
                                          side: BorderSide(
                                              color: theme.cardBtn.value),
                                        ),
                                        onPressed: () async {
                                          await _verifyDetails();
                                        },
                                        child: const Text(
                                          'Verify Details',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Utils.showProgressBar(context),
                                const SizedBox(height: 20),
                                isVerified == true
                                    ?
                                ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 30),
                                          side: const BorderSide(
                                            color: Color(0xff123456),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await _handleGoogleBtnClick(context);
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.google,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Sign in with Google',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ))
                                    : Material(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(30),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: null,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 30),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.google,
                                                  color: Colors.blueGrey,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Sign in with Google',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
