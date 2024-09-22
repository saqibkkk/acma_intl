import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_model.dart';
import '../employee_contract/contract.dart';
import '../employee_financials/employee_financials.dart';
import '../employee_salarySlip/employee_payroll.dart';
import '../employee_salarySlip/salary_slip.dart';
import 'employee_details.dart';
import '../../../utils.dart';

class AllEmployees extends StatefulWidget {
  const AllEmployees({super.key});

  @override
  State<AllEmployees> createState() => _AllEmployeesState();
}

class _AllEmployeesState extends State<AllEmployees> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();
  late bool _isLoading = false;

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
      _filteredEmployees = _employees
          .where((employee) => employee.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _fetchEmployeesData();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "All Employees",
          style: TextStyle(color: theme.textLight.value, fontSize: 16),
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
                                fontWeight: FontWeight.w500),
                          ))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                                top: 10, left: 15, right: 15, bottom: 20),
                            itemCount: _filteredEmployees.length,
                            itemBuilder: (context, index) {
                              EmployeeModel employee =
                                  _filteredEmployees[index];
                              return Card(
                                color: theme.cardBtn.value,
                                child: ExpansionTile(
                                  trailing: Icon(
                                    Icons.arrow_drop_down,
                                    color: theme.iconColor.value,
                                  ),
                                  title: Text(
                                    '${employee.name} ${employee.fatherName}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: theme.textDark.value,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    employee.designation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textDark.value,
                                    ),
                                  ),
                                  children: [
                                    Divider(
                                      color: theme.iconColor.value,
                                    ),
                                    _expansionContent(
                                        employee: employee,
                                        onPress: () {
                                          Get.to(EmployeeDetails(
                                            employee: employee,
                                          ));
                                        },
                                        title: 'Employee Details'),
                                    _expansionContent(
                                        employee: employee,
                                        onPress: () {
                                          Get.to(EmployeeFinancials(
                                              employee: employee));
                                        },
                                        title: 'Financials'),
                                    _expansionContent(
                                        employee: employee,
                                        onPress: () {
                                          Get.to(Contract(
                                            employee: employee,
                                          ));
                                        },
                                        title: 'Contracts'),
                                    _expansionContent(
                                        employee: employee,
                                        onPress: () {
                                          Get.to(SalarySlip(
                                            employee: employee,
                                          ));
                                        },
                                        title: 'Salary Slips'),
                                    _expansionContent(
                                        employee: employee,
                                        onPress: () {
                                          Get.to(EmployeePayroll(
                                            employee: employee,
                                          ));
                                        },
                                        title: 'Recent Salary Slip'),
                                    const SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              );
                            },
                          )),
              ],
            ),
    );
  }

  Widget _expansionContent(
      {required EmployeeModel employee,
      required VoidCallback onPress,
      required String title}) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(color: theme.textDark.value, fontSize: 12),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.iconColor.value,
            )
          ],
        ),
      ),
    );
  }
}
