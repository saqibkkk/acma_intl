import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../API/realtime_crud.dart';
import '../Controllers/app_controller.dart';
import '../Controllers/theme_controller.dart';
import '../screens/auth_screens/local_auth.dart';
import '../screens/company/company_profile.dart';
import '../screens/employee/employee_details/all_employees.dart';
import '../screens/splash_screen.dart';
import '../screens/user/user_profile.dart';
import '../utils.dart';

class SidebarMenu extends StatefulWidget {
  final List<Map<String, dynamic>> companyDetails;

  const SidebarMenu({super.key, required this.companyDetails});

  @override
  SidebarMenuState createState() => SidebarMenuState();
}

class SidebarMenuState extends State<SidebarMenu> {
  int _selectedIndex = -1;
  late bool switchValue;
  final googleSignIn = GoogleSignIn();
  late GetStorage box;
  final String key = 'fingerprintEnabled';
  final AppController app = Get.find();

  @override
  void initState() {
    super.initState();
    box = GetStorage();
    switchValue = box.read(key) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sideMenuProfiles = [
      {
        'icon':  FontAwesomeIcons.industry,
        'text': 'Company Profile',
        'screen': () => CompanyProfile(companyDetails: widget.companyDetails),
      },
      {
        'icon': FontAwesomeIcons.circleUser,
        'text': 'User Profile',
        'screen': () => const UserProfile(),
      },
    ];

    List<Map<String, dynamic>> sideMenuRecent = [
      {
        'icon': FontAwesomeIcons.userGroup,
        'text': 'All Employee',
        'screen': () => const AllEmployees(),
      },
    ];

    return GetBuilder<ThemeController>(
      builder: (theme) {
        return Obx(
          () => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    companyName: widget.companyDetails.isNotEmpty
                        ? '${widget.companyDetails[0]['name']}'
                        : 'Loading',
                    userName: Api.user.displayName!.isNotEmpty
                        ? Api.user.displayName.toString()
                        : 'Loading',
                  ),
                  Divider(
                    color: theme.iconColor.value,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Profiles:',
                    style: TextStyle(
                        color: theme.textDark.value,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  for (int i = 0; i < sideMenuProfiles.length; i++)
                    Card(
                      color: theme.bgLight1.value,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _selectedIndex == i
                              ? theme.iconColor.value
                              : theme.cardBtn.value,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          sideMenuProfiles[i]['icon'],
                          color: theme.iconColor.value,
                        ),
                        title: Text(
                          sideMenuProfiles[i]['text'],
                          style: TextStyle(
                            color: theme.textDark.value,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = i;
                          });
                          Get.to(sideMenuProfiles[i]['screen']());
                        },
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: theme.iconColor.value,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Recent:',
                    style: TextStyle(
                        color: theme.textDark.value,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  for (int i = 0; i < sideMenuRecent.length; i++)
                    Card(
                      color: theme.bgLight1.value,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _selectedIndex == (sideMenuProfiles.length + i)
                              ? theme.iconColor.value
                              : theme.cardBtn.value,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          sideMenuRecent[i]['icon'],
                          color: theme.iconColor.value,
                        ),
                        title: Text(
                          sideMenuRecent[i]['text'],
                          style: TextStyle(
                            color: theme.textDark.value,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = sideMenuProfiles.length + i;
                          });
                          Get.to(sideMenuRecent[i]['screen']());
                        },
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: theme.iconColor.value,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            theme.theme.value == "1"
                                ? 'Dark mode'
                                : 'Light Mode',
                            style: TextStyle(
                                color: theme.textDark.value,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              theme.theme.value == '1'
                                  ? FaIcon(FontAwesomeIcons.moon,
                                      color: theme.iconColor.value)
                                  : FaIcon(FontAwesomeIcons.sun,
                                  color: theme.iconColor.value),
                              const SizedBox(
                                width: 10,
                              ),
                              Switch(
                                activeColor: const Color(0xff161D31),
                                activeTrackColor: Colors.grey,
                                inactiveThumbColor: const Color(0xff161D31),
                                inactiveTrackColor: Colors.grey,
                                value: theme.theme.value == "1",
                                onChanged: (bool value) {
                                  String newTheme = value ? "1" : "0";
                                  theme.setTheme(newTheme);
                                  box.write('theme', newTheme);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable Biometric',
                            style: TextStyle(
                                color: theme.textDark.value,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.fingerprint,
                                  color: theme.iconColor.value),
                              const SizedBox(
                                width: 10,
                              ),
                              Switch(
                                activeColor: const Color(0xff161D31),
                                activeTrackColor: Colors.grey,
                                inactiveThumbColor: const Color(0xff161D31),
                                inactiveTrackColor: Colors.grey,
                                value: switchValue,
                                onChanged: (bool value) {
                                  setState(() {
                                    switchValue = value;
                                    box.write(key, value);
                                    if (value) {
                                      LocalAuth.authenticate();
                                    } else {
                                      LocalAuth.cancelAuthentication();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Utils.customElevatedButton(
                              btnName: 'Log Out',
                              onPress: () async {
                                setState(() {
                                  switchValue = false;
                                  box.write(key, false);
                                });
                                Get.offAll(const SplashScreen());
                                await FirebaseAuth.instance.signOut();
                                await Api.auth.signOut();
                                await googleSignIn.signOut();
                              },
                              bgColor: theme.appbarBottomNav.value,
                              textClr: theme.textLight.value),
                          Text('App Version: ${app.currentVersion}', style: TextStyle(color: theme.textDark.value, fontSize: 12),)
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard(
      {super.key, required this.companyName, required this.userName});

  final String companyName, userName;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: ClipOval(
            child: Image.network(
              Api.user.photoURL.toString(),
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  CupertinoIcons.person,
                  color: Colors.white,
                  size: 24,
                );
              },
            ),
          ),
        ),
        title: Text(
          companyName,
          style: TextStyle(
              color: theme.textDark.value,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          userName,
          style: TextStyle(color: theme.textDark.value, fontSize: 14),
        ),
      );
    });
  }
}
