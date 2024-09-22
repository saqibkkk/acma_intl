import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controllers/theme_controller.dart';

class GenerateSalarySlip extends StatefulWidget {
  const GenerateSalarySlip({
    super.key,
    required this.name,
    required this.designation,
    required this.uid,
    required this.joiningDate,
    required this.payMonth,
    required this.payDate,
    required this.netSalary,
    required this.paidDays,
    required this.absent,
    required this.requiredHours,
    required this.completedHours,
    required this.basicSalary,
    required this.overTimeSalary,
    required this.contractSalary,
    required this.grossSalary,
    required this.receivable,
    required this.salary,
    required this.textColor,
    required this.textLight,
  });

  final String name;
  final String designation;
  final String uid;
  final String joiningDate;
  final String payMonth;
  final String payDate;
  final String netSalary;
  final String paidDays;
  final String absent;
  final String requiredHours;
  final String completedHours;
  final String basicSalary;
  final String overTimeSalary;
  final String contractSalary;
  final String grossSalary;
  final String receivable;
  final String salary;
  final Color textColor;
  final Color textLight;

  @override
  State<GenerateSalarySlip> createState() => _GenerateSalarySlipState();
}

class _GenerateSalarySlipState extends State<GenerateSalarySlip> {
  final ThemeController theme = Get.put(ThemeController());
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  Widget buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(label,
                style: TextStyle(
                    color: widget.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(': $value',
              style: TextStyle(color: widget.textColor, fontSize: 12)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow('Employee Name', widget.name),
                    buildRow('Designation', widget.designation),
                    buildRow('Monthly Salary', widget.salary),
                    buildRow('Employee ID', widget.uid),
                    buildRow('Date Of Joining', widget.joiningDate),
                    buildRow('Pay Period', widget.payMonth),
                    buildRow('Pay Date', formattedDate),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  color: Colors.black87,
                  child: Container(
                    height: 120,
                    width: 100,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Rs. ${widget.netSalary}',
                              style: TextStyle(color: widget.textLight, fontSize: 14),
                            )),
                        const Divider(),
                        Text('Paid Days : ${widget.paidDays}',
                            style: TextStyle(color: widget.textLight, fontSize: 12)),
                        Text('Absents   : ${widget.absent}',
                            style: TextStyle(color: widget.textLight, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        buildRow('Required Hours Of Month', widget.requiredHours),
        buildRow('Total Completed Hours', widget.completedHours),
        const Divider(),
        buildRow('Basic Salary', widget.basicSalary),
        buildRow('Over Time Salary', widget.overTimeSalary),
        buildRow('Contract Salary', widget.contractSalary),
        const Divider(),
        buildRow('Gross Salary: Rs.', widget.grossSalary),
        const Divider(),
        buildRow('Receivables', widget.receivable),
        buildRow('Net Salary', widget.netSalary),
        const Divider(),
      ],
    );
  }
}
