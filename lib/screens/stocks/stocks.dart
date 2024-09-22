import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../../Models/stock_model.dart';
import 'add_stock.dart';
import 'edit_stock.dart';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

class _StocksState extends State<Stocks> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  String? selectedOption;
  List<StockModel> stockList = [];
  List<StockModel> filteredStockList = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<bool> editRemoveBtn = [];

  Future<void> _fetchStockData() async {
    setState(() {
      isLoading = true;
    });
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'No Internet Connection.');
      setState(() {
        isLoading = false;
      });
      return;
    }
    stockList = await Api.getAllStock();
    setState(() {
      isLoading = false;
      filteredStockList = stockList;
      editRemoveBtn = List<bool>.filled(stockList.length, false);
    });
  }

  void _filterEmployees() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredStockList = stockList
          .where((product) => product.productName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void initState() {
    _fetchStockData();
    _searchController.addListener(_filterEmployees);
    super.initState();
  }

  @override
  void dispose() {
    _fetchStockData();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> addQuantity(BuildContext context, StockModel stock) async {
    final TextEditingController addQuantityController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text(
            'Add Stock',
            style: TextStyle(
              color: theme.textDark.value,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                icon: FontAwesomeIcons.plus,
                controller: addQuantityController,
                keyboardType: TextInputType.number,
                label: 'Quantity',
                readOnly: false,
                obscureText: false,
                capital: TextCapitalization.none,
                textColor: theme.textDark.value,
                bgColor: theme.cardBtn.value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Utils.customElevatedButton(
              btnName: 'Add',
              onPress: () async {
                bool hasInternet = await internet.checkInternet();
                if (!hasInternet) {
                  Utils.showSnackBar('Error', 'No Internet Connection.');
                  return;
                }
                int currentQuantity = int.tryParse(stock.productQuantity) ?? 0;
                int enteredQuantity =
                    int.tryParse(addQuantityController.text) ?? 0;
                int updatedQuantity = currentQuantity + enteredQuantity;
                String updatedStockQuantity = updatedQuantity.toString();
                await Api.updateStockQuantity(
                    productQuantity: updatedStockQuantity,
                    productId: stock.productId);
                Get.back();
                Utils.showSnackBar('Successful',
                    'Product quantity for ${stock.productName} has been updated to $updatedStockQuantity');
                stockList.clear();
                await _fetchStockData();
              },
              bgColor: theme.appbarBottomNav.value,
              textClr: Colors.green,
            )
          ],
        );
      },
    );
  }

  Future<void> subtractQuantity(BuildContext context, StockModel stock) async {
    final TextEditingController subtractQuantityController =
        TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text(
            'Subtract Quantity',
            style: TextStyle(
              color: theme.textDark.value,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                icon: FontAwesomeIcons.minus,
                controller: subtractQuantityController,
                keyboardType: TextInputType.number,
                label: 'Quantity',
                readOnly: false,
                obscureText: false,
                capital: TextCapitalization.none,
                textColor: theme.textDark.value,
                bgColor: theme.cardBtn.value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Utils.customElevatedButton(
              btnName: 'Subtract',
              onPress: () async {
                bool hasInternet = await internet.checkInternet();
                if (!hasInternet) {
                  Utils.showSnackBar('Error', 'No Internet Connection.');
                  return;
                }
                int currentQuantity = int.tryParse(stock.productQuantity) ?? 0;
                int enteredQuantity =
                    int.tryParse(subtractQuantityController.text) ?? 0;
                int updatedQuantity = (currentQuantity - enteredQuantity)
                    .clamp(0, currentQuantity);
                String updatedStockQuantity = updatedQuantity.toString();
                Api.updateStockQuantity(
                    productQuantity: updatedStockQuantity,
                    productId: stock.productId);
                Get.back();
                Utils.showSnackBar('Successful',
                    'Product quantity for ${stock.productName} has been updated to $updatedStockQuantity');
                stockList.clear();
                await _fetchStockData();
              },
              bgColor: theme.appbarBottomNav.value,
              textClr: Colors.green,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
            for (int i = 0; i < editRemoveBtn.length; i++) {
              editRemoveBtn[i] = false;
            }
          });
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBg.value,
          floatingActionButton: SizedBox(
            height: 50,
            width: 120,
            child: FloatingActionButton(
              backgroundColor: theme.iconColor.value,
              onPressed: () {
                Get.to(const AddStock());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add Product',
                  style: TextStyle(color: theme.textLight.value),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(child: Utils.showProgressBar(context))
              : SafeArea(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Utils.customTextFormField(
                              onTap: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                });
                              },
                              icon: FontAwesomeIcons.magnifyingGlass,
                              controller: _searchController,
                              keyboardType: TextInputType.text,
                              label: 'Search by Product Name...',
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.words,
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value)),
                      Expanded(
                        child: filteredStockList.isEmpty
                            ? Center(
                                child: Text(
                                "No Products available!",
                                style: TextStyle(
                                    color: theme.textDark.value,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                              ))
                            : ListView.builder(
                                itemCount: filteredStockList.length,
                                padding: const EdgeInsets.only(bottom: 70),
                                itemBuilder: (context, index) {
                                  StockModel stocks = filteredStockList[index];
                                  return InkWell(
                                    onTap: () {},
                                    onLongPress: () {
                                      setState(() {
                                        for (int i = 0;
                                            i < editRemoveBtn.length;
                                            i++) {
                                          if (i != index) {
                                            editRemoveBtn[i] = false;
                                          }
                                        }
                                        editRemoveBtn[index] =
                                            !editRemoveBtn[index];
                                      });
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      color: theme.cardBtn.value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    stocks.productName,
                                                    style: TextStyle(
                                                        color: theme
                                                            .textDark.value,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                DropdownButton<String>(
                                                  value: selectedOption,
                                                  hint: Text(
                                                      selectedOption ??
                                                          'Update Stock',
                                                      style: TextStyle(
                                                          color: theme
                                                              .textDark.value,
                                                          fontSize: 12)),
                                                  items: [
                                                    'Add Stock',
                                                    'Subtract Stock'
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value,
                                                          style: TextStyle(
                                                              color: theme
                                                                  .textDark
                                                                  .value)),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      selectedOption = newValue;
                                                    });

                                                    if (newValue ==
                                                        'Add Stock') {
                                                      addQuantity(
                                                          context, stocks);
                                                    } else if (newValue ==
                                                        'Subtract Stock') {
                                                      subtractQuantity(
                                                          context, stocks);
                                                    }
                                                  },
                                                  dropdownColor:
                                                      theme.cardBtn.value,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: theme.textDark.value,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      color:
                                                          theme.textDark.value),
                                                  underline: const SizedBox(),
                                                )
                                              ],
                                            ),
                                            Divider(
                                              color: theme.iconColor.value,
                                            ),
                                            Text(
                                              'Description: ${stocks.productDescription}',
                                              style: TextStyle(
                                                color: theme.textDark.value,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Available Quantity: ${stocks.productQuantity}',
                                                    style: TextStyle(
                                                      color:
                                                          theme.textDark.value,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                editRemoveBtn[index]
                                                    ? Row(
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                Get.to(EditStock(
                                                                    stock:
                                                                        stocks));
                                                              },
                                                              child: const Icon(
                                                                FontAwesomeIcons
                                                                    .pencil,
                                                                color: Colors
                                                                    .green,
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Utils
                                                                  .customAlertBox(
                                                                      stock:
                                                                          stocks,
                                                                      context:
                                                                          context,
                                                                      headingText:
                                                                          'Warning',
                                                                      insideText:
                                                                          'Your product ${stocks.productName} will be deleted',
                                                                      onConfirmPress:
                                                                          () async {
                                                                        bool
                                                                            hasInternet =
                                                                            await internet.checkInternet();
                                                                        if (!hasInternet) {
                                                                          Utils.showSnackBar(
                                                                              'Error',
                                                                              'No Internet Connection.');
                                                                          return;
                                                                        }
                                                                        await Api.deleteStock(
                                                                            productId:
                                                                                stocks.productId);
                                                                        Get.back();
                                                                        Utils.showSnackBar(
                                                                            'Successful',
                                                                            'Your product ${stocks.productName} has been deleted');
                                                                        stockList
                                                                            .clear();
                                                                        await _fetchStockData();
                                                                      });
                                                            },
                                                            child: const Icon(
                                                              FontAwesomeIcons
                                                                  .trash,
                                                              color: Colors.red,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
