import 'dart:io';
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import '../../Controllers/internet.dart';
import '../../Controllers/theme_controller.dart';
import '../../Models/client_bills_model.dart';
import '../../utils.dart';

class DownloadBill extends StatefulWidget {
  final ClientBill bill;
  const DownloadBill({
    super.key,
    required this.bill,
  });

  @override
  State<DownloadBill> createState() => _DownloadBillState();
}

class _DownloadBillState extends State<DownloadBill> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  final ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;

  Future<void> savePdfToDownloads(Uint8List pdfData) async {
    if (await _requestStoragePermission()) {
      try {
        final downloadsDirectory = Directory(
            '/storage/emulated/0/Download/ACMA INTL/Bills/${widget.bill.clientName}/');
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }
        final filePath = '${downloadsDirectory.path}/${widget.bill.billId}.pdf';
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
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: theme.textLight.value),
          ),
          title: Row(
            children: [
              Text(
                "Bill - ${widget.bill.clientName}",
                style: TextStyle(color: theme.textLight.value, fontSize: 16),
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  bool hasInternet = await internet.checkInternet();
                  if (!hasInternet) {
                    Utils.showSnackBar('Error', 'No Internet Connection.');
                    return;
                  }
                  setState(() => isLoading = true);
                  try {
                    final Uint8List? image =
                        await screenshotController.capture();
                    if (image == null) return;

                    final pdf = pw.Document();
                    pdf.addPage(pw.Page(build: (pw.Context context) {
                      return pw.Center(child: pw.Image(pw.MemoryImage(image)));
                    }));

                    Uint8List pdfData = await pdf.save();
                    await savePdfToDownloads(pdfData);
                    Utils.showSnackBar(
                        'Successful', 'PDF downloaded successfully');
                  } catch (e) {
                    Utils.showSnackBar(
                        'Error', "Failed to generate salary slip: $e");
                  } finally {
                    setState(() => isLoading = false);
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
        body: SafeArea(
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 100,
                        height: 70,
                        child: Image.asset('assets/acmaLogo.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Main G.T. Road, Markaz-e-Sanat Road, Street # 9, Gujranwala',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
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
                    buildRow('Bill #', widget.bill.billId),
                    buildRow('Date', widget.bill.date),
                    buildRow('Bill To', widget.bill.clientName),
                    buildRow('Address', widget.bill.clientAddress),
                    buildRow('Contact', widget.bill.clientContact),
                    const Divider(thickness: 2),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Sr #:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Price',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.bill.productNames.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.bill.serialNumber[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    widget.bill.productNames[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    widget.bill.productDescriptions[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.bill.productQuantities[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.bill.pricePerItems[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.bill.perItemTotals[index],
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            )
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Bill',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Text(widget.bill.billTotal,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    const Spacer(),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This is an electronically generated document and does not require any signature.',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Opacity(
                      opacity: .1, child: Image.asset('assets/acmaLogo.png')),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(': $value',
              style: const TextStyle(color: Colors.black87, fontSize: 12)),
        ),
      ],
    );
  }
}
