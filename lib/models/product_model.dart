class ProductModel {
  final String id;
  final String name;
  final int stock;
  final double price;

  ProductModel({required this.id, required this.name, required this.stock,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      stock: json['stock'] ?? 0,
        price: json['price'] ?? 0,
    );
  }
}
