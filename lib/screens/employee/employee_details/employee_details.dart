import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../Models/employee_model.dart';
import '../../../../utils.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import 'all_employees.dart';
import 'edit_employee.dart';

class EmployeeDetails extends StatefulWidget {
  final EmployeeModel employee;
  const EmployeeDetails({super.key, required this.employee});

  @override
  EmployeeDetailsState createState() => EmployeeDetailsState();
}

class EmployeeDetailsState extends State<EmployeeDetails> {
  final bool _isLoading = false;
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();

  String formatStringWithDashes(String idCard) {
    if (idCard.length == 13) {
      return '${idCard.substring(0, 5)}-${idCard.substring(5, 12)}-${idCard.substring(12, 13)}';
    }
    return idCard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBg.value,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                FontAwesomeIcons.chevronLeft,
                color: theme.textLight.value,
              ),
            ),
            Text('Details - ${widget.employee.name}',
                style: TextStyle(color: theme.textLight.value, fontSize: 16)),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Get.to(EditEmployee(
                    employee: widget.employee,
                  ));
                },
                icon: const Icon(
                  FontAwesomeIcons.pencil,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () async {
                  await Utils.customAlertBox(
                      employee: widget.employee,
                      context: context,
                      headingText: 'Warning!',
                      insideText:
                          'All data of the employee ${widget.employee.name} ${widget.employee.fatherName} will be deleted permanently!',
                      onConfirmPress: () async {
                        bool hasInternet = await internet.checkInternet();
                        if (!hasInternet) {
                          Utils.showSnackBar(
                              'Error', 'No Internet Connection.');
                          return;
                        }
                        await Api.deleteEmployee(
                            idCard: widget.employee.idCard);
                        Get.off(() => const AllEmployees());
                        Utils.showSnackBar('Successful',
                            'Employee ${widget.employee.name} ${widget.employee.fatherName} is deleted!');
                      });
                },
                icon: const Icon(
                  FontAwesomeIcons.trash,
                  color: Colors.red,
                )),
          ],
        ),
        backgroundColor: theme.appbarBottomNav.value,
      ),
      body: _isLoading
          ? Center(child: Utils.showProgressBar(context))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    customCard(
                      subTitle:
                          '${widget.employee.name} ${widget.employee.fatherName}',
                      title: 'Name:',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    customCard(
                        title: 'ID Card Number:',
                        subTitle:
                            formatStringWithDashes(widget.employee.idCard)),
                    const SizedBox(
                      height: 10,
                    ),
                    customCard(
                        title: 'Mobile Number:',
                        subTitle: widget.employee.phone),
                    const SizedBox(
                      height: 10,
                    ),
                    customCard(
                        title: 'Joining Date:',
                        subTitle: widget.employee.joiningDate),
                    const SizedBox(
                      height: 10,
                    ),
                    customCard(
                        title: 'Designation:',
                        subTitle: widget.employee.designation),
                    const SizedBox(
                      height: 10,
                    ),
                    customCard(
                        title: 'Salary:',
                        subTitle: 'Rs. ${widget.employee.salary}'),
                    const SizedBox(
                      height: 20,
                    ),
                    Utils.customElevatedButton(
                        btnName: 'View ID Cards',
                        onPress: () {
                          _showBottomSheet(
                              idFront: widget.employee.idFront!,
                              idBack: widget.employee.idFront!);
                        },
                        bgColor: theme.appbarBottomNav.value,
                        textClr: theme.textLight.value)
                  ],
                ),
              ),
            ),
    );
  }

  Widget customCard({required String title, required String subTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                  color: theme.textDark.value,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            )),
        Card(
          color: theme.cardBtn.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Text(
              subTitle,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textDark.value,
                  fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet({required String idFront, required String idBack}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return GetBuilder<ThemeController>(
          id: "0",
          builder: (theme) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: theme.appbarBottomNav.value,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.employee.name} ${widget.employee.fatherName} ID Card',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textLight.value),
                      )),
                  const SizedBox(height: 16),
                  Text(
                    'ID Card Front:',
                    style:
                        TextStyle(color: theme.textLight.value, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: widget.employee.idFront!,
                      errorWidget: (context, url, error) => const Text(
                        'Not Available',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ID Card Back:',
                      style: TextStyle(
                          color: theme.textLight.value, fontSize: 12)),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: widget.employee.idBack!,
                      errorWidget: (context, url, error) => const Text(
                        'Not Available',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
