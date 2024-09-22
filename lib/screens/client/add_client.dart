import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../home_screen.dart';

class AddClient extends StatefulWidget {
  const AddClient({super.key});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  bool isLoading = false;
  final TextEditingController clientName = TextEditingController();
  final TextEditingController clientAddress = TextEditingController();
  final TextEditingController clientContact = TextEditingController();

  @override
  void dispose() {
    clientName.dispose();
    clientContact.dispose();
    clientAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
        });
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBg.value,
        appBar: AppBar(
          backgroundColor: theme.appbarBottomNav.value,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(FontAwesomeIcons.chevronLeft, color: theme.textLight.value),
          ),
          title: Text(
            "New Client",
            style: TextStyle(color: theme.textLight.value, fontSize: 16),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.userPen,
                    controller: clientName,
                    keyboardType: TextInputType.text,
                    label: 'Client Name',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.mobileScreen,
                    controller: clientContact,
                    keyboardType: TextInputType.phone,
                    label: 'Client Contact',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.addressBook,
                    controller: clientAddress,
                    keyboardType: TextInputType.text,
                    label: 'Client Address',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.sentences,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 20,
                ),
                Utils.customElevatedButton(
                    btnName: 'Add Client',
                    onPress: () async {
                      bool hasInternet = await internet.checkInternet();
                      if (!hasInternet) {
                        Utils.showSnackBar('Error', 'No Internet Connection.');
                        return;
                      }
                      setState(() {
                        isLoading == true;
                      });
                      if (clientName.text.isNotEmpty) {
                        if (clientAddress.text.isNotEmpty) {
                          if (clientContact.text.isNotEmpty) {

                            await Api.addClient(
                                clientName: clientName.text,
                                clientAddress: clientAddress.text,
                                clientContact: clientContact.text);
                            Get.to(const HomeScreen(
                              initialIndex: 1,
                            ));
                            setState(() {
                              isLoading == false;
                            });
                            Utils.showSnackBar('Successful',
                                'New client ${clientName.text} has been added');

                          } else {
                            setState(() {
                              isLoading == false;
                            });
                            Utils.showSnackBar(
                                'Error', 'Client Contact can not be empty');
                          }
                        } else {
                          setState(() {
                            isLoading == false;
                          });
                          Utils.showSnackBar(
                              'Error', 'Client Address can not be empty');
                        }
                      } else {
                        setState(() {
                          isLoading == false;
                        });
                        Utils.showSnackBar(
                            'Error', 'Client Name can not be empty');
                      }
                    },
                    bgColor: theme.appbarBottomNav.value,
                    textClr: theme.textLight.value)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
