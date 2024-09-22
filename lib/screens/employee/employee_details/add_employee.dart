import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/internet.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../home_screen.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
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
                    Icons.arrow_back,
                    color: theme.textLight.value,
                  ),
                ),
                Text('Add New Employee',
                    style:
                        TextStyle(color: theme.textLight.value, fontSize: 16)),
              ],
            ),
            backgroundColor: theme.appbarBottomNav.value,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom Form Fields
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
                      controller: employeeIDCard,
                      label: '13 digits ID card Number',
                      icon: FontAwesomeIcons.idCard,
                      keyboardType: TextInputType.number,
                      readOnly: false,
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
                        _buildImageButton(
                          label: 'Select ID Back',
                          imagePath: _backImage,
                          isFrontImage: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isLoading == false
                        ? Utils.customElevatedButton(
                            btnName: 'Add Employee',
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
            ),
          )),
    );
  }

  Widget _buildImageButton(
      {required String label, String? imagePath, required bool isFrontImage}) {
    return imagePath == null
        ? SizedBox(
            width: 150,
            child: Utils.customElevatedButton(
                btnName: label,
                onPress: () {
                  _showBottomSheet(isFrontImage: isFrontImage);
                },
                bgColor: theme.appbarBottomNav.value,
                textClr: theme.textLight.value))
        : GestureDetector(
            onTap: () => _showBottomSheet(isFrontImage: isFrontImage),
            child: Container(
              height: 120,
              width: 180,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Utils.customElevatedButton(
                          btnName: 'Gallery',
                          onPress: () {
                            _pickImage(ImageSource.gallery, isFrontImage);
                          },
                          bgColor: theme.scaffoldBg.value,
                          textClr: theme.textDark.value),
                      Utils.customElevatedButton(
                          btnName: 'Camera',
                          onPress: () {
                            _pickImage(ImageSource.camera, isFrontImage);
                          },
                          bgColor: theme.scaffoldBg.value,
                          textClr: theme.textDark.value)
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
      isLoading = true;
    });
    if (
        employeeName.text.isNotEmpty &&
        employeeFatherName.text.isNotEmpty &&
        employeeIDCard.text.isNotEmpty &&
        employeePhone.text.isNotEmpty &&
        employeeDesignation.text.isNotEmpty &&
        employeeSalary.text.isNotEmpty) {
      String idCardNumber = employeeIDCard.text;
      if (idCardNumber.length != 13) {
        Utils.showSnackBar('Error', 'ID card number must be exactly 13 digits');
        setState(() {
          isLoading = false;
        });
        return;
      } else if (!RegExp(r'^\d{13}$').hasMatch(idCardNumber)) {
        Utils.showSnackBar('Error', 'ID card number must contain only digits');
        setState(() {
          isLoading = false;
        });
        return;
      }
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('employees')
          .child(idCardNumber)
          .once();
      if (event.snapshot.exists) {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar('Error',
            'Employee with ID card number $idCardNumber already exists.');
        throw Exception(
            "Employee with ID card number $idCardNumber already exists.");
      }

      await Api.addEmployee(
        name: employeeName.text,
        fatherName: employeeFatherName.text,
        idCardNumber: employeeIDCard.text,
        phone: employeePhone.text,
        joiningDate: employeeJoiningDate.text,
        designation: employeeDesignation.text,
        salary: double.parse(employeeSalary.text),
        idFront: _frontImage ?? '',
        idBack: _backImage ?? '',
      );
      Utils.showSnackBar(
          'Successful', 'New Employee has been saved successfully');
      setState(() {
        isLoading = false;
      });
      Get.offAll(const HomeScreen());
    } else {
      Utils.showSnackBar('Error', 'Please fill all fields.');
      setState(() {
        isLoading = false;
      });
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
}
