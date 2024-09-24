import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../API/realtime_crud.dart';
import '../../Controllers/theme_controller.dart';
import '../../Models/user_model.dart';
import '../../utils.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({
    super.key,
  });

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final ThemeController theme = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBg.value,
      appBar: AppBar(
        backgroundColor: theme.appbarBottomNav.value,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: theme.textLight.value),
        ),
        title: Text(
          "User Profile",
          style: TextStyle(color: theme.textLight.value, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: Api.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Utils.showProgressBar(context);
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('No Data Available!'),
              );
            } else {
              UserModel user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.height * .2,
                          width: MediaQuery.of(context).size.width * .4,
                          fit: BoxFit.cover,
                          imageUrl: user.photo,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(
                            CupertinoIcons.person,
                            size: 50,
                          )),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Utils.customTextFormField(
                        controller: TextEditingController(text: user.name),
                        keyboardType: TextInputType.none,
                        label: 'Name:',
                        readOnly: true,
                        obscureText: false,
                        capital: TextCapitalization.none,
                        textColor: theme.textDark.value,
                        bgColor: theme.cardBtn.value,
                        icon: FontAwesomeIcons.circleUser),
                    const SizedBox(
                      height: 20,
                    ),
                    Utils.customTextFormField(
                        controller: TextEditingController(text: user.email),
                        keyboardType: TextInputType.none,
                        label: 'E-mail:',
                        readOnly: true,
                        obscureText: false,
                        capital: TextCapitalization.none,
                        textColor: theme.textDark.value,
                        bgColor: theme.cardBtn.value,
                        icon: FontAwesomeIcons.envelope),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
