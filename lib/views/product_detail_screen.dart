import 'package:flutter/material.dart';
import 'package:product_mgmt_app/models/stock_model.dart';
import 'package:product_mgmt_app/widgets/appbar.dart';

class ProductDetailScreen extends StatelessWidget {
  final StockModel product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: const DefaultAppBar(title: "Product Detail"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(title: Text(
                  product.productId,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ) ,
                subtitle: Text(
                  product.productName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            const SizedBox(height: 10),
          GridView.count(
              shrinkWrap: true, 
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _buildStockCard("Opening", product.openingStock.toString(),
                    Icons.login_rounded, Colors.red),
                _buildStockCard("Receipt", product.receipt.toString(),
                    Icons.receipt_long_rounded, Colors.blue),
                _buildStockCard("Dispatch", product.dispatch.toString(),
                    Icons.local_shipping_rounded, Colors.pink),
                _buildStockCard("Closing", product.closing.toString(),
                    Icons.inventory_rounded, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(String label, String value, IconData icon, Color iconColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16)),
                Icon(icon, color: iconColor),
              ],
            ),
            Text(value, style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
