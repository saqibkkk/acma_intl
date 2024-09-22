class StockModel {
  StockModel(
      {required this.productName,
      required this.productDescription,
      required this.productQuantity,
      required this.productId});

  late String productName;
  late String productDescription;
  late String productQuantity;
  late String productId;

  StockModel.fromJson(Map<String, dynamic> json) {
    productName = json['productName'] ?? "";
    productDescription = json['productDescription'] ?? "";
    productQuantity = json['productQuantity'] ?? "";
    productId = json['productId'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['productQuantity'] = productQuantity;
    data['productId'] = productId;
    return data;
  }
}
