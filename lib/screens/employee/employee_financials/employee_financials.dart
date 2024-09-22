import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_bill_model.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';

class EmployeeFinancials extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeFinancials({super.key, required this.employee});

  @override
  EmployeeFinancialsState createState() => EmployeeFinancialsState();
}

class EmployeeFinancialsState extends State<EmployeeFinancials> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<EmployeeFinancialsModel> employeeFinancialList = [];
  final TextEditingController _dateController = TextEditingController();
  bool isLoading = false;
  List<bool> removeBtn = [];
  String? selectedOption;
  double totalReceivable = 0.0;
  double totalReceived = 0.0;
  double pendingAmount = 0.0;

  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> years = List.generate(DateTime.now().year - 1999,
      (index) => (DateTime.now().year - index).toString());
  String selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    fetchEmployeeFinancials();
    super.initState();
  }

  Future<void> fetchEmployeeFinancials() async {
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
    employeeFinancialList = await Api.getFinancials(
      idCard: widget.employee.idCard,
      year: selectedYear,
      month: selectedMonth,
    );
    employeeFinancialList.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
      DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
      return dateB.compareTo(dateA);
    });
    calculateTotals();

    setState(() {
      isLoading = false;
      removeBtn = List<bool>.filled(employeeFinancialList.length, false);
    });
  }

  void calculateTotals() {
    totalReceivable = employeeFinancialList.fold(0.0, (sum, financial) {
      return sum + (double.tryParse(financial.receivable) ?? 0.0);
    });

    totalReceived = employeeFinancialList.fold(0.0, (sum, financial) {
      return sum + (double.tryParse(financial.receivedAmount) ?? 0.0);
    });

    pendingAmount = (totalReceivable - totalReceived);
  }

  Future<void> _selectDate(BuildContext context) async {
    Map<String, int> monthMapping = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    int year = int.parse(selectedYear);
    int month = monthMapping[selectedMonth]!;

    DateTime firstDate = DateTime(year, month, 1);
    DateTime lastDate = DateTime(year, month + 1, 0);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  Future<void> addReceived(BuildContext context, EmployeeModel employee) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController statusController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text(
            'Received',
            style: TextStyle(
                color: theme.textDark.value,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  icon: FontAwesomeIcons.calendarDay,
                  controller: _dateController,
                  keyboardType: TextInputType.datetime,
                  label: 'Select Date',
                  readOnly: true,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
              const SizedBox(
                height: 10,
              ),
              Utils.customTextFormField(
                  icon: FontAwesomeIcons.font,
                  controller: statusController,
                  keyboardType: TextInputType.text,
                  label: 'Description',
                  readOnly: false,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
              const SizedBox(
                height: 10,
              ),
              Utils.customTextFormField(
                  icon: FontAwesomeIcons.creditCard,
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  label: 'Amount',
                  readOnly: false,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
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
                if (_dateController.text.isNotEmpty) {
                  if (amountController.text.isNotEmpty) {
                    await Api.addReceived(
                      idCard: employee.idCard,
                      date: _dateController.text,
                      amount: amountController.text,
                      status: statusController.text,
                    );
                    employeeFinancialList.clear();
                    await fetchEmployeeFinancials();
                    await Api.addPendingReceivable(
                      idCard: widget.employee.idCard,
                      pendingReceivable: pendingAmount.toStringAsFixed(2),
                      month: selectedMonth,
                      year: selectedYear,
                    );
                    Get.back();
                    Utils.showSnackBar(
                      'Successful',
                      'Receiving of amount Rs. ${amountController.text} has been added',
                    );
                    _dateController.clear();
                    amountController.clear();
                    statusController.clear();
                  } else {
                    Utils.showSnackBar('Error', 'Amount can not be empty');
                  }
                } else {
                  Utils.showSnackBar('Error', 'Date can not be empty');
                }
              },
              bgColor: theme.appbarBottomNav.value,
              textClr: Colors.green,
            )
          ],
        );
      },
    );
  }

  Future<void> addReceivable(
      BuildContext context, EmployeeModel employee) async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text('Receivable',
              style: TextStyle(
                  color: theme.textDark.value,
                  fontWeight: FontWeight.w500,
                  fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  icon: FontAwesomeIcons.calendarDay,
                  controller: _dateController,
                  keyboardType: TextInputType.datetime,
                  label: 'Select Date',
                  readOnly: true,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
              const SizedBox(
                height: 10,
              ),
              Utils.customTextFormField(
                  icon: FontAwesomeIcons.font,
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  label: 'Description',
                  readOnly: false,
                  obscureText: false,
                  capital: TextCapitalization.words,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
              const SizedBox(
                height: 10,
              ),
              Utils.customTextFormField(
                  icon: FontAwesomeIcons.creditCard,
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  label: 'Amount',
                  readOnly: false,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
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
                  if (_dateController.text.isNotEmpty) {
                    if (amountController.text.isNotEmpty) {
                      await Api.addReceivable(
                          idCard: employee.idCard,
                          date: _dateController.text,
                          description: descriptionController.text,
                          amount: amountController.text);

                      employeeFinancialList.clear();
                      await fetchEmployeeFinancials();

                      await Api.addPendingReceivable(
                          idCard: employee.idCard,
                          pendingReceivable: pendingAmount.toStringAsFixed(2),
                          month: selectedMonth,
                          year: selectedYear);
                      Get.back();
                      Utils.showSnackBar('Successful',
                          'Receivable of amount Rs. ${amountController.text} has been added');
                      _dateController.clear();
                      descriptionController.clear();
                      amountController.clear();
                    } else {
                      Utils.showSnackBar('Error', 'Amount can not be empty');
                    }
                  } else {
                    Utils.showSnackBar('Error', 'Date can not be empty');
                  }
                },
                bgColor: theme.appbarBottomNav.value,
                textClr: Colors.green),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return Obx(() => GestureDetector(
            onTap: () {
              setState(() {
                for (int i = 0; i < removeBtn.length; i++) {
                  removeBtn[i] = false;
                }
              });
            },
            child: Scaffold(
              backgroundColor: theme.scaffoldBg.value,
              appBar: AppBar(
                backgroundColor: theme.appbarBottomNav.value,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(FontAwesomeIcons.chevronLeft,
                      color: theme.textLight.value),
                ),
                title: Row(
                  children: [
                    Text(
                      "Financials - ${widget.employee.name}",
                      style:
                          TextStyle(color: theme.textLight.value, fontSize: 16),
                    ),
                    const Spacer(),
                    for (int i = 0; i < removeBtn.length; i++)
                      removeBtn[i]
                          ? InkWell(
                              onTap: () async {
                                Utils.customAlertBox(
                                    employee: widget.employee,
                                    context: context,
                                    headingText: 'Warning',
                                    insideText:
                                        'Financial entry for date ${employeeFinancialList[i].date} will be deleted!',
                                    onConfirmPress: () async {
                                      bool hasInternet =
                                          await internet.checkInternet();
                                      if (!hasInternet) {
                                        Utils.showSnackBar(
                                            'Error', 'No Internet Connection.');
                                        return;
                                      }
                                      await Api.deleteFinancials(
                                          idCard: widget.employee.idCard,
                                          year: selectedYear,
                                          month: selectedMonth,
                                          date: employeeFinancialList[i].date,
                                          id: employeeFinancialList[i].fUid);
                                      Get.back();
                                      employeeFinancialList.clear();
                                      await fetchEmployeeFinancials();
                                      Utils.showSnackBar('Successful',
                                          'Financial Entry for the ${employeeFinancialList[i].date} has been deleted');
                                      setState(() {
                                        for (int i = 0;
                                            i < removeBtn.length;
                                            i++) {
                                          removeBtn[i] = false;
                                        }
                                      });
                                    });
                              },
                              child: const Icon(
                                FontAwesomeIcons.trash,
                                color: Colors.red,
                              ),
                            )
                          : const SizedBox.shrink()
                  ],
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: selectedMonth,
                          items: months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(
                                month,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textDark.value,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                              employeeFinancialList.clear();
                              fetchEmployeeFinancials();
                            });
                          },
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.textDark.value,
                          ),
                          dropdownColor: theme.cardBtn.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textDark.value,
                            fontWeight: FontWeight.bold,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        DropdownButton<String>(
                          value: selectedYear,
                          items: years.map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(
                                year,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textDark.value,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue!;
                              employeeFinancialList.clear();
                              fetchEmployeeFinancials();
                            });
                          },
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.textDark.value,
                          ),
                          dropdownColor: theme.cardBtn.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textDark.value,
                            fontWeight: FontWeight.bold,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: theme.iconColor.value,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Receivable: $totalReceivable',
                              style: TextStyle(
                                  color: theme.textDark.value,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
                            ),
                            Text('Total Received: $totalReceived',
                                style: TextStyle(
                                    color: theme.textDark.value,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12)),
                            Text('Pending: $pendingAmount',
                                style: TextStyle(
                                    color: theme.textDark.value,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: selectedOption,
                          hint: Text(selectedOption ?? 'ADD',
                              style: TextStyle(
                                  color: theme.textDark.value, fontSize: 12)),
                          items: ['Receivable', 'Received'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style:
                                      TextStyle(color: theme.textDark.value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOption = newValue;
                            });

                            if (newValue == 'Receivable') {
                              addReceivable(context, widget.employee);
                            } else if (newValue == 'Received') {
                              addReceived(context, widget.employee);
                            }
                          },
                          dropdownColor: theme.cardBtn.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textDark.value,
                            fontWeight: FontWeight.bold,
                          ),
                          icon: Icon(Icons.arrow_drop_down,
                              color: theme.textDark.value),
                          underline: const SizedBox(),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    color: theme.yellowPrimary.value,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('Date',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textDark.value,
                                    fontSize: 12)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('Receivable',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textDark.value,
                                    fontSize: 12)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('Received',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textDark.value,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Utils.showProgressBar(context),
                          )
                        : employeeFinancialList.isNotEmpty
                            ? ListView.builder(
                                itemCount: employeeFinancialList.length,
                                itemBuilder: (context, index) {
                                  final financial =
                                      employeeFinancialList[index];
                                  return InkWell(
                                    onLongPress: () {
                                      setState(() {
                                        for (int i = 0;
                                            i < removeBtn.length;
                                            i++) {
                                          if (i != index) {
                                            removeBtn[i] = false;
                                          }
                                        }
                                        removeBtn[index] = !removeBtn[index];
                                      });
                                    },
                                    onTap: () {
                                      _showAlertDialog(
                                        context: context,
                                        details: financial.receivableDescription
                                                .isNotEmpty
                                            ? financial.receivableDescription
                                            : financial
                                                    .receivedStatus.isNotEmpty
                                                ? financial.receivedStatus
                                                : 'No Details available for this entry',
                                        heading: financial.receivableDescription
                                                .isNotEmpty
                                            ? 'Receivable'
                                            : 'Received',
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      color: removeBtn[index]
                                          ? theme.iconColor.value
                                          : index % 2 == 0
                                              ? Colors.transparent
                                              : theme.multipleRows.value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                financial.date,
                                                style: TextStyle(
                                                    color: removeBtn[index]
                                                        ? theme.textLight.value
                                                        : theme.textDark.value,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(financial.receivable,
                                                  style: TextStyle(
                                                      color: removeBtn[index]
                                                          ? theme
                                                              .textLight.value
                                                          : theme
                                                              .textDark.value,
                                                      fontSize: 12)),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                  financial.receivedAmount,
                                                  style: TextStyle(
                                                      color: removeBtn[index]
                                                          ? theme
                                                              .textLight.value
                                                          : theme
                                                              .textDark.value,
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No Financial Record found for ${widget.employee.name} for $selectedMonth $selectedYear.',
                                  style: TextStyle(
                                      color: theme.textDark.value,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ));
    });
  }

  void _showAlertDialog({
    required BuildContext context,
    required String details,
    required String heading,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.appbarBottomNav.value,
          title: Text(
            '$heading Details',
            style: TextStyle(color: theme.textLight.value),
          ),
          content: Text(
            details,
            style: TextStyle(color: theme.textLight.value),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }
}
