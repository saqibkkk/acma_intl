import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_contractEarning_model.dart';
import '../../../Models/employee_contract_model.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';

class ContractDetails extends StatefulWidget {
  final EmployeeModel employee;
  final EmployeeContractModel employeeContract;

  const ContractDetails(
      {super.key, required this.employee, required this.employeeContract});

  @override
  State<ContractDetails> createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<EmployeeContractEarningModel> employeeContractEarningList = [];
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noOfItems = TextEditingController();
  bool isLoading = false;
  double totalNoOfItems = 0.0;
  double totalEarning = 0.0;
  double singleEntryEarning = 0.0;
  List<bool> removeBtn = [];

  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> years = List.generate(DateTime.now().year - 1999,
      (index) => (DateTime.now().year - index).toString());
  String selectedYear = DateTime.now().year.toString();

  Future<void> fetchEmployeeContractEarning() async {
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
    employeeContractEarningList = await Api.getContractEarning(
        idCard: widget.employee.idCard,
        cUid: widget.employeeContract.cUid,
        month: selectedMonth,
        year: selectedYear);

    employeeContractEarningList.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
      DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
      return dateB.compareTo(dateA);
    });
    calculateTotals();

    setState(() {
      isLoading = false;
      removeBtn = List<bool>.filled(employeeContractEarningList.length, false);
    });
  }

  void calculateTotals() {
    totalNoOfItems = employeeContractEarningList.fold(
      0.0,
      (previousValue, element) =>
          previousValue + double.parse(element.noOfItems),
    );
    double perItemRate =
        double.tryParse(widget.employeeContract.contractPerItemRate) ?? 0.0;
    totalEarning = totalNoOfItems * perItemRate;
    setState(() {});
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
      dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  Future<void> addContractEarning(BuildContext context, EmployeeModel employee,
      {required String cUid}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text(
            'Contract Entry',
            style: TextStyle(color: theme.textDark.value),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  icon: Icons.calendar_month_outlined,
                  controller: dateController,
                  keyboardType: TextInputType.datetime,
                  label: 'Date',
                  readOnly: true,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value),
              const SizedBox(
                height: 10,
              ),
              Utils.customTextFormField(
                  icon: Icons.numbers,
                  controller: noOfItems,
                  keyboardType: TextInputType.number,
                  label: 'No. of Items',
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
                style: TextStyle(color: Colors.red),
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
                  if (dateController.text.isNotEmpty) {
                    if (noOfItems.text.isNotEmpty) {
                      await Api.addContractEarning(
                          idCard: employee.idCard,
                          noOfItems: noOfItems.text,
                          date: dateController.text,
                          cUid: cUid,
                          year: selectedYear,
                          month: selectedMonth);
                      employeeContractEarningList.clear();
                      await fetchEmployeeContractEarning();

                      await Api.addTotalContractEarning(
                          idCard: employee.idCard,
                          cUid: cUid,
                          totalEarning: totalEarning.toStringAsFixed(2),
                          year: selectedYear,
                          month: selectedMonth);
                      Get.back();
                      Utils.showSnackBar('Successful',
                          'Contract entry of ${noOfItems.text} items has been added');
                      noOfItems.clear();
                      dateController.clear();
                    } else {
                      Utils.showSnackBar(
                          'Error', 'No. of Items can not be empty');
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
  void initState() {
    fetchEmployeeContractEarning();
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    noOfItems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: theme.textLight.value),
          ),
          title: Row(
            children: [
              Text(
                "Details - ${widget.employeeContract.contractName}",
                style: TextStyle(color: theme.textLight.value, fontSize: 16),
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
                                  'Entry of ${employeeContractEarningList[i].noOfItems} will be deleted.',
                              onConfirmPress: () async {
                                bool hasInternet = await internet.checkInternet();
                                if (!hasInternet) {
                                  Utils.showSnackBar('Error', 'No Internet Connection.');
                                  return;
                                }
                                await Api.deleteContractEarning(
                                    idCard: widget.employee.idCard,
                                    cUid: widget.employeeContract.cUid,
                                    year: selectedYear,
                                    month: selectedMonth,
                                    date: employeeContractEarningList[i].date,
                                    eUid: employeeContractEarningList[i].eUid);
                                Get.back();
                                Utils.showSnackBar('Successful',
                                    'Entry of ${employeeContractEarningList[i].noOfItems} has been be deleted.');
                                employeeContractEarningList.clear();
                                await fetchEmployeeContractEarning();
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
        body: SafeArea(
          child: Column(
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
                          employeeContractEarningList.clear();
                          fetchEmployeeContractEarning();
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
                          employeeContractEarningList.clear();
                          fetchEmployeeContractEarning();
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total No. of Items: $totalNoOfItems',
                          style: TextStyle(
                              color: theme.textDark.value,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text('Total Earning: $totalEarning',
                            style: TextStyle(
                                color: theme.textDark.value,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ],
                    ),
                    InkWell(
                        onTap: () {
                          addContractEarning(context, widget.employee,
                              cUid: widget.employeeContract.cUid);
                        },
                        child: Text(
                          'New Entry',
                          style: TextStyle(
                              color: theme.greenPrimary.value, fontSize: 12),
                        ))
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
                        child: Text('No. Of Items',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textDark.value,
                                fontSize: 12)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Earning',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textDark.value,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: Utils.showProgressBar(context))
                    : employeeContractEarningList.isEmpty
                        ? Center(
                            child: Text(
                              "No contract details available for $selectedMonth $selectedYear",
                              style: TextStyle(
                                  color: theme.textDark.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: employeeContractEarningList.length,
                            itemBuilder: (context, index) {
                              EmployeeContractEarningModel earning =
                                  employeeContractEarningList[index];
                              double perItemEarning =
                                  double.parse(earning.noOfItems) *
                                      double.parse(widget
                                          .employeeContract.contractPerItemRate);
                              return InkWell(
                                onLongPress: () {
                                  setState(() {
                                    for (int i = 0; i < removeBtn.length; i++) {
                                      if (i != index) {
                                        removeBtn[i] = false;
                                      }
                                    }
                                    removeBtn[index] = !removeBtn[index];
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                            earning.date,
                                            style: TextStyle(
                                                color: removeBtn[index]
                                                    ? theme.textLight.value
                                                    : theme.textDark.value,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(earning.noOfItems,
                                              style: TextStyle(
                                                  color: removeBtn[index]
                                                      ? theme.textLight.value
                                                      : theme.textDark.value,
                                                  fontSize: 12)),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(perItemEarning.toString(),
                                              style: TextStyle(
                                                  color: removeBtn[index]
                                                      ? theme.textLight.value
                                                      : theme.textDark.value,
                                                  fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
