class EmployeeContractEarningModel {
  EmployeeContractEarningModel({
    required this.date,
    required this.noOfItems,
    required this.eUid,
  });

  late String date;
  late String noOfItems;
  late String eUid;

  EmployeeContractEarningModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    noOfItems = json['noOfItems'] ?? '';
    eUid = json['eUid'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = date;
    data['noOfItems'] = noOfItems;
    data['eUid'] = eUid;
    return data;
  }
}
