class ClientModel {
  ClientModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.clientId
  });

  late String name;
  late String address;
  late String phone;
  late String clientId;

  ClientModel.fromJson(Map<String, dynamic> json) {
    name = json['clientName'] ?? "";
    address = json['clientAddress'] ?? "";
    phone = json['clientContact'] ?? "";
    clientId = json['clientId'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['clientName'] = name;
    data['clientAddress'] = address;
    data['clientContact'] = phone;
    data['clientId'] = clientId;
    return data;
  }
}
