import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_model.dart';
import 'package:http/http.dart' as http;
import '../../../utils.dart';

class EmployeePayroll extends StatefulWidget {
  final EmployeeModel employee;
  const EmployeePayroll({super.key, required this.employee});

  @override
  State<EmployeePayroll> createState() => _EmployeePayrollState();
}

class _EmployeePayrollState extends State<EmployeePayroll> {
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String selectedYear = DateTime.now().year.toString();
  String? salarySlipUrl;
  bool isLoading = false;
  final InternetController internet = Get.find();

  @override
  void initState() {
    super.initState();
    fetchSalarySlips();
  }

  Future<void> fetchSalarySlips() async {
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
    salarySlipUrl = await Api.getSalarySlip(
      idCard: widget.employee.idCard,
      year: selectedYear,
      month: selectedMonth,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> savePdfToDownloads(
      Uint8List pdfData, String employeeName) async {
    if (await _requestStoragePermission()) {
      try {
        final downloadsDirectory = Directory(
            '/storage/emulated/0/Download/ACMA INTL/Salary Slips/$employeeName-${widget.employee.idCard}');
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }

        final filePath =
            '${downloadsDirectory.path}/SalarySlip $selectedMonth $selectedYear.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfData);
        // Utils.showSnackBar('Success', "PDF saved successfully at: $filePath");
      } catch (e) {
        Utils.showSnackBar('Error', "Error writing file: $e");
      }
    } else {
      Utils.showSnackBar('Error', "Storage permission not granted.");
    }
  }

  Future<bool> _requestStoragePermission() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var result = await Permission.manageExternalStorage.request();
      return result.isGranted;
    } else {
      var status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = Get.find();

    final List<String> months = List.generate(
        12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
    final List<String> years =
        List.generate(10, (index) => (DateTime.now().year - index).toString());

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
        actions: [
          if (salarySlipUrl != null && salarySlipUrl != '0')
            IconButton(
              icon: Icon(FontAwesomeIcons.download,
                  color: theme.greenPrimary.value),
              onPressed: () async {
                bool hasInternet = await internet.checkInternet();
                if (!hasInternet) {
                  Utils.showSnackBar('Error', 'No Internet Connection.');
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                if (salarySlipUrl != null) {
                  try {
                    final response = await http.get(Uri.parse(salarySlipUrl!));
                    if (response.statusCode == 200) {
                      final pdf = pw.Document();
                      final image = pw.MemoryImage(response.bodyBytes);
                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) {
                            return pw.Center(
                              child: pw.Image(image),
                            );
                          },
                        ),
                      );
                      Uint8List pdfData = await pdf.save();
                      await savePdfToDownloads(pdfData, widget.employee.name);
                      Utils.showSnackBar(
                          'Successful', "PDF downloaded successfully.");
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      Utils.showSnackBar(
                          'Error', "Failed to load the salary slip image.");
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    Utils.showSnackBar('Error',
                        "An error occurred while downloading the PDF.");
                  }
                }
              },
            ),
        ],
      ),
      body: Column(
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
                          fontSize: 16.0,
                          color: theme.textDark.value,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMonth = newValue!;
                    });
                    fetchSalarySlips();
                  },
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.textDark.value,
                  ),
                  dropdownColor: theme.cardBtn.value,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: theme.textDark.value,
                    fontWeight: FontWeight.bold,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                DropdownButton<String>(
                  value: selectedYear,
                  items: years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(
                        year,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: theme.textDark.value,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                    fetchSalarySlips();
                  },
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.textDark.value,
                  ),
                  dropdownColor: theme.cardBtn.value,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: theme.textDark.value,
                    fontWeight: FontWeight.bold,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(child: Utils.showProgressBar(context))
          else if (salarySlipUrl != null && salarySlipUrl != '0')
            Expanded(
              child: Image.network(
                salarySlipUrl!,
                fit: BoxFit.cover,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No salary slip available for $selectedMonth $selectedYear.\n(Salary Slip will only show here once you download it).',
                style: TextStyle(
                    color: theme.textDark.value,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
