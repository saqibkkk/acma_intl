import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'Controllers/theme_controller.dart';
import 'Models/client_model.dart';
import 'Models/employee_model.dart';
import 'Models/stock_model.dart';

class Utils {
  static String getCurrentDate() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    return formattedDate;
  }

  static String generate6DigitUID() {
    final random = Random();
    String uid = '';
    for (int i = 0; i < 6; i++) {
      uid += random.nextInt(10).toString();
    }
    return uid;
  }

  static String getCurrentMonthName() {
    final DateTime now = DateTime.now();
    final List<String> monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[now.month - 1];
  }

  static String getPreviousMonth(String currentMonth) {
    DateTime now = DateFormat("MMMM").parse(currentMonth);
    DateTime previousDate = DateTime(now.year, now.month - 1);
    return DateFormat('MMMM').format(previousDate);
  }

  static int getCurrentYear() {
    final DateTime now = DateTime.now();
    return now.year;
  }

  static void showSnackBar(String title, String msg) {
    final ThemeController theme = Get.find();
    Get.snackbar(
      title,
      msg,
      backgroundColor: title == 'Error'
          ? Colors.red.withOpacity(.5)
          : Colors.green.withOpacity(.5),
      colorText: theme.textDark.value,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 500),
      borderRadius: 20,
      margin: const EdgeInsets.all(10),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
    );
  }

  static Widget showProgressBar(BuildContext context) {
    final ThemeController theme = Get.find();
    return Center(
        child: CircularProgressIndicator(
      color: theme.iconColor.value,
    ));
  }

  static Widget customTextFormField(
      {required TextEditingController controller,
      required TextInputType keyboardType,
      required String label,
      required bool readOnly,
      required bool obscureText,
      required TextCapitalization capital,
      required Color textColor,
      required Color bgColor,
      IconData? icon,
      VoidCallback? onTap}) {
    final ThemeController theme = Get.find();
    return TextFormField(
      onTap: onTap,
      obscureText: obscureText,
      readOnly: readOnly,
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: theme.textDark.value,
      textCapitalization: capital,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.iconColor.value),
        filled: true,
        fillColor: bgColor,
        labelStyle: TextStyle(color: theme.textDark.value, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.textLight.value, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.textLight.value, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.iconColor.value, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  static Widget customElevatedButton(
      {required String btnName,
      required VoidCallback onPress,
      required Color bgColor,
      required Color textClr}) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        btnName,
        style: TextStyle(color: textClr),
      ),
    );
  }

  static Widget customListViewCard({
    required String name,
    required String designation,
    required String salary,
    required VoidCallback onPress,
    required Color color,
    required VoidCallback attendance,
    required String startingTime,
    required String endingTime,
    required bool isAttendanceMarked,
    required String date,
  }) {
    final ThemeController theme = Get.find();
    Color statusColor;
    if (isAttendanceMarked) {
      if (startingTime.isNotEmpty && endingTime.isEmpty) {
        statusColor = Colors.red;
      } else if (startingTime.isNotEmpty && endingTime.isNotEmpty) {
        statusColor = Colors.green;
      } else {
        statusColor = Colors.grey;
      }
    } else {
      statusColor = Colors.grey;
    }
    return Card(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Name: $name',
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.textDark.value,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: attendance,
                  child: Text(
                    'Mark Attendance',
                    style: TextStyle(
                        color: theme.greenPrimary.value,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: theme.iconColor.value,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Designation: $designation',
                        style: TextStyle(
                            fontSize: 14, color: theme.textDark.value),
                      ),
                    ),
                    Text(
                      'Date: $date',
                      style: TextStyle(
                          fontSize: 10,
                          color: theme.textDark.value,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Salary: $salary',
                        style: TextStyle(
                            fontSize: 14, color: theme.textDark.value),
                      ),
                    ),
                    InkWell(
                      onTap: onPress,
                      child: Text(
                        'View More',
                        style: TextStyle(
                            color: theme.greenPrimary.value,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ',
                      style:
                          TextStyle(fontSize: 14, color: theme.textDark.value),
                    ),
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Start: $startingTime',
                      style:
                          TextStyle(fontSize: 12, color: theme.textDark.value),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'End: $endingTime',
                      style:
                          TextStyle(fontSize: 12, color: theme.textDark.value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  static Future<void> customAlertBox(
      {StockModel? stock,
      EmployeeModel? employee,
      ClientModel? client,
      required BuildContext context,
      required String headingText,
      required String insideText,
      required VoidCallback onConfirmPress}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final ThemeController theme = Get.find();
        return Obx(
          () => AlertDialog(
            backgroundColor: theme.appbarBottomNav.value,
            title: Text(
              headingText,
              style: TextStyle(color: theme.textLight.value, fontSize: 16),
            ),
            content: Text(
              insideText,
              style: TextStyle(color: theme.textLight.value, fontSize: 12),
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
                onPressed: onConfirmPress,
                child: const Text('OK',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
