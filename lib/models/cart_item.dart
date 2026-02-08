import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  String get productName => product.name;
  String get productId => product.id;
  double get price => product.price;
  String get imagePath => product.imagePath ?? '';

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    product: Product.fromJson(json['product']),
    quantity: json['quantity'],
  );
}