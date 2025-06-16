class CustomerModel {
  final String id;
  final String name;

  CustomerModel({required this.id, required this.name});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'].toString(),
      name: json['businessName'] ?? "Unknown",  
    );
  }
}
