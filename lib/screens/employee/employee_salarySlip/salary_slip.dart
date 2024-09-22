import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_attendance_model.dart';
import '../../../Models/employee_contract_model.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';
import 'download_salary_slip.dart';
import 'generate_salary_slip.dart';

class SalarySlip extends StatefulWidget {
  final EmployeeModel employee;
  const SalarySlip({super.key, required this.employee});

  @override
  State<SalarySlip> createState() => _SalarySlipState();
}

class _SalarySlipState extends State<SalarySlip> {
  final ThemeController theme = Get.put(ThemeController());
  final InternetController internet = Get.find();
  List<EmployeeContractModel> employeeContractList = [];
  List<String> totalContractEarnings = [];
  bool isLoading = false;
  bool isSalarySlipVisible = false;
  List<EmployeeAttendanceModel> dailyReportList = [];
  final TextEditingController receivedController = TextEditingController();
  String pendingReceivable = '0';
  String totalContractEarning = '0';
  final ScreenshotController screenshotController = ScreenshotController();

  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  final List<String> years =
      List.generate(10, (index) => (DateTime.now().year - index).toString());

  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String selectedYear = DateTime.now().year.toString();

  Future<void> fetchMonthlyAttendance() async {
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
    dailyReportList = await Api.getAttendance(
        idCard: widget.employee.idCard,
        month: selectedMonth,
        year: selectedYear);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchPendingReceivable() async {
    setState(() {
      isLoading = true;
    });
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    String result = await Api.getPendingReceivable(
      idCard: widget.employee.idCard,
      year: selectedYear,
      month: selectedMonth,
    );
    setState(() {
      isLoading = true;
      pendingReceivable = result;
    });
  }

  Future<void> fetchEmployeeContract() async {
    setState(() {
      isLoading = true;
    });
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    employeeContractList = await Api.getAllContract(
      idCard: widget.employee.idCard,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchContractEarnings() async {
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      return;
    }
    totalContractEarnings.clear();
    for (var contract in employeeContractList) {
      String cUid = contract.cUid;
      String result = await Api.getContractTotalEarning(
        idCard: widget.employee.idCard,
        year: selectedYear,
        month: selectedMonth,
        cUid: cUid,
      );
      totalContractEarnings.add(result);
    }

    String totalEarnings = totalContractEarnings
        .map(double.parse)
        .reduce((a, b) => a + b)
        .toString();
    setState(() {
      totalContractEarning = totalEarnings;
    });
  }

  double getTotalWorkedHours() {
    double totalWorkedHours = 0.0;

    for (var report in dailyReportList) {
      String dailyHours = report.dailyHours;

      try {
        RegExp regExp = RegExp(r'(\d+\.?\d*)h (\d+\.?\d*)m');
        Match? match = regExp.firstMatch(dailyHours);

        if (match != null) {
          double hours = double.parse(match.group(1)!);
          double minutes = double.parse(match.group(2)!);

          totalWorkedHours += hours + (minutes / 60);
        }
      } catch (e) {}
    }

    return totalWorkedHours;
  }

  double calculatePayableSalary({
    required double monthlySalary,
    required double totalWorkedHours,
  }) {
    double perHourSalary = monthlySalary / calculateRequiredHours();
    double totalPayableSalary = perHourSalary * totalWorkedHours;
    return totalPayableSalary;
  }

  double calculateOverTimeSalary({
    required double monthlySalary,
    required double totalWorkedHours,
  }) {
    double overTimeHours = totalWorkedHours - calculateRequiredHours();
    double overTimeHoursInMonth = calculateOverTimeHours();
    double overTimePerHourRate = monthlySalary / overTimeHoursInMonth;
    double totalOverTimeSalary = overTimePerHourRate * overTimeHours;
    return totalOverTimeSalary;
  }

  double calculateRequiredHours() {
    double totalDays = 26;
    int perDayHours = 8;
    double requiredHours = totalDays * perDayHours;
    return requiredHours;
  }

  double calculateOverTimeHours() {
    double totalDays = 26;
    int perDayHours = 6;
    double requiredHours = totalDays * perDayHours;
    return requiredHours;
  }

  int calculateAbsents() {
    int totalDays = 26;
    int absents = totalDays - dailyReportList.length;
    return absents;
  }

  @override
  void initState() {
    super.initState();
    fetchMonthlyAttendance();
    fetchPendingReceivable();
    fetchEmployeeContract();
    fetchEmployeeContract().then((_) => fetchContractEarnings());
  }

  Future<void> addReceived(BuildContext context, EmployeeModel employee) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBg.value,
          title: Text(
            'Received',
            style: TextStyle(
                color: theme.textDark.value, fontWeight: FontWeight.w500),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Utils.customTextFormField(
                  icon: FontAwesomeIcons.creditCard,
                  controller: receivedController,
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
                style: TextStyle(color: Colors.red),
              ),
            ),
            Utils.customElevatedButton(
              btnName: 'Add',
              onPress: () async {
                bool hasInternet = await internet.checkInternet();
                if (!hasInternet) {
                  Utils.showSnackBar('Error', 'No Internet Connection.');
                  setState(() {
                    isLoading = false;
                  });
                  return;
                }
                if (receivedController.text.isNotEmpty) {
                  Get.back();
                  Utils.showSnackBar('Successful',
                      'Receiving of amount Rs. ${receivedController.text} has been added in salary slip');
                  setState(() {
                    isSalarySlipVisible = false;
                  });
                } else {
                  Utils.showSnackBar(
                      'Error', 'Received amount can no be empty');
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

  @override
  void dispose() {
    receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalWorkedHours = getTotalWorkedHours();
    String basicSalary = (totalWorkedHours < calculateRequiredHours())
        ? calculatePayableSalary(
            monthlySalary: widget.employee.salary,
            totalWorkedHours: totalWorkedHours,
          ).toStringAsFixed(2)
        : widget.employee.salary.toString();
    String overTimeSalary = (totalWorkedHours > calculateRequiredHours())
        ? calculateOverTimeSalary(
                monthlySalary: widget.employee.salary,
                totalWorkedHours: totalWorkedHours)
            .toStringAsFixed(2)
        : "0.0";
    double grossSalary = double.parse(basicSalary) +
        double.parse(overTimeSalary) +
        double.parse(totalContractEarning);
    String receivedText = receivedController.text;

    double receivedAmount = 0.0;
    if (receivedText.isNotEmpty) {
      try {
        receivedAmount = double.parse(receivedText);
      } catch (e) {
        receivedAmount = 0.0;
      }
    }
    double netSalary = grossSalary - receivedAmount;
    String absent = calculateAbsents().toString();
    String requiredHours = calculateRequiredHours().toString();
    String completedHours = getTotalWorkedHours().toStringAsFixed(2);

    return Scaffold(
      backgroundColor: theme.scaffoldBg.value,
      appBar: AppBar(
        backgroundColor: theme.appbarBottomNav.value,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon:
              Icon(FontAwesomeIcons.chevronLeft, color: theme.textLight.value),
        ),
        title: Text(
          "Salary Slip - ${widget.employee.name}",
          style: TextStyle(color: theme.textLight.value, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                        isSalarySlipVisible = false;
                        employeeContractList.clear();
                        dailyReportList.clear();
                        fetchMonthlyAttendance();
                        fetchEmployeeContract();
                        fetchPendingReceivable();
                        fetchEmployeeContract()
                            .then((_) => fetchContractEarnings());
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
                        isSalarySlipVisible = false;
                        employeeContractList.clear();
                        dailyReportList.clear();
                        fetchMonthlyAttendance();
                        fetchEmployeeContract();
                        fetchPendingReceivable();
                        fetchEmployeeContract()
                            .then((_) => fetchContractEarnings());
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pending Receivable:',
                        style: TextStyle(
                            color: theme.textDark.value, fontSize: 12),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Rs. $pendingReceivable',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                      onTap: () {
                        addReceived(context, widget.employee);
                      },
                      child: Text(
                        'Add Received',
                        style: TextStyle(
                            color: theme.greenPrimary.value, fontSize: 12),
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Utils.customElevatedButton(
                  btnName: 'Show Salary Slip',
                  onPress: () async{
                    bool hasInternet = await internet.checkInternet();
                    if (!hasInternet) {
                      Utils.showSnackBar('Error', 'No Internet Connection.');
                      setState(() {
                        isSalarySlipVisible = false;
                      });
                      return;
                    }
                    setState(() {
                      isSalarySlipVisible = true;
                    });
                  },
                  bgColor: theme.appbarBottomNav.value,
                  textClr: theme.textLight.value),
            ),
            if (isSalarySlipVisible)
              Column(
                children: [
                  Divider(
                    color: theme.iconColor.value,
                  ),
                  GenerateSalarySlip(
                    name:
                        '${widget.employee.name} ${widget.employee.fatherName}',
                    designation: widget.employee.designation,
                    uid: widget.employee.idCard,
                    joiningDate: widget.employee.joiningDate,
                    payMonth: selectedMonth,
                    payDate: Utils.getCurrentDate().toString(),
                    netSalary: netSalary.toStringAsFixed(2),
                    paidDays: dailyReportList.length.toString(),
                    absent: absent,
                    requiredHours: requiredHours,
                    completedHours: completedHours,
                    basicSalary: basicSalary,
                    overTimeSalary: overTimeSalary,
                    contractSalary: totalContractEarning,
                    grossSalary: grossSalary.toStringAsFixed(2),
                    receivable: receivedAmount.toStringAsFixed(2),
                    salary: widget.employee.salary.toString(),
                    textColor: theme.textDark.value,
                    textLight: theme.textLight.value,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Utils.customElevatedButton(
                      btnName: 'Generate PDF',
                      onPress: () async {

                        Get.to(DownloadSalarySlip(
                          employee: widget.employee,
                          selectedMonth: selectedMonth,
                          netSalary: netSalary,
                          dailyReportList: dailyReportList,
                          absent: absent,
                          requiredHours: requiredHours,
                          completedHours: completedHours,
                          basicSalary: basicSalary,
                          overTimeSalary: overTimeSalary,
                          totalContractEarning: totalContractEarning,
                          grossSalary: grossSalary,
                          receivedAmount: receivedAmount,
                          selectedYear: selectedYear,
                          currentDate: Utils.getCurrentDate().toString(),
                        ));
                      },
                      bgColor: theme.appbarBottomNav.value,
                      textClr: theme.textLight.value)
                ],
              ),
          ],
        ),
      ),
    );
  }
}
