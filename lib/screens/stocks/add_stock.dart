import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../home_screen.dart';

class AddStock extends StatefulWidget {
  const AddStock({super.key});

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final TextEditingController productName = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  final TextEditingController productQuantity = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    productName.dispose();
    productDescription.dispose();
    productQuantity.dispose();
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
            "New Product Listing ",
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
                    controller: productName,
                    keyboardType: TextInputType.text,
                    label: 'Product Name',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    controller: productDescription,
                    keyboardType: TextInputType.text,
                    label: 'Product Description',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.sentences,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    controller: productQuantity,
                    keyboardType: TextInputType.number,
                    label: 'Product Quantity',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 20,
                ),
                isLoading == true
                ?Utils.showProgressBar(context)
                :Utils.customElevatedButton(
                    btnName: 'Add Product',
                    onPress: () async {
                      bool hasInternet = await internet.checkInternet();
                      if (!hasInternet) {
                        Utils.showSnackBar('Error', 'No Internet Connection.');
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      if (productName.text.isNotEmpty) {
                        if (productQuantity.text.isNotEmpty) {
                          await Api.saveStockProduct(
                              productName: productName.text,
                              productDescription: productDescription.text,
                              productQuantity: productQuantity.text);
                          Get.to(const HomeScreen(
                            initialIndex: 2,
                          ));
                          setState(() {
                            isLoading = false;
                          });
                          Utils.showSnackBar('Successful',
                              'New Product ${productName.text} ${productQuantity.text} has been added in stock');
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          Utils.showSnackBar(
                              'Error', 'Product Quantity can not be empty');
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        Utils.showSnackBar(
                            'Error', 'Product Name can not be empty');
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
