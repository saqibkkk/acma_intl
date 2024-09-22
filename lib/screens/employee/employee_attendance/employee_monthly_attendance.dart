import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_attendance_model.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';

class EmployeeMonthlyAttendance extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeMonthlyAttendance({super.key, required this.employee});

  @override
  EmployeeMonthlyAttendanceState createState() =>
      EmployeeMonthlyAttendanceState();
}

class EmployeeMonthlyAttendanceState extends State<EmployeeMonthlyAttendance> {
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();
  final TextEditingController date = TextEditingController();
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<EmployeeAttendanceModel> dailyReportList = [];
  List<EmployeeAttendanceModel> reversedDailyReportList = [];
  String? selectedOption;
  double totalSalary = 0.0;
  double totalHoursWorked = 0.0;
  bool isLoading = false;
  List<bool> editRemoveBtn = [];
  String previousMonth = Utils.getPreviousMonth(Utils.getCurrentMonthName());

  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> years = List.generate(DateTime.now().year - 1999,
      (index) => (DateTime.now().year - index).toString());
  String selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    fetchMonthlyAttendance();
    super.initState();
  }

  @override
  void dispose() {
    startTime.dispose();
    endTime.dispose();
    date.dispose();
    super.dispose();
  }

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

    dailyReportList.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.currentDate);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.currentDate);
      return dateB.compareTo(dateA);
    });
    reversedDailyReportList = dailyReportList;

    setState(() {
      isLoading = false;
      editRemoveBtn = List<bool>.filled(reversedDailyReportList.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < editRemoveBtn.length; i++) {
            editRemoveBtn[i] = false;
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
                  "Attendance - ${widget.employee.name}",
                  style: TextStyle(color: theme.textLight.value, fontSize: 16),
                ),
                const Spacer(),
                for (int i = 0; i < editRemoveBtn.length; i++)
                  editRemoveBtn[i]
                      ? Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _editAttendance(
                                  startingTime:
                                      reversedDailyReportList[i].startTime,
                                  endingTime:
                                      reversedDailyReportList[i].endTime,
                                  employee: widget.employee,
                                  currentDate:
                                      reversedDailyReportList[i].currentDate,
                                );
                              },
                              child: const Icon(
                                FontAwesomeIcons.pencil,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: () {
                                Utils.customAlertBox(
                                    context: context,
                                    headingText: 'Warning',
                                    insideText:
                                        'Attendance of ${reversedDailyReportList[i].currentDate} will be deleted',
                                    onConfirmPress: () async {
                                      bool hasInternet =
                                          await internet.checkInternet();
                                      if (!hasInternet) {
                                        Utils.showSnackBar(
                                            'Error', 'No Internet Connection.');
                                        return;
                                      }
                                      await Api.removeEmployeeAttendance(
                                        idCard: widget.employee.idCard,
                                        month: selectedMonth,
                                        year: selectedYear,
                                        date: reversedDailyReportList[i]
                                            .currentDate,
                                      );
                                      startTime.clear();
                                      endTime.clear();
                                      Get.back();
                                      Utils.showSnackBar('Successful',
                                          'Attendance of ${reversedDailyReportList[i].currentDate} has been deleted');
                                      dailyReportList.clear();
                                      await fetchMonthlyAttendance();
                                    });
                              },
                              child: const Icon(
                                FontAwesomeIcons.trash,
                                color: Colors.red,
                              ),
                            )
                          ],
                        )
                      : const SizedBox.shrink()
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                            reversedDailyReportList.clear();
                            fetchMonthlyAttendance();
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
                            reversedDailyReportList.clear();
                            fetchMonthlyAttendance();
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
                const Text(
                  'Note*:\n'
                  'Attendance of current month or previous month is editable only.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(
                  height: 10,
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
                          child: Text('Start Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textDark.value,
                                  fontSize: 12)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('End Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textDark.value,
                                  fontSize: 12)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Daily Hours',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textDark.value,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                isLoading == true
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Utils.showProgressBar(context),
                      )
                    : reversedDailyReportList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: reversedDailyReportList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onLongPress: () {
                                  bool isCurrentOrPreviousMonth =
                                      (selectedMonth ==
                                              Utils.getCurrentMonthName()) ||
                                          (selectedMonth == previousMonth);

                                  if (isCurrentOrPreviousMonth) {
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
                                  } else {
                                    Utils.showSnackBar('Error',
                                        'attendance for month $selectedMonth $selectedYear is not editable r deletable');
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  color: editRemoveBtn[index]
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
                                            reversedDailyReportList[index]
                                                .currentDate,
                                            style: TextStyle(
                                                color: editRemoveBtn[index]
                                                    ? theme.textLight.value
                                                    : theme.textDark.value,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              reversedDailyReportList[index]
                                                  .startTime,
                                              style: TextStyle(
                                                  color: editRemoveBtn[index]
                                                      ? theme.textLight.value
                                                      : theme.textDark.value,
                                                  fontSize: 12)),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              reversedDailyReportList[index]
                                                  .endTime,
                                              style: TextStyle(
                                                  color: editRemoveBtn[index]
                                                      ? theme.textLight.value
                                                      : theme.textDark.value,
                                                  fontSize: 12)),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              reversedDailyReportList[index]
                                                  .dailyHours,
                                              style: TextStyle(
                                                  color: editRemoveBtn[index]
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
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              'No Attendance record found for $selectedMonth $selectedYear',
                              style: TextStyle(
                                  color: theme.textDark.value,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
              ],
            ),
          )),
    );
  }

  void _editAttendance({
    required String startingTime,
    required String endingTime,
    required String currentDate,
    required EmployeeModel employee,
  }) async {
    startTime.text = startingTime;
    endTime.text = endingTime;
    date.text = currentDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            backgroundColor: theme.appbarBottomNav.value,
            title: Text(
              'Edit Attendance',
              style: TextStyle(color: theme.textLight.value, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15),
                    child: TextFormField(
                      controller: date,
                      readOnly: true,
                      cursorColor: Colors.green,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'Current Date',
                        labelStyle: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.textLight.value,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.textLight.value,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                    )),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15),
                          child: TextFormField(
                            controller: startTime,
                            keyboardType: TextInputType.none,
                            onTap: () {
                              _selectTime(context, startTime);
                            },
                            style: TextStyle(
                                color: theme.textLight.value, fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              labelStyle: TextStyle(
                                color: theme.textLight.value,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: theme.textLight.value,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: theme.textLight.value,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                  color: theme.textLight.value,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15),
                        child: TextFormField(
                          keyboardType: TextInputType.none,
                          controller: endTime,
                          onTap: () {
                            _selectTime(context, endTime);
                          },
                          style: TextStyle(
                              color: theme.textLight.value, fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            labelStyle: TextStyle(
                              color: theme.textLight.value,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: theme.textLight.value,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: theme.textLight.value,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: theme.textLight.value,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: const Text('OK',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
                onPressed: () async {
                  bool hasInternet = await internet.checkInternet();
                  if (!hasInternet) {
                    Utils.showSnackBar('Error', 'No Internet Connection.');
                    return;
                  }
                  if (startTime.text.isNotEmpty && endTime.text.isNotEmpty) {
                    String totalHours =
                        calculateTotalHours(startTime.text, endTime.text);
                    if (totalHours == '0' ||
                        totalHours
                            .contains('End time must be after start time.')) {
                      Utils.showSnackBar(
                          'Error', 'End time must be after the start time.');
                    } else {
                      await Api.editEmployeeAttendance(
                        idCard: employee.idCard,
                        startTime: startTime.text,
                        endTime: endTime.text,
                        dailyHours: totalHours,
                        month: selectedMonth,
                        year: selectedYear,
                        date: date.text,
                      );
                      Get.back();
                      Utils.showSnackBar('Successful',
                          'Attendance of ${date.text} has been updated Successfully.');
                    }

                    setState(() {
                      for (int i = 0; i < editRemoveBtn.length; i++) {
                        editRemoveBtn[i] = false;
                      }
                      reversedDailyReportList.clear();
                      fetchMonthlyAttendance();
                    });
                  } else {
                    Utils.showSnackBar(
                        'Error', 'Start time and End Time are required');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String calculateTotalHours(String start, String end) {
    final DateFormat dateFormat = DateFormat("h:mm a");

    try {
      start = start.trim();
      end = end.trim();
      final DateTime startDateTime = dateFormat.parse(start);
      final DateTime endDateTime = dateFormat.parse(end);
      if (endDateTime.isBefore(startDateTime)) {
        return 'End time must be after start time.';
      }

      final Duration difference = endDateTime.difference(startDateTime);
      final int hours = difference.inHours;
      final int minutes = difference.inMinutes.remainder(60);

      return '${hours}h ${minutes}m';
    } catch (e) {
      return '0';
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }
}
