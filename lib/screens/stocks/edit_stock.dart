import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../../Models/stock_model.dart';
import '../home_screen.dart';

class EditStock extends StatefulWidget {
  final StockModel stock;
  const EditStock({super.key, required this.stock});

  @override
  State<EditStock> createState() => _EditStockState();
}

class _EditStockState extends State<EditStock> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final TextEditingController productName = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    productName.text = widget.stock.productName;
    productDescription.text = widget.stock.productDescription;
    super.initState();
  }

  @override
  void dispose() {
    productName.dispose();
    productDescription.dispose();
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
            "Edit Stock - ${widget.stock.productName}",
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
                  height: 20,
                ),
                Utils.customElevatedButton(
                    btnName: 'Edit Product',
                    onPress: () async {
                      bool hasInternet = await internet.checkInternet();
                      if (!hasInternet) {
                        Utils.showSnackBar('Error', 'No Internet Connection.');
                        return;
                      }
                      if (productName.text.isNotEmpty) {
                        if (productDescription.text.isNotEmpty) {
                          await Api.editStock(
                              productName: productName.text,
                              productDescription: productDescription.text,
                              productId: widget.stock.productId);
                          Get.off(const HomeScreen(
                            initialIndex: 2,
                          ));
                          Utils.showSnackBar('Successful',
                              'Stock ${widget.stock.productName} has been edited to ${productName.text}');
                        } else {
                          Utils.showSnackBar(
                              'Error', 'Product Description can not be empty');
                        }
                      } else {
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
