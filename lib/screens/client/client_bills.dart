import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../../Controllers/theme_controller.dart';
import '../../Models/client_bills_model.dart';
import '../../Models/client_model.dart';
import 'download_bill.dart';

class ClientBills extends StatefulWidget {
  final ClientModel client;
  const ClientBills({super.key, required this.client});

  @override
  ClientBillsState createState() => ClientBillsState();
}

class ClientBillsState extends State<ClientBills> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  bool isLoading = false;
  List<bool> removeBtn = [];
  String? selectedOption;
  late List<ClientBill> clientBillsList = [];

  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> years = List.generate(DateTime.now().year - 1999,
      (index) => (DateTime.now().year - index).toString());
  String selectedYear = DateTime.now().year.toString();

  Future<void> fetchClientBills() async {
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
    clientBillsList = await Api.getClientBill(
        clientId: widget.client.clientId,
        month: selectedMonth,
        year: selectedYear);
    setState(() {
      isLoading = false;
      removeBtn = List<bool>.filled(clientBillsList.length, false);
    });
  }

  @override
  void initState() {
    fetchClientBills();
    super.initState();
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
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(FontAwesomeIcons.chevronLeft,
                color: theme.textLight.value),
          ),
          title: Row(
            children: [
              Text(
                "Bills - ${widget.client.name}",
                style: TextStyle(color: theme.textLight.value, fontSize: 16),
              ),
              const Spacer(),
              for (int i = 0; i < removeBtn.length; i++)
                removeBtn[i]
                    ? InkWell(
                        onTap: () async {
                          Utils.customAlertBox(
                              context: context,
                              headingText: 'Warning',
                              insideText:
                                  'Bill for client ${widget.client.name}, bill number ${clientBillsList[i].billId} and total amount ${clientBillsList[i].billTotal} will be deleted',
                              onConfirmPress: () async {
                                bool hasInternet =
                                    await internet.checkInternet();
                                if (!hasInternet) {
                                  Utils.showSnackBar(
                                      'Error', 'No Internet Connection.');
                                  return;
                                }
                                await Api.deleteClientBill(
                                    clientId: widget.client.clientId,
                                    selectedYear: selectedYear,
                                    selectedMonth: selectedMonth,
                                    billDate: clientBillsList[i].date,
                                    billId: clientBillsList[i].billId);
                                Get.back();
                                Utils.showSnackBar('Successful',
                                    'Bill for client ${widget.client.name},having bill number ${clientBillsList[i].billId} and total amount ${clientBillsList[i].billTotal} has been deleted');
                                clientBillsList.clear();
                                await fetchClientBills();
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
        body: isLoading
            ? Center(
                child: Utils.showProgressBar(context),
              )
            : SafeArea(
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
                                removeBtn.clear();
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
                                removeBtn.clear();
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
                              child: Text('Bill Id',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textDark.value,
                                      fontSize: 12)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Bill Total',
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
                        child: clientBillsList.isEmpty
                            ? Center(
                                child: Text(
                                  'No Bills are available for $selectedMonth $selectedYear',
                                  style: TextStyle(
                                      color: theme.textDark.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ListView.builder(
                                itemCount: clientBillsList.length,
                                itemBuilder: (context, index) {
                                  final bill = clientBillsList[index];
                                  return InkWell(
                                    onTap: () async{
                                      bool hasInternet = await internet.checkInternet();
                                      if (!hasInternet) {
                                        Utils.showSnackBar('Error', 'No Internet Connection.');
                                        return;
                                      }
                                      Get.to(DownloadBill(
                                        bill: bill,
                                      ));
                                    },
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
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      color: removeBtn[index]
                                          ? theme.iconColor.value
                                          : index % 2 == 0
                                              ? Colors.transparent
                                              : theme.multipleRows.value,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(bill.date,
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
                                              child: Text(bill.billId,
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
                                              child: Text(bill.billTotal,
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
                              )),
                  ],
                ),
              ),
      ),
    );
  }
}
