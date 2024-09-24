import 'dart:core';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../Models/client_bills_model.dart';
import '../Models/client_model.dart';
import '../Models/employee_attendance_model.dart';
import '../Models/employee_bill_model.dart';
import '../Models/employee_contractEarning_model.dart';
import '../Models/employee_contract_model.dart';
import '../Models/employee_model.dart';
import '../Models/stock_model.dart';
import '../Models/user_model.dart';
import '../utils.dart';
import 'dart:typed_data';

class Api extends GetxController {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  static FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> companyDetailsList = [];
  static User get user => auth.currentUser!;

  static Future<UserModel?> getUser() async {
    try {
      DatabaseReference userRef = dbRef.child('Users').child(user.uid);
      DatabaseEvent event = await userRef.once();

      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        UserModel user = UserModel.fromJson(userData);
        return user;
      } else {
        print('No data found for user ${user.uid}');
        return null;
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      rethrow;
    }
  }

  static Future<bool> userExists() async {
    try {
      DatabaseReference userRef = dbRef.child('Users').child(user.uid);
      DatabaseEvent event = await userRef.once();
      return event.snapshot.exists;
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return false;
    }
  }

  static Future<bool> checkNtn(
      {required String ntn, required String pass}) async {
    String Ntn = ntn.trim();

    try {
      DatabaseReference ref = dbRef.child('companyDetails');
      DataSnapshot snapshot = (await ref.once()).snapshot;
      if (snapshot.value != null) {
        Map<String, dynamic> companyDetails =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        String storedNtn = companyDetails['ntn'].toString();
        String storedPassword = companyDetails['password'].toString();
        if (storedNtn == Ntn && storedPassword == pass) {
          return true;
        }
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }

    return false;
  }

  static Future<void> createUser() async {
    final userModel = UserModel(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      photo: user.photoURL.toString(),
    );
    try {
      dbRef.child('Users').child(user.uid).set(userModel.toJson());
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<bool> changeCompanyPassword({required String pass}) async {
    try {
      DatabaseReference ref = dbRef.child('companyDetails');
      DataSnapshot snapshot = (await ref.once()).snapshot;
      if (snapshot.value != null) {
        Map<String, dynamic> companyDetails =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        String storedPassword = companyDetails['password'].toString();
        if (storedPassword == pass) {
          return true;
        } else {}
      } else {}
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getCompanyDetails() async {
    try {
      DatabaseReference companyRef = dbRef.child('companyDetails');
      DatabaseEvent event = await companyRef.once();
      var companyData = event.snapshot.value;

      if (companyData != null && companyData is Map) {
        return [
          {
            'name': companyData['name'],
            'ntn': companyData['ntn'],
            'password': companyData['password'],
          }
        ];
      } else {
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return [];
    }
  }

  static Future<void> updateCompanyPassword({required String password}) async {
    try {
      dbRef.child('companyDetails').update({'password': password});
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addEmployee({
    required String name,
    required String fatherName,
    required String idCardNumber,
    required String phone,
    required String joiningDate,
    required String designation,
    required double salary,
    String? idFront,
    String? idBack,
  }) async {
    try {
      String? frontImageUrl;
      String? backImageUrl;
      if (idFront != null && File(idFront).existsSync()) {
        File frontFile = File(idFront);
        String frontFileName =
            'employee_idCards/$idCardNumber/${idCardNumber}_front.jpg';
        Reference frontRef = storage.ref().child(frontFileName);
        UploadTask frontUploadTask = frontRef.putFile(frontFile);
        TaskSnapshot frontSnapshot = await frontUploadTask;
        frontImageUrl = await frontSnapshot.ref.getDownloadURL();
      }
      if (idBack != null && File(idBack).existsSync()) {
        File backFile = File(idBack);
        String backFileName =
            'employee_idCards/$idCardNumber/${idCardNumber}_back.jpg';
        Reference backRef = storage.ref().child(backFileName);
        UploadTask backUploadTask = backRef.putFile(backFile);
        TaskSnapshot backSnapshot = await backUploadTask;
        backImageUrl = await backSnapshot.ref.getDownloadURL();
      }
      await dbRef.child('employees').child(idCardNumber).set({
        'name': name,
        'fatherName': fatherName,
        'idCard': idCardNumber,
        'phone': phone,
        'joiningDate': joiningDate,
        'designation': designation,
        'salary': salary,
        'idFront': frontImageUrl ?? '',
        'idBack': backImageUrl ?? '',
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred');
      rethrow;
    }
  }

  static Future<void> updateEmployee({
    required String idCardNumber,
    String? name,
    String? fatherName,
    String? phone,
    String? joiningDate,
    String? designation,
    double? salary,
    String? idFront,
    String? idBack,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (fatherName != null) updates['fatherName'] = fatherName;
      if (phone != null) updates['phone'] = phone;
      if (joiningDate != null) updates['joiningDate'] = joiningDate;
      if (designation != null) updates['designation'] = designation;
      if (salary != null) updates['salary'] = salary;

      if (idFront != null) {
        File frontFile = File(idFront);
        String frontFileName =
            'employee_idCards/$idCardNumber/${idCardNumber}_front.jpg';
        Reference frontRef = storage.ref().child(frontFileName);
        UploadTask frontUploadTask = frontRef.putFile(frontFile);
        TaskSnapshot frontSnapshot = await frontUploadTask;
        String frontImageUrl = await frontSnapshot.ref.getDownloadURL();
        updates['idFront'] = frontImageUrl;
      }

      if (idBack != null) {
        File backFile = File(idBack);
        String backFileName =
            'employee_idCards/$idCardNumber/${idCardNumber}_back.jpg';
        Reference backRef = storage.ref().child(backFileName);
        UploadTask backUploadTask = backRef.putFile(backFile);
        TaskSnapshot backSnapshot = await backUploadTask;
        String backImageUrl = await backSnapshot.ref.getDownloadURL();
        updates['idBack'] = backImageUrl;
      }
      if (updates.isNotEmpty) {
        await dbRef.child('employees').child(idCardNumber).update(updates);
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      rethrow;
    }
  }

  static Future<void> deleteEmployee({required String idCard}) async {
    await dbRef.child('employees').child(idCard).remove();
    await dbRef.child('DailyReports').child(idCard).remove();
  }

  static Future<List<EmployeeModel>> getEmployees() async {
    try {
      DatabaseReference employeesRef = dbRef.child('employees');
      DatabaseEvent event = await employeesRef.once();

      if (event.snapshot.value != null) {
        Map<String, dynamic> employeesData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        List<EmployeeModel> employees = [];

        employeesData.forEach((key, value) {
          employees
              .add(EmployeeModel.fromJson(Map<String, dynamic>.from(value)));
        });

        return employees;
      } else {
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      rethrow;
    }
  }

  static Future<void> addEmployeeAttendance(
      {required String idCard,
      required String startTime,
      required String endTime,
      required String currentDate,
      String? dailyHours}) async {
    String date = Utils.getCurrentDate();
    String month = Utils.getCurrentMonthName();
    int year = Utils.getCurrentYear();

    try {
      await dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child('$year')
          .child(month)
          .child(date)
          .set({
        'startTime': startTime,
        'endTime': endTime,
        'currentDate': currentDate,
        'dailyHours': dailyHours
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown occurred');
    }
  }

  static Future<void> editEmployeeAttendance(
      {required String idCard,
      required String startTime,
      required String endTime,
      required String month,
      required String year,
      required String date,
      required String dailyHours}) async {
    try {
      await dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child(year)
          .child(month)
          .child(date)
          .update({
        'startTime': startTime,
        'endTime': endTime,
        'currentDate': date,
        'dailyHours': dailyHours
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred');
    }
  }

  static Future<void> removeEmployeeAttendance({
    required String idCard,
    required String month,
    required String year,
    required String date,
  }) async {
    try {
      await dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child(year)
          .child(month)
          .child(date)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred');
    }
  }

  static Future<List<EmployeeAttendanceModel>> getAttendance({
    required String idCard,
    required String month,
    required String year,
  }) async {
    List<EmployeeAttendanceModel> monthlyAttendanceList = [];

    try {
      DatabaseReference monthRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child(year)
          .child(month);

      DatabaseEvent snapshot = await monthRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> monthlyData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        RegExp datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
        monthlyData.forEach((dateKey, attendanceData) {
          if (datePattern.hasMatch(dateKey)) {
            var attendanceModel = EmployeeAttendanceModel.fromJson({
              'currentDate': attendanceData['currentDate'],
              'startTime': attendanceData['startTime'],
              'endTime': attendanceData['endTime'],
              'dailyHours': attendanceData['dailyHours'],
            });

            monthlyAttendanceList.add(attendanceModel);
          }
        });

        return monthlyAttendanceList;
      } else {
        print("No attendance records found for the month.");
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return [];
    }
  }

  static Future<void> addReceived(
      {required String idCard,
      required String date,
      required String amount,
      required String status}) async {
    int year = Utils.getCurrentYear();
    String month = Utils.getCurrentMonthName();
    String fUid = Utils.generate6DigitUID();
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child('$year')
          .child(month)
          .child(date)
          .child('received-$fUid')
          .set({
        'fUid': 'received-$fUid',
        'date': date,
        'receivedStatus': status,
        'receivedAmount': amount
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addReceivable(
      {required String idCard,
      required String date,
      required String description,
      required String amount}) async {
    int year = Utils.getCurrentYear();
    String month = Utils.getCurrentMonthName();
    String fUid = Utils.generate6DigitUID();

    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child('$year')
          .child(month)
          .child(date)
          .child('receivable-$fUid')
          .set({
        'fUid': 'receivable-$fUid',
        'date': date,
        'receivableDescription': description,
        'receivableAmount': amount
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addPendingReceivable(
      {required String idCard,
      required String pendingReceivable,
      required String month,
      required String year}) async {
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child(year)
          .child(month)
          .child('Pending Receivable')
          .set({
        'pendingReceivable': pendingReceivable,
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<String> getPendingReceivable({
    required String idCard,
    required String year,
    required String month,
  }) async {
    try {
      DatabaseReference pendingReceivableRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child(year)
          .child(month)
          .child('Pending Receivable');

      DatabaseEvent snapshot = await pendingReceivableRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> pendingReceivableData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        String pendingReceivable =
            pendingReceivableData['pendingReceivable'] ?? '0';

        return pendingReceivable;
      } else {
        print("No pending receivable found.");
        return '0';
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return '0';
    }
  }

  static Future<List<EmployeeFinancialsModel>> getFinancials({
    required String idCard,
    required String month,
    required String year,
  }) async {
    List<EmployeeFinancialsModel> employeeFinancialsModel = [];

    try {
      DatabaseReference financialRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child(year)
          .child(month);

      DatabaseEvent snapshot = await financialRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> financialData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        financialData.forEach((dateKey, entryData) {
          if (entryData is Map) {
            entryData.forEach((uid, financialData) {
              if (financialData is Map) {
                Map<String, dynamic> financialEntryData =
                    Map<String, dynamic>.from(financialData);

                String receivedAmount =
                    financialEntryData['receivedAmount'] ?? '0';
                String receivableAmount =
                    financialEntryData['receivableAmount'] ?? '0';
                String receivableStatus =
                    financialEntryData['receivedStatus'] ?? '';
                String receivableDescription =
                    financialEntryData['receivableDescription'] ?? '';
                String fUid = financialEntryData['fUid'] ?? '';

                var financialModel = EmployeeFinancialsModel.fromJson({
                  'date': dateKey,
                  'receivedAmount': receivedAmount,
                  'receivable': receivableAmount,
                  'receivedStatus': receivableStatus,
                  'receivableDescription': receivableDescription,
                  'fUid': fUid,
                });

                employeeFinancialsModel.add(financialModel);
              }
            });
          }
        });

        return employeeFinancialsModel;
      } else {
        print("No Contract Details found.");
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return [];
    }
  }

  static Future<void> deleteFinancials(
      {required String idCard,
      required String year,
      required String month,
      required String date,
      required String id}) async {
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Financials')
          .child(year)
          .child(month)
          .child(date)
          .child(id)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addContract({
    required String idCard,
    required String date,
    required String contractName,
    required String contractDescription,
    required String contractItemName,
    required String contractPerItemRate,
  }) async {
    String cUid = Utils.generate6DigitUID();

    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Details')
          .child(date)
          .set({
        'cUid': cUid,
        'date': date,
        'contractName': contractName,
        'contractDescription': contractDescription,
        'contractItemName': contractItemName,
        'contractPerItemRate': contractPerItemRate,
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<List<EmployeeContractModel>> getAllContract({
    required String idCard,
  }) async {
    List<EmployeeContractModel> employeeContractModel = [];
    try {
      DatabaseReference contractRef =
          dbRef.child('DailyReports').child(idCard).child('Contract');

      DatabaseEvent snapshot = await contractRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> contractData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        contractData.forEach((cUidKey, contractDetails) {
          Map<String, dynamic> contractDetailsMap =
              Map<String, dynamic>.from(contractDetails as Map);

          if (contractDetailsMap.containsKey('Contract Details')) {
            Map<String, dynamic> dateEntries = Map<String, dynamic>.from(
                contractDetailsMap['Contract Details'] as Map);
            dateEntries.forEach((dateKey, entryData) {
              Map<String, dynamic> contractEntryData =
                  Map<String, dynamic>.from(entryData as Map);

              String contractName = contractEntryData['contractName'] ?? '0';
              String contractDescription =
                  contractEntryData['contractDescription'] ?? '0';
              String contractItemName =
                  contractEntryData['contractItemName'] ?? '';
              String contractPerItemRate =
                  contractEntryData['contractPerItemRate'] ?? '';
              String cUid = contractEntryData['cUid'] ?? '';

              var contractModel = EmployeeContractModel.fromJson({
                'date': dateKey,
                'contractName': contractName,
                'contractDescription': contractDescription,
                'contractItemName': contractItemName,
                'contractPerItemRate': contractPerItemRate,
                'cUid': cUid,
              });

              employeeContractModel.add(contractModel);
            });
          }
        });

        return employeeContractModel;
      } else {
        print("No Contract found.");
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return [];
    }
  }

  static Future<void> deleteContract(
      {required String idCard, required String cUid}) async {
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addContractEarning(
      {required String idCard,
      required String noOfItems,
      required String date,
      required String cUid,
      required String year,
      required String month}) async {
    String eUid = Utils.generate6DigitUID();

    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Earning')
          .child(year)
          .child(month)
          .child(date)
          .child(eUid)
          .set({'eUid': eUid, 'date': date, 'noOfItems': noOfItems});
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> addTotalContractEarning({
    required String idCard,
    required String cUid,
    required String totalEarning,
    required String year,
    required String month,
  }) async {
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Earning')
          .child(year)
          .child(month)
          .child('Total Earning')
          .set({
        'totalEarning': totalEarning,
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<String> getContractTotalEarning(
      {required String idCard,
      required String year,
      required String month,
      required String cUid}) async {
    try {
      DatabaseReference contractEarningRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Earning')
          .child(year)
          .child(month)
          .child('Total Earning');

      DatabaseEvent snapshot = await contractEarningRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> contractEarning =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        String totalContractEarning = contractEarning['totalEarning'] ?? '0';

        return totalContractEarning;
      } else {
        print("No pending receivable found.");
        return '0';
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return '0';
    }
  }

  static Future<List<EmployeeContractEarningModel>> getContractEarning({
    required String idCard,
    required String cUid,
    required String month,
    required String year,
  }) async {
    List<EmployeeContractEarningModel> employeeContractEarningModel = [];

    try {
      DatabaseReference contractRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Earning')
          .child(year)
          .child(month);

      DatabaseEvent snapshot = await contractRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> contractData =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        contractData.forEach((dateKey, entryData) {
          if (entryData is Map) {
            entryData.forEach((eUidKey, earningData) {
              if (earningData is Map) {
                Map<String, dynamic> contractEntryData =
                    Map<String, dynamic>.from(earningData);

                String noOfItems =
                    contractEntryData['noOfItems']?.toString() ?? '0';
                String eUid = contractEntryData['eUid']?.toString() ?? '0';

                var contractEarningModel =
                    EmployeeContractEarningModel.fromJson({
                  'date': dateKey,
                  'noOfItems': noOfItems,
                  'eUid': eUid,
                });

                employeeContractEarningModel.add(contractEarningModel);
              }
            });
          }
        });

        return employeeContractEarningModel;
      } else {
        print("No Contract Details found.");
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return [];
    }
  }

  static Future<void> deleteContractEarning({
    required String idCard,
    required String cUid,
    required String year,
    required String month,
    required String date,
    required String eUid,
  }) async {
    try {
      dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Contract')
          .child(cUid)
          .child('Contract Earning')
          .child(year)
          .child(month)
          .child(date)
          .child(eUid)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> saveSalarySlip({
    required String idCard,
    required String year,
    required String month,
    required Uint8List salarySlipImage,
  }) async {
    try {
      String storagePath =
          'all_employee/$idCard/salary_slips/$year/$month/salarySlip.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      UploadTask uploadTask = storageRef.putData(salarySlipImage);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child(year)
          .child(month)
          .child('Salary Slip')
          .set({'salarySlipUrl': downloadUrl});

      print('Salary slip saved successfully.');
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<String> getSalarySlip(
      {required String idCard,
      required String year,
      required String month}) async {
    try {
      DatabaseReference salarySlipRef = dbRef
          .child('DailyReports')
          .child(idCard)
          .child('Attendance')
          .child(year)
          .child(month)
          .child('Salary Slip');

      DatabaseEvent snapshot = await salarySlipRef.once();

      if (snapshot.snapshot.exists) {
        Map<String, dynamic> salarySlip =
            Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        String allSalarySlips = salarySlip['salarySlipUrl'] ?? '0';

        return allSalarySlips;
      } else {
        print("No Salary slip available..");
        return '0';
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      return '0';
    }
  }

  static Future<void> addClient(
      {required String clientName,
      required String clientAddress,
      required String clientContact}) async {
    final String clientId = Utils.generate6DigitUID();

    try {
      dbRef.child('Clients').child('Client Details').child(clientId).set({
        'clientId': clientId,
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientContact': clientContact
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> editClient(
      {required String clientName,
      required String clientAddress,
      required String clientContact,
      required String clientId}) async {
    try {
      dbRef.child('Clients').child('Client Details').child(clientId).update({
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientContact': clientContact
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> deleteClient({required String clientId}) async {
    try {
      await dbRef
          .child('Clients')
          .child('Client Details')
          .child(clientId)
          .remove();
      await dbRef
          .child('Clients')
          .child('Client Bills')
          .child(clientId)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<List<ClientModel>> getClient() async {
    try {
      DatabaseReference clientRef =
          dbRef.child('Clients').child('Client Details');
      DatabaseEvent event = await clientRef.once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> clientData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        List<ClientModel> clients = [];
        clientData.forEach((uid, value) {
          clients.add(ClientModel.fromJson(Map<String, dynamic>.from(value)));
        });

        return clients;
      } else {
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      rethrow;
    }
  }

  static Future<void> generateBill(
      {required String clientName,
      required String clientAddress,
      required String clientContact,
      required List<String> serialNumber,
      required List<String> productName,
      required List<String> productDescription,
      required List<String> productQuantity,
      required List<String> perItemPrice,
      required List<String> perItemTotal,
      required String billTotal,
      required String clientId}) async {
    String month = Utils.getCurrentMonthName();
    int year = Utils.getCurrentYear();
    String bill = Utils.generate6DigitUID();
    String date = Utils.getCurrentDate();

    try {
      dbRef
          .child('Clients')
          .child('Client Bills')
          .child(clientId)
          .child('$year')
          .child(month)
          .child(date)
          .child('B-$bill')
          .set({
        'billId': 'B-$bill',
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientContact': clientContact,
        'serialNumber': serialNumber,
        'date': date,
        'productName': productName,
        'productDescription': productDescription,
        'productQuantity': productQuantity,
        'perItemPrice': perItemPrice,
        'perItemTotal': perItemTotal,
        'billTotal': billTotal
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<List<ClientBill>> getClientBill({
    required String clientId,
    required String month,
    required String year,
  }) async {
    DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('Clients/Client Bills/$clientId/$year/$month');

    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;
    List<ClientBill> bills = [];
    try {
      if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> billEntries =
            snapshot.value as Map<dynamic, dynamic>;
        billEntries.forEach((dateKey, billData) {
          if (billData is Map) {
            billData.forEach((billId, data) {
              ClientBill bill = ClientBill(
                clientName: data['clientName'] ?? 'Unknown Client',
                clientAddress: data['clientAddress'] ?? 'Unknown Address',
                clientContact: data['clientContact'] ?? 'Unknown Contact',
                date: data['date'] ?? 'Unknown Date',
                billTotal: data['billTotal']?.toString() ?? '0.0',
                productNames: (data['productName'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                productDescriptions:
                    (data['productDescription'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [],
                productQuantities: (data['productQuantity'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                pricePerItems: (data['perItemPrice'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                perItemTotals: (data['perItemTotal'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                serialNumber: (data['serialNumber'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
                billId: data['billId'] ?? 'Unknown Bill',
              );

              bills.add(bill);
            });
          }
        });
      } else {
        print(
            "No data found for clientId: $clientId, Month: $month, Year: $year");
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }

    return bills;
  }

  static Future<void> deleteClientBill(
      {required String clientId,
      required String selectedYear,
      required String selectedMonth,
      required String billDate,
      required String billId}) async {
    try {
      dbRef
          .child('Clients')
          .child('Client Bills')
          .child(clientId)
          .child(selectedYear)
          .child(selectedMonth)
          .child(billDate)
          .child(billId)
          .remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> saveStockProduct(
      {required String productName,
      required String productDescription,
      required String productQuantity}) async {
    String productId = Utils.generate6DigitUID();

    try {
      await dbRef.child('Stocks').child(productId).set({
        'productId': productId,
        'productName': productName,
        'productDescription': productDescription,
        'productQuantity': productQuantity
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> editStock(
      {required String productName,
      required String productDescription,
      required String productId}) async {
    try {
      await dbRef.child('Stocks').child(productId).update({
        'productName': productName,
        'productDescription': productDescription,
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<void> deleteStock({required String productId}) async {
    try {
      await dbRef.child('Stocks').child(productId).remove();
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }

  static Future<List<StockModel>> getAllStock() async {
    try {
      DatabaseReference stockRef = dbRef.child('Stocks');
      DatabaseEvent event = await stockRef.once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> clientData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        List<StockModel> stocks = [];
        clientData.forEach((uid, value) {
          stocks.add(StockModel.fromJson(Map<String, dynamic>.from(value)));
        });

        return stocks;
      } else {
        return [];
      }
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
      rethrow;
    }
  }

  static Future<void> updateStockQuantity(
      {required String productQuantity, required String productId}) async {
    try {
      await dbRef.child('Stocks').child(productId).update({
        'productQuantity': productQuantity,
      });
    } catch (e) {
      Utils.showSnackBar('Error', 'An unknown error occurred.');
    }
  }
}
