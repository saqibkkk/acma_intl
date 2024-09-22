class EmployeeContractModel {
  EmployeeContractModel(
      {required this.date,
      required this.contractName,
      required this.contractDescription,
      required this.contractItemName,
      required this.contractPerItemRate,
      required this.cUid});

  late String date;
  late String contractName;
  late String contractDescription;
  late String contractItemName;
  late String contractPerItemRate;
  late String cUid;

  EmployeeContractModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    contractName = json['contractName'] ?? '';
    contractDescription = json['contractDescription'] ?? '';
    cUid = json['cUid'] ?? '';
    contractItemName = json['contractItemName'] ?? '';
    contractPerItemRate = json['contractPerItemRate'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = date;
    data['contractName'] = contractName;
    data['contractDescription'] = contractDescription;
    data['cUid'] = cUid;
    data['contractItemName'] = contractItemName;
    data['contractPerItemRate'] = contractPerItemRate;
    return data;
  }
}
