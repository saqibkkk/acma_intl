import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_contract_model.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';
import 'add_contract.dart';
import 'contract_details.dart';

class Contract extends StatefulWidget {
  final EmployeeModel employee;

  const Contract({super.key, required this.employee});

  @override
  State<Contract> createState() => _ContractState();
}

class _ContractState extends State<Contract> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<EmployeeContractModel> employeeContractList = [];
  List<EmployeeContractModel> filteredContractList = [];
  bool isLoading = false;
  List<bool> editRemoveBtn = [];
  final TextEditingController searchController = TextEditingController();

  Future<void> fetchEmployeeContract() async {
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
    employeeContractList = await Api.getAllContract(
      idCard: widget.employee.idCard,
    );
    employeeContractList.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.date);
      DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.date);
      return dateB.compareTo(dateA);
    });
    setState(() {
      isLoading = false;
      filteredContractList = employeeContractList;
      editRemoveBtn = List<bool>.filled(employeeContractList.length, false);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterContracts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredContractList = employeeContractList;
      });
    } else {
      setState(() {
        filteredContractList = employeeContractList.where((contract) {
          return contract.contractName
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  void initState() {
    fetchEmployeeContract();
    searchController.addListener(() {
      filterContracts(searchController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
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
          title: Text(
            "Contract - ${widget.employee.name}",
            style: TextStyle(color: theme.textLight.value, fontSize: 16),
          ),
        ),
        floatingActionButton: SizedBox(
          height: 50,
          width: 120,
          child: FloatingActionButton(
            backgroundColor: theme.iconColor.value,
            onPressed: () {
              Get.to(AddContract(employee: widget.employee));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Add Contract',
                style: TextStyle(color: theme.textLight.value),
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: Utils.showProgressBar(context))
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Utils.customTextFormField(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).unfocus();
                              });
                            },
                            icon: FontAwesomeIcons.magnifyingGlass,
                            controller: searchController,
                            keyboardType: TextInputType.text,
                            label: 'Search by Contract Name...',
                            readOnly: false,
                            obscureText: false,
                            capital: TextCapitalization.words,
                            textColor: theme.textDark.value,
                            bgColor: theme.cardBtn.value)),
                    Expanded(
                      child: filteredContractList.isEmpty
                          ? Center(
                              child: Text(
                              "No contracts available!",
                              style: TextStyle(
                                  color: theme.textDark.value,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ))
                          : ListView.builder(
                              itemCount: filteredContractList.length,
                              itemBuilder: (context, index) {
                                final contract = filteredContractList[index];
                                return InkWell(
                                  onLongPress: () {
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
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    color: theme.cardBtn.value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                contract.contractName,
                                                style: TextStyle(
                                                    color: theme.textDark.value,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              editRemoveBtn[index]
                                                  ? InkWell(
                                                      onTap: () async {
                                                        Utils.customAlertBox(
                                                            employee:
                                                                widget.employee,
                                                            context: context,
                                                            headingText:
                                                                'Warning',
                                                            insideText:
                                                                'Contract ${contract.contractName} will be deleted permanently!',
                                                            onConfirmPress:
                                                                () async {
                                                              await Api.deleteContract(
                                                                  idCard: widget
                                                                      .employee
                                                                      .idCard,
                                                                  cUid: contract
                                                                      .cUid);
                                                              Get.back();
                                                              employeeContractList
                                                                  .clear();
                                                              await fetchEmployeeContract();
                                                            });
                                                      },
                                                      child: const Icon(
                                                          FontAwesomeIcons
                                                              .trash,
                                                          color: Colors.red))
                                                  : Text(
                                                      'Created on: ${contract.date}',
                                                      style: TextStyle(
                                                          color: theme
                                                              .textDark.value,
                                                          fontSize: 10),
                                                    )
                                            ],
                                          ),
                                          Divider(
                                            color: theme.iconColor.value,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${contract.contractItemName}',
                                                style: TextStyle(
                                                  color: theme.textDark.value,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Description: ${contract.contractDescription}',
                                                style: TextStyle(
                                                  color: theme.textDark.value,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Per Item Rate: ${contract.contractPerItemRate}',
                                                    style: TextStyle(
                                                      color:
                                                          theme.textDark.value,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Get.to(ContractDetails(
                                                        employee:
                                                            widget.employee,
                                                        employeeContract:
                                                            contract,
                                                      ));
                                                    },
                                                    child: Text('View Details',
                                                        style: TextStyle(
                                                            color: theme
                                                                .greenPrimary
                                                                .value,
                                                            fontSize: 10)),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
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
