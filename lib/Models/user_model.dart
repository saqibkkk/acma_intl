class UserModel {
  UserModel({
    required this.photo,
    required this.name,
    required this.id,
    required this.email,
  });
  late String photo;
  late String name;
  late String id;
  late String email;

  UserModel.fromJson(Map<String, dynamic> json){
    photo = json['photo'] ?? "";
    name = json['name'] ?? "";
    id = json['id'] ?? "";
    email = json['email'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['photo'] = photo;
    data['name'] = name;
    data['id'] = id;
    data['email'] = email;

    return data;
  }
}