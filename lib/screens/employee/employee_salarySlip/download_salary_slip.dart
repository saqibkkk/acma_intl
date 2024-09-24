import 'dart:io';
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';
import 'generate_salary_slip.dart';

class DownloadSalarySlip extends StatefulWidget {
  final EmployeeModel employee;
  final String selectedMonth;
  final double netSalary;
  final List dailyReportList;
  final String absent;
  final String requiredHours;
  final String completedHours;
  final String basicSalary;
  final String overTimeSalary;
  final String totalContractEarning;
  final double grossSalary;
  final double receivedAmount;
  final String selectedYear;
  final String currentDate;

  const DownloadSalarySlip({
    super.key,
    required this.employee,
    required this.selectedMonth,
    required this.netSalary,
    required this.dailyReportList,
    required this.absent,
    required this.requiredHours,
    required this.completedHours,
    required this.basicSalary,
    required this.overTimeSalary,
    required this.totalContractEarning,
    required this.grossSalary,
    required this.receivedAmount,
    required this.selectedYear,
    required this.currentDate,
  });

  @override
  DownloadSalarySlipState createState() => DownloadSalarySlipState();
}

class DownloadSalarySlipState extends State<DownloadSalarySlip> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;

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
            '${downloadsDirectory.path}/SalarySlip ${widget.selectedMonth} ${widget.selectedYear}.pdf';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.appbarBottomNav.value,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon:
              Icon(FontAwesomeIcons.chevronLeft, color: theme.textLight.value),
        ),
        title: Row(
          children: [
            Text(
              "Salary Slip - ${widget.employee.name}",
              style: TextStyle(color: theme.textLight.value, fontSize: 16),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {

                try {
                  setState(() => isLoading = true);
                  bool hasInternet = await internet.checkInternet();
                  if (!hasInternet) {
                    setState(() => isLoading = false);
                    Utils.showSnackBar('Error', 'No Internet Connection.');
                    return;
                  }

                  final Uint8List? image = await screenshotController.capture();
                  if (image == null) return;
                  final pdf = pw.Document();
                  pdf.addPage(pw.Page(build: (pw.Context context) {
                    return pw.Center(child: pw.Image(pw.MemoryImage(image)));
                  }));
                  Uint8List pdfData = await pdf.save();
                  await savePdfToDownloads(pdfData, widget.employee.name);
                  await Api.saveSalarySlip(
                    idCard: widget.employee.idCard,
                    year: widget.selectedYear,
                    month: widget.selectedMonth,
                    salarySlipImage: image,
                  );
                  if (widget.receivedAmount.toString() != '0.0') {
                    await Api.addReceived(
                        idCard: widget.employee.idCard,
                        date: widget.currentDate,
                        amount: widget.receivedAmount.toString(),
                        status:
                            'Received In Salary - ${widget.selectedMonth} ${widget.selectedYear}');
                  }
                  setState(() => isLoading = false);
                  Utils.showSnackBar(
                      'Successful', 'PDF downloaded successfully');
                } catch (e) {
                  Utils.showSnackBar(
                      'Error', "Failed to generate salary slip: $e");
                }
              },
              child: isLoading
                  ? Utils.showProgressBar(context)
                  : Icon(FontAwesomeIcons.download,
                      color: theme.greenPrimary.value),
            ),
          ],
        ),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 100,
                      height: 70,
                      child:
                          Image.asset('assets/acmaLogo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Main G.T. Road, Markaz-e-Sanat Road, Street # 9, Gujranwala',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Phone: 0321-7432032 / 0309-0550002',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Divider(thickness: 2),
                  GenerateSalarySlip(
                    name:
                        '${widget.employee.name} ${widget.employee.fatherName}',
                    designation: widget.employee.designation,
                    uid: widget.employee.idCard,
                    joiningDate: widget.employee.joiningDate,
                    payMonth: widget.selectedMonth,
                    payDate: widget.currentDate,
                    netSalary: widget.netSalary.toStringAsFixed(2),
                    paidDays: widget.dailyReportList.length.toString(),
                    absent: widget.absent,
                    requiredHours: widget.requiredHours,
                    completedHours: widget.completedHours,
                    basicSalary: widget.basicSalary,
                    overTimeSalary: widget.overTimeSalary,
                    contractSalary: widget.totalContractEarning,
                    grossSalary: widget.grossSalary.toStringAsFixed(2),
                    receivable: widget.receivedAmount.toStringAsFixed(2),
                    salary: widget.employee.salary.toString(),
                    textColor: Colors.black,
                    textLight: Colors.white,
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This is an electronically generated document and does not require any signature.',
                          style: TextStyle(color: Colors.black87, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Opacity(
                  opacity: .1, child: Image.asset('assets/acmaLogo.png')),
            ),
          ],
        ),
      ),
    );
  }
}
