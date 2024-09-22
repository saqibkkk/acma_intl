class EmployeeFinancialsModel {
  EmployeeFinancialsModel(
      {required this.date,
      required this.receivedAmount,
      required this.receivable,
      required this.receivedStatus,
      required this.receivableDescription,
      required this.fUid});

  late String date;
  late String receivedAmount;
  late String receivable;
  late String receivedStatus;
  late String receivableDescription;
  late String fUid;

  EmployeeFinancialsModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? '';
    receivedAmount = json['receivedAmount'] ?? '';
    receivable = json['receivable'] ?? '';
    fUid = json['fUid'] ?? '';
    receivedStatus = json['receivedStatus'] ?? '';
    receivableDescription = json['receivableDescription'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = date;
    data['receivedAmount'] = receivedAmount;
    data['receivable'] = receivable;
    data['fUid'] = fUid;
    data['receivedStatus'] = receivedStatus;
    data['receivableDescription'] = receivableDescription;
    return data;
  }
}
