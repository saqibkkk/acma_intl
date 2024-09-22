import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../../Models/client_model.dart';
import '../home_screen.dart';

class EditClient extends StatefulWidget {
  final ClientModel client;
  const EditClient({super.key, required this.client});

  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final TextEditingController clientName = TextEditingController();
  final TextEditingController clientAddress = TextEditingController();
  final TextEditingController clientContact = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    clientName.text = widget.client.name;
    clientAddress.text = widget.client.address;
    clientContact.text = widget.client.phone;
    super.initState();
  }

  @override
  void dispose() {
    clientName.dispose();
    clientAddress.dispose();
    clientContact.dispose();
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
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: theme.textLight.value),
          ),
          title: Text(
            "Edit Client - ${widget.client.name}",
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
                    btnName: 'Edit Client',
                    onPress: () async {
                      bool hasInternet = await internet.checkInternet();
                      if (!hasInternet) {
                        Utils.showSnackBar('Error', 'No Internet Connection.');
                        return;
                      }
                      if (clientName.text.isNotEmpty) {
                        if (clientAddress.text.isNotEmpty) {
                          if (clientContact.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            await Api.editClient(
                                clientName: clientName.text,
                                clientAddress: clientAddress.text,
                                clientContact: clientContact.text,
                                clientId: widget.client.clientId);
                            Get.to(const HomeScreen(
                              initialIndex: 1,
                            ));
                            Utils.showSnackBar('Successful',
                                'Client ${clientName.text} has been edited');
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            Utils.showSnackBar(
                                'Error', 'Client Contact can not be empty');
                          }
                        } else {
                          Utils.showSnackBar(
                              'Error', 'Client Address can not be empty');
                        }
                      } else {
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
