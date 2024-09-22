import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';
import 'contract.dart';

class AddContract extends StatefulWidget {
  final EmployeeModel employee;
  const AddContract({super.key, required this.employee});

  @override
  State<AddContract> createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  bool isLoading = false;
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  );
  final TextEditingController contractName = TextEditingController();
  final TextEditingController contractDesc = TextEditingController();
  final TextEditingController contractItemName = TextEditingController();
  final TextEditingController contractItemRate = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    contractName.dispose();
    contractDesc.dispose();
    contractItemName.dispose();
    contractItemRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
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
            icon: Icon(FontAwesomeIcons.chevronLeft, color: theme.textLight.value),
          ),
          title: Text(
            "New Contract - ${widget.employee.name}",
            style: TextStyle(color: theme.textLight.value, fontSize: 16),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Utils.customTextFormField(
                  icon: FontAwesomeIcons.calendarDay,
                  controller: _dateController,
                  keyboardType: TextInputType.datetime,
                  label: 'Date',
                  readOnly: true,
                  obscureText: false,
                  capital: TextCapitalization.none,
                  textColor: theme.textDark.value,
                  bgColor: theme.cardBtn.value,
                ),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.receipt,
                    controller: contractName,
                    keyboardType: TextInputType.text,
                    label: 'Contract Name',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.font,
                    controller: contractDesc,
                    keyboardType: TextInputType.text,
                    label: 'Contract Description',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.sentences,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                Utils.customTextFormField(
                    icon: FontAwesomeIcons.chartGantt,
                    controller: contractItemName,
                    keyboardType: TextInputType.text,
                    label: 'Item Name',
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
                    controller: contractItemRate,
                    keyboardType: TextInputType.number,
                    label: 'Per Item Rate',
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                isLoading == true
                ?Utils.showProgressBar(context)
                :Utils.customElevatedButton(
                    btnName: 'Add Contract',
                    onPress: () async {
                      bool hasInternet = await internet.checkInternet();
                      if (!hasInternet) {
                        Utils.showSnackBar('Error', 'No Internet Connection.');
                        return;
                      }
                      setState(() {
                        isLoading == true;
                      });
                      if (contractName.text.isNotEmpty) {
                        if (contractItemName.text.isNotEmpty) {
                          if (contractItemRate.text.isNotEmpty) {
                            await Api.addContract(
                                idCard: widget.employee.idCard,
                                date: _dateController.text,
                                contractName: contractName.text,
                                contractDescription: contractDesc.text,
                                contractItemName: contractItemName.text,
                                contractPerItemRate: contractItemRate.text);
                            Get.off(Contract(employee: widget.employee));
                            setState(() {
                              isLoading == false;
                            });
                            Utils.showSnackBar('Successful',
                                'New Contract ${contractName.text} has been created successfully');
                          } else {
                            setState(() {
                              isLoading == false;
                            });
                            Utils.showSnackBar(
                                'Error', 'Per item rate can not be empty');
                          }
                        } else {
                          setState(() {
                            isLoading == false;
                          });
                          Utils.showSnackBar('Error', 'Item name can not be empty');
                        }
                      } else {
                        setState(() {
                          isLoading == false;
                        });
                        Utils.showSnackBar(
                            'Error', 'Contract name can not be empty');
                      }
                    },
                    bgColor: theme.appbarBottomNav.value,
                    textClr: theme.textLight.value)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
