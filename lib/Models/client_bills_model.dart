class ClientBill {
  final String clientName;
  final String clientAddress;
  final String clientContact;
  final String date;
  final String billTotal;
  final List<String> productNames;
  final List<String> productDescriptions;
  final List<String> productQuantities;
  final List<String> pricePerItems;
  final List<String> perItemTotals;
  final List<String> serialNumber;
  final String billId;

  ClientBill({
    required this.billId,
    required this.clientName,
    required this.clientAddress,
    required this.clientContact,
    required this.date,
    required this.billTotal,
    required this.productNames,
    required this.productDescriptions,
    required this.productQuantities,
    required this.pricePerItems,
    required this.perItemTotals,
    required this.serialNumber,
  });
}
