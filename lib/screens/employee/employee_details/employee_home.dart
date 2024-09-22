import 'package:firebase_database/firebase_database.dart';
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
import '../employee_attendance/employee_monthly_attendance.dart';
import 'add_employee.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  EmployeeHomeState createState() => EmployeeHomeState();
}

class EmployeeHomeState extends State<EmployeeHome> {
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = false;
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final TextEditingController startTime = TextEditingController();
  final TextEditingController endTime = TextEditingController();
  final TextEditingController currentDate =
      TextEditingController(text: Utils.getCurrentDate());
  final TextEditingController _searchController = TextEditingController();
  static DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchEmployeesData();
    _searchController.addListener(_filterEmployees);
  }

  void _fetchEmployeesData() async {
    setState(() {
      _isLoading = true;
    });
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'No Internet Connection.');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    List<EmployeeModel> employees = await Api.getEmployees();
    setState(() {
      _isLoading = false;
      _employees = employees;
      _filteredEmployees = employees;
    });
  }

  void _filterEmployees() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        return employee.name.toLowerCase().contains(query);
      }).toList();
    });
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

  @override
  void dispose() {
    _searchController.dispose();
    startTime.dispose();
    endTime.dispose();
    currentDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
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
                Get.to(const AddEmployee());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add Employee',
                  style: TextStyle(color: theme.textLight.value),
                ),
              ),
            ),
          ),
          body: _isLoading
              ? Center(child: Utils.showProgressBar(context))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 15, right: 15, bottom: 10),
                      child: Utils.customTextFormField(
                        onTap: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                          });
                        },
                        icon: FontAwesomeIcons.magnifyingGlass,
                        controller: _searchController,
                        keyboardType: TextInputType.text,
                        label: 'Search By Name...',
                        readOnly: false,
                        obscureText: false,
                        capital: TextCapitalization.words,
                        textColor: theme.textDark.value,
                        bgColor: theme.cardBtn.value,
                      ),
                    ),
                    Expanded(
                      child: _filteredEmployees.isEmpty
                          ? Center(
                              child: Text(
                              'No employees found!',
                              style: TextStyle(
                                color: theme.textDark.value,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  top: 10, left: 15, right: 15, bottom: 80),
                              itemCount: _filteredEmployees.length,
                              itemBuilder: (context, index) {
                                EmployeeModel employee =
                                    _filteredEmployees[index];
                                return StreamBuilder<DatabaseEvent>(
                                  stream: dbRef
                                      .child('DailyReports')
                                      .child(employee.idCard)
                                      .child('Attendance')
                                      .child('${Utils.getCurrentYear()}')
                                      .child(Utils.getCurrentMonthName())
                                      .child(Utils.getCurrentDate())
                                      .onValue,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data!.snapshot.exists) {
                                        Map<Object?, Object?> data = snapshot
                                            .data!
                                            .snapshot
                                            .value as Map<Object?, Object?>;
                                        EmployeeAttendanceModel attendance =
                                            EmployeeAttendanceModel.fromJson(
                                                Map<String, String>.from(data));
                                        return Utils.customListViewCard(
                                          name: employee.name,
                                          salary: employee.salary
                                              .toStringAsFixed(2),
                                          color: theme.cardBtn.value,
                                          attendance: () async {
                                            _markAttendance(
                                                startingTime:
                                                    startTime.text.isNotEmpty
                                                        ? startTime
                                                        : TextEditingController(
                                                            text: attendance
                                                                .startTime
                                                                .toString()),
                                                endingTime: endTime
                                                        .text.isNotEmpty
                                                    ? endTime
                                                    : TextEditingController(
                                                        text: attendance.endTime
                                                            .toString()),
                                                currentDate:
                                                    currentDate.text.isNotEmpty
                                                        ? currentDate
                                                        : TextEditingController(
                                                            text: attendance
                                                                .currentDate
                                                                .toString()),
                                                employee: employee);
                                          },
                                          startingTime: attendance.startTime,
                                          endingTime: attendance.endTime,
                                          isAttendanceMarked: true,
                                          date: Utils.getCurrentDate(),
                                          designation: employee.designation,
                                          onPress: () {
                                            Get.to(EmployeeMonthlyAttendance(
                                              employee: employee,
                                            ));
                                          },
                                        );
                                      } else {
                                        return Utils.customListViewCard(
                                          name: employee.name,
                                          salary: employee.salary
                                              .toStringAsFixed(2),
                                          color: theme.cardBtn.value,
                                          attendance: () async {
                                            _markAttendance(
                                                startingTime: startTime
                                                        .text.isNotEmpty
                                                    ? startTime
                                                    : TextEditingController(),
                                                endingTime: endTime
                                                        .text.isNotEmpty
                                                    ? endTime
                                                    : TextEditingController(),
                                                currentDate: currentDate
                                                        .text.isNotEmpty
                                                    ? currentDate
                                                    : TextEditingController(),
                                                employee: employee);
                                          },
                                          startingTime: '',
                                          endingTime: '',
                                          isAttendanceMarked: false,
                                          date: Utils.getCurrentDate(),
                                          designation: employee.designation,
                                          onPress: () async {
                                            Get.to(EmployeeMonthlyAttendance(
                                              employee: employee,
                                            ));
                                          },
                                        );
                                      }
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return const Center();
                                    }
                                  },
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

  void _markAttendance({
    required TextEditingController startingTime,
    required TextEditingController endingTime,
    required TextEditingController currentDate,
    required EmployeeModel employee,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            backgroundColor: theme.appbarBottomNav.value,
            title: Text(
              'Mark Attendance',
              style: TextStyle(color: theme.textLight.value, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  child: TextFormField(
                    controller: currentDate,
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
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15),
                        child: TextFormField(
                          controller: startingTime,
                          keyboardType: TextInputType.none,
                          onTap: () {
                            _selectTime(context, startingTime);
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
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15),
                        child: TextFormField(
                          keyboardType: TextInputType.none,
                          controller: endingTime,
                          onTap: () {
                            _selectTime(context, endingTime);
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

                  if (startingTime.text.isNotEmpty && endingTime.text.isEmpty) {
                    await Api.addEmployeeAttendance(
                      idCard: employee.idCard,
                      startTime: startingTime.text,
                      endTime: endingTime.text,
                      currentDate: currentDate.text,
                    );
                    Get.back();
                    Utils.showSnackBar('Successful',
                        'Attendance start time (${startingTime.text}) for employee ${employee.name} has been added');
                  } else if (startingTime.text.isNotEmpty &&
                      endingTime.text.isNotEmpty) {
                    String totalHours =
                        calculateTotalHours(startingTime.text, endingTime.text);
                    if (totalHours == '0' ||
                        totalHours
                            .contains('End time must be after start time.')) {
                      Utils.showSnackBar(
                          'Error', 'End time must be after the start time');

                    } else {
                      await Api.addEmployeeAttendance(
                        idCard: employee.idCard,
                        startTime: startingTime.text,
                        endTime: endingTime.text,
                        currentDate: currentDate.text,
                        dailyHours: totalHours,
                      );
                      Get.back();
                      Utils.showSnackBar('Successful',
                          'Attendance start time (${startingTime.text}) and end time (${endingTime.text}) for employee ${employee.name} has been added');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
