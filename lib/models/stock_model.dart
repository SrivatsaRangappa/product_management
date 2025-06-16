class StockModel {
  final String productName;
  final String productId;
  final double price;
  final int openingStock;
  final int closing;
  final int dispatch;
  final int receipt;

  StockModel(
      {required this.productName,
      required this.productId,
      required this.price,
      required this.openingStock,required this.closing,required this.dispatch,required this.receipt});

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      productName: json['productName'] ?? "Unknown",
      productId: json['SkuUpcEan'].toString(),
      price: (json['price'] ?? 0).toDouble(),
      openingStock: (json['openingStock'] ?? 0), 
      closing: (json['closing'] ?? 0), 
      dispatch: (json['actualQty'] ?? 0),
       receipt: (json['totalQty'] ?? 0),
    );
  }
}
