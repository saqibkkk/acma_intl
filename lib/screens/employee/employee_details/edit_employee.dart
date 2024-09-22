import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../Models/employee_model.dart';
import '../../../utils.dart';
import 'all_employees.dart';

class EditEmployee extends StatefulWidget {
  final EmployeeModel employee;
  const EditEmployee({super.key, required this.employee});

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final employeeName = TextEditingController();
  final employeeFatherName = TextEditingController();
  final employeeIDCard = TextEditingController();
  final employeePhone = TextEditingController();
  final employeeJoiningDate = TextEditingController();
  final employeeSalary = TextEditingController();
  final employeeDesignation = TextEditingController();
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  late bool isLoading = false;
  String? _frontImage;
  String? _backImage;

  @override
  void initState() {
    super.initState();
    employeeName.text = widget.employee.name;
    employeeFatherName.text = widget.employee.fatherName;
    employeeIDCard.text = formatStringWithDashes(widget.employee.idCard);
    employeePhone.text = widget.employee.phone;
    employeeJoiningDate.text = widget.employee.joiningDate;
    employeeSalary.text = widget.employee.salary.toString();
    employeeDesignation.text = widget.employee.designation;
  }

  @override
  void dispose() {
    employeeName.dispose();
    employeeFatherName.dispose();
    employeeIDCard.dispose();
    employeePhone.dispose();
    employeeJoiningDate.dispose();
    employeeSalary.dispose();
    employeeDesignation.dispose();
    super.dispose();
  }

  String formatStringWithDashes(String idCard) {
    if (idCard.length == 13) {
      return '${idCard.substring(0, 5)}-${idCard.substring(5, 12)}-${idCard.substring(12, 13)}';
    }
    return idCard;
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
                Text('Edit Employee',
                    style:
                        TextStyle(color: theme.textLight.value, fontSize: 16)),
              ],
            ),
            backgroundColor: theme.appbarBottomNav.value,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Utils.customTextFormField(
                    controller: employeeName,
                    label: 'Name',
                    icon: FontAwesomeIcons.circleUser,
                    keyboardType: TextInputType.text,
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    controller: employeeFatherName,
                    label: 'Father Name',
                    icon: FontAwesomeIcons.solidUser,
                    keyboardType: TextInputType.text,
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    controller: TextEditingController(
                        text: formatStringWithDashes(widget.employee.idCard)),
                    label: '13 digits ID card Number',
                    icon: FontAwesomeIcons.idCard,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    controller: employeePhone,
                    label: 'Phone',
                    icon: FontAwesomeIcons.mobileScreen,
                    keyboardType: TextInputType.phone,
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  _buildDateField(
                    controller: employeeJoiningDate,
                    label: 'Joining Date',
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    controller: employeeDesignation,
                    label: 'Designation',
                    icon: FontAwesomeIcons.idBadge,
                    keyboardType: TextInputType.text,
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.words,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 15),
                  Utils.customTextFormField(
                    controller: employeeSalary,
                    label: 'Salary',
                    icon: FontAwesomeIcons.creditCard,
                    keyboardType: TextInputType.number,
                    readOnly: false,
                    obscureText: false,
                    capital: TextCapitalization.none,
                    textColor: theme.textDark.value,
                    bgColor: theme.cardBtn.value,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageButton(
                        label: 'Select ID Front',
                        imagePath: _frontImage,
                        isFrontImage: true,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      _buildImageButton(
                        label: 'Select ID Back',
                        imagePath: _backImage,
                        isFrontImage: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isLoading == false
                      ? _buildCustomElevatedButton(
                          btnName: 'Edit Employee',
                          onPress: _saveEmployee,
                          bgColor: theme.appbarBottomNav.value,
                          textClr: theme.textLight.value,
                        )
                      : Center(
                          child: Utils.showProgressBar(context),
                        )
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildImageButton(
      {required String label, String? imagePath, required bool isFrontImage}) {
    return GestureDetector(
      onTap: () => _showBottomSheet(isFrontImage: isFrontImage),
      child: Container(
        height: 120,
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imagePath == null
              ? Image.network(
                  isFrontImage
                      ? widget.employee.idFront!
                      : widget.employee.idBack!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  void _showBottomSheet({required bool isFrontImage}) {
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
              decoration: BoxDecoration(
                  color: theme.appbarBottomNav.value,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCustomElevatedButton(
                          btnName: 'Gallery',
                          onPress: () {
                            _pickImage(ImageSource.gallery, isFrontImage);
                          },
                          bgColor: theme.scaffoldBg.value,
                          textClr: theme.textDark.value),
                      _buildCustomElevatedButton(
                          btnName: 'Camera',
                          onPress: () {
                            _pickImage(ImageSource.camera, isFrontImage);
                          },
                          bgColor: theme.scaffoldBg.value,
                          textClr: theme.textDark.value),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, bool isFrontImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        if (isFrontImage) {
          _frontImage = image.path;
        } else {
          _backImage = image.path;
        }
      });
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _saveEmployee() async {
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'No Internet Connection.');
      return;
    }
    setState(() {
      isLoading == true;
    });
    // if (employeeSalary.text.isNotEmpty) {
    //   try {
    //     salary = double.parse(employeeSalary.text);
    //   } catch (e) {
    //     return;
    //   }
    // } else {
    //   Utils.showSnackBar('Error', 'Employee salary can no be empty.');
    //   return;
    // }
    if (employeeName.text.isNotEmpty &&
        employeeFatherName.text.isNotEmpty &&
        employeePhone.text.isNotEmpty &&
        employeeDesignation.text.isNotEmpty &&
        employeeSalary.text.isNotEmpty) {
      await Api.updateEmployee(
        idCardNumber: widget.employee.idCard,
        name: employeeName.text,
        fatherName: employeeFatherName.text,
        phone: employeePhone.text,
        joiningDate: employeeJoiningDate.text,
        designation: employeeDesignation.text,
        salary: double.parse(employeeSalary.text),
        idFront: _frontImage,
        idBack: _backImage,
      );
      Get.off(const AllEmployees());
      setState(() {
        isLoading == false;
      });
      Utils.showSnackBar(
          'Successful', 'Employee has been updated successfully');
    } else {
      setState(() {
        isLoading == false;
      });
      Utils.showSnackBar('Error',
          'Please fill all fields and select both front and back ID images');
    }
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: theme.textDark.value, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(FontAwesomeIcons.calendarDay, color: theme.iconColor.value),
        filled: true,
        fillColor: theme.cardBtn.value,
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
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        }
      },
    );
  }

  Widget _buildCustomElevatedButton(
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
}
