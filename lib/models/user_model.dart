class UserModel {
  final String token;
  final String warehouseId;

  UserModel({required this.token, required this.warehouseId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      warehouseId: json['warehouseId'],
    );
  }
}
