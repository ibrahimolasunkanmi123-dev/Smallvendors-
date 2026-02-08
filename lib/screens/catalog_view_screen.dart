import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/product.dart';

class CatalogViewScreen extends StatelessWidget {
  final Vendor vendor;
  final List<Product> products;

  const CatalogViewScreen({super.key, required this.vendor, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${vendor.businessName} Catalog'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text('${product.category} • \$${product.price.toStringAsFixed(2)}'),
              trailing: Icon(
                product.isAvailable ? Icons.check_circle : Icons.cancel,
                color: product.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}