import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../API/realtime_crud.dart';
import '../../Controllers/internet.dart';
import '../../Models/client_model.dart';

class GenerateClientBill extends StatefulWidget {
  final ClientModel client;
  const GenerateClientBill({super.key, required this.client});

  @override
  State<GenerateClientBill> createState() => _GenerateClientBillState();
}

class _GenerateClientBillState extends State<GenerateClientBill> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  int numberOfProducts = 1;
  List<TextEditingController> productNameControllers = [];
  List<TextEditingController> productDescriptionControllers = [];
  List<TextEditingController> productQuantityControllers = [];
  List<TextEditingController> pricePerProductControllers = [];

  List<double> perItemTotal = [];
  double billTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers(numberOfProducts);
  }

  void _initializeControllers(int count) {
    productNameControllers = List.generate(
        count,
        (i) => productNameControllers.length > i
            ? productNameControllers[i]
            : TextEditingController());
    productDescriptionControllers = List.generate(
        count,
        (i) => productDescriptionControllers.length > i
            ? productDescriptionControllers[i]
            : TextEditingController());
    productQuantityControllers = List.generate(
        count,
        (i) => productQuantityControllers.length > i
            ? productQuantityControllers[i]
            : TextEditingController());
    pricePerProductControllers = List.generate(
        count,
        (i) => pricePerProductControllers.length > i
            ? pricePerProductControllers[i]
            : TextEditingController());
  }

  void _calculateBillTotal() {
    perItemTotal.clear();
    for (int i = 0; i < numberOfProducts; i++) {
      double quantity =
          double.tryParse(productQuantityControllers[i].text) ?? 0;
      double price = double.tryParse(pricePerProductControllers[i].text) ?? 0;
      double total = quantity * price;
      perItemTotal.add(total);
    }
    setState(() {
      billTotal = perItemTotal.fold(0, (sum, element) => sum + element);
    });
  }

  @override
  void dispose() {
    for (var controller in productNameControllers) {
      controller.dispose();
    }
    for (var controller in productDescriptionControllers) {
      controller.dispose();
    }
    for (var controller in productQuantityControllers) {
      controller.dispose();
    }
    for (var controller in pricePerProductControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _extractControllerText(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text).toList();
  }

  List<String> _generateSerialNumbers(int count) {
    return List.generate(count, (index) => (index + 1).toString());
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
            "Generate Bill",
            style: TextStyle(color: theme.textLight.value, fontSize: 16),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Please select number of products for billing',
                        style: TextStyle(
                            color: theme.textDark.value, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DropdownButton<int>(
                      value: numberOfProducts,
                      items: List.generate(10, (index) {
                        int number = index + 1;
                        return DropdownMenuItem(
                          value: number,
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textDark.value,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            numberOfProducts = newValue;
                            _initializeControllers(numberOfProducts);
                          });
                        }
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.textDark.value,
                      ),
                      dropdownColor: theme.cardBtn.value,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: theme.iconColor.value,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: numberOfProducts,
                    itemBuilder: (context, i) {
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Utils.customTextFormField(
                              controller: productNameControllers[i],
                              keyboardType: TextInputType.text,
                              label: 'Product Name ${i + 1}',
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value,
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.words),
                          const SizedBox(height: 10),
                          Utils.customTextFormField(
                              controller: productDescriptionControllers[i],
                              keyboardType: TextInputType.text,
                              label: 'Product Description ${i + 1}',
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value,
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.sentences),
                          const SizedBox(height: 10),
                          Utils.customTextFormField(
                              controller: productQuantityControllers[i],
                              keyboardType: TextInputType.number,
                              label: 'Product Quantity ${i + 1}',
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value,
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.none),
                          const SizedBox(height: 10),
                          Utils.customTextFormField(
                              controller: pricePerProductControllers[i],
                              keyboardType: TextInputType.number,
                              label: 'Per Item Price ${i + 1}',
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value,
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.none),
                          const SizedBox(height: 10),
                          Divider(
                            color: theme.iconColor.value,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Utils.customElevatedButton(
                  btnName: 'Generate Bill',
                  onPress: () async {
                    bool hasInternet = await internet.checkInternet();
                    if (!hasInternet) {
                      Utils.showSnackBar('Error', 'No Internet Connection.');
                      return;
                    }
                    if (_extractControllerText(productNameControllers)
                        .any((name) => name.isEmpty)) {
                      Utils.showSnackBar(
                          'Error', 'All product names are required');
                    } else {
                      if (_extractControllerText(productQuantityControllers)
                          .any((name) => name.isEmpty)) {
                        Utils.showSnackBar(
                            'Error', 'All product quantities are required');
                      } else {
                        if (_extractControllerText(pricePerProductControllers)
                            .any((name) => name.isEmpty)) {
                          Utils.showSnackBar(
                              'Error', 'All product prices are required');
                        } else {
                          _calculateBillTotal();
                          List<String> serialNumbers =
                              _generateSerialNumbers(numberOfProducts);
                          await Api.generateBill(
                            clientName: widget.client.name,
                            clientAddress: widget.client.address,
                            clientContact: widget.client.phone,
                            clientId: widget.client.clientId,
                            serialNumber: serialNumbers,
                            productName:
                                _extractControllerText(productNameControllers),
                            productDescription: _extractControllerText(
                                productDescriptionControllers),
                            productQuantity: _extractControllerText(
                                productQuantityControllers),
                            perItemPrice: _extractControllerText(
                                pricePerProductControllers),
                            perItemTotal: perItemTotal
                                .map((total) => total.toString())
                                .toList(),
                            billTotal: billTotal.toString(),
                          );
                          Get.back();
                          Utils.showSnackBar('Successful',
                              'Bill has been generated successfully');
                        }
                      }
                    }
                  },
                  bgColor: theme.appbarBottomNav.value,
                  textClr: theme.textLight.value,
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
