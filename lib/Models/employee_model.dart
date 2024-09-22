class EmployeeModel {
  EmployeeModel(
      {required this.name,
      required this.fatherName,
      required this.idCard,
      required this.phone,
      required this.joiningDate,
      required this.designation,
      required this.salary,
       this.idFront,
       this.idBack});

  late String name;
  late String fatherName;
  late String idCard;
  late String phone;
  late String joiningDate;
  late String designation;
  late double salary;
   String? idFront;
   String? idBack;

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    fatherName = json['fatherName'] ?? "";
    idCard = json['idCard'] ?? "";
    salary = (json['salary'] ?? 0.0).toDouble();
    phone = json['phone'] ?? "";
    joiningDate = json['joiningDate'] ?? "";
    designation = json['designation'] ?? "";
    idFront = json['idFront'] ?? "";
    idBack = json['idBack'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['fatherName'] = fatherName;
    data['idCard'] = idCard;
    data['salary'] = salary;
    data['phone'] = phone;
    data['joiningDate'] = joiningDate;
    data['designation'] = designation;
    data['idFront'] = idFront;
    data['idBack'] = idBack;
    return data;
  }
}
