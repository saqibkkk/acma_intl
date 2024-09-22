class EmployeeAttendanceModel {
  EmployeeAttendanceModel({
    required this.startTime,
    required this.endTime,
    required this.currentDate,
    required this.dailyHours
  });

  late String startTime;
  late String endTime;
  late String currentDate;
  late String dailyHours;


  EmployeeAttendanceModel.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'] ?? '';
    endTime = json['endTime'] ?? '';
    currentDate = json['currentDate'] ?? '';
    dailyHours = json['dailyHours'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['currentDate'] = currentDate;
    data['dailyHours'] = dailyHours;
    return data;
  }
}
