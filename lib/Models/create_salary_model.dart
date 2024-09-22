class CreateSalaryModel {
  CreateSalaryModel({
    required this.dailyStartTime,
    required this.dailyEndTime,
  });

  late String dailyStartTime;
  late String dailyEndTime;

  CreateSalaryModel.fromJson(Map<String, dynamic> json) {
    dailyStartTime = json['dailyStartTime'] ?? "";
    dailyEndTime = json['dailyEndTime'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dailyStartTime'] = dailyStartTime;
    data['dailyEndTime'] = dailyEndTime;

    return data;
  }

  @override
  String toString() {
    return 'CreateSalaryModel( dailyStartTime: $dailyStartTime, dailyEndTime: $dailyEndTime)';
  }
}
