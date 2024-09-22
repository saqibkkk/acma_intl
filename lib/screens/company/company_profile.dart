import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../API/realtime_crud.dart';
import '../../Controllers/internet.dart';
import '../../Controllers/theme_controller.dart';
import '../../utils.dart';

class CompanyProfile extends StatefulWidget {
  final List<Map<String, dynamic>> companyDetails;
  const CompanyProfile({super.key, required this.companyDetails});

  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  bool isLoading = false;
  bool isVerified = false;
  @override
  Widget build(BuildContext context) {
    final ThemeController theme = Get.find();
    final InternetController internet = Get.find();
    final TextEditingController companyOldPassword = TextEditingController();
    final TextEditingController companyNewPassword = TextEditingController();
    final TextEditingController companyConfirmNewPassword =
        TextEditingController();
    final TextEditingController companyName = TextEditingController(
        text: widget.companyDetails[0]['name'].toString());
    final TextEditingController companyNtn =
        TextEditingController(text: widget.companyDetails[0]['ntn'].toString());

    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
        });
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBg.value,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.textLight.value,
                ),
              ),
              Text('Company Profile',
                  style: TextStyle(color: theme.textLight.value, fontSize: 16)),
            ],
          ),
          backgroundColor: theme.appbarBottomNav.value,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Utils.customTextFormField(
                      icon: FontAwesomeIcons.industry,
                      controller: companyName,
                      keyboardType: TextInputType.none,
                      label: 'Company Name',
                      readOnly: true,
                      obscureText: false,
                      capital: TextCapitalization.none,
                      textColor: theme.textDark.value,
                      bgColor: theme.scaffoldBg.value),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    icon: FontAwesomeIcons.buildingColumns,
                    controller: companyNtn,
                    readOnly: true,
                    keyboardType: TextInputType.none,
                    label: 'Company NTN',
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.scaffoldBg.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    icon: FontAwesomeIcons.lockOpen,
                    controller: companyOldPassword,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    label: 'Old Password',
                    readOnly: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    icon: FontAwesomeIcons.lock,
                    controller: companyNewPassword,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    label: 'New Password',
                    readOnly: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    icon: FontAwesomeIcons.lock,
                    controller: companyConfirmNewPassword,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    label: 'Confirm New Password',
                    readOnly: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* Password must contain minimum 8 characters.'
                      '\n* Password must contain one uppercase letter.'
                      '\n* Password must contain one special character.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  isLoading == true
                  ?Utils.showProgressBar(context)
                  :Utils.customElevatedButton(
                      btnName: 'Change Password',
                      onPress: () async {
                        bool hasInternet = await internet.checkInternet();
                        if (!hasInternet) {
                          Utils.showSnackBar('Error', 'No Internet Connection.');
                          return;
                        }
                        setState(() {
                          isLoading = true;
                        });
                        if (companyOldPassword.text.isEmpty &&
                            companyNewPassword.text.isEmpty &&
                            companyConfirmNewPassword.text.isEmpty) {
                          Utils.showSnackBar(
                              'Error', 'Old and New Password are required.');
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }
                        final isVerifiedDetails =
                            await Api.changeCompanyPassword(
                                pass: companyOldPassword.text);
                        setState(() {
                          isLoading = false;
                          isVerified = isVerifiedDetails;
                        });
                        if (!isValidPassword(companyNewPassword.text)) {
                          Utils.showSnackBar('Error',
                              'Password must be at least 8 characters long, contain at least one uppercase letter, and one special character.');
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }
                        if (isVerified == true) {
                          if (companyNewPassword.text ==
                              companyConfirmNewPassword.text) {
                            if (companyOldPassword.text ==
                                companyConfirmNewPassword.text) {
                              setState(() {
                                isLoading = false;
                              });
                              Utils.showSnackBar('Error',
                                  'Old and New passwords can not be same');
                            } else {
                              await Api.updateCompanyPassword(
                                  password: companyNewPassword.text);
                              Utils.showSnackBar('Successful',
                                  'Password has changed successfully!');
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } else {
                            Utils.showSnackBar('Error',
                                'New password and Confirm new password are not same');
                            setState(() {
                              isLoading = false;
                            });
                          }
                        } else {
                          Utils.showSnackBar(
                              'Error', 'Old Password is not Correct');
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      bgColor: theme.appbarBottomNav.value,
                      textClr: theme.textLight.value)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isValidPassword(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }
}
