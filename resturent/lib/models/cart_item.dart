import 'package:resturent/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;
  String? selectedSize;
  List<String> selectedExtras;
  final double totalPrice;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
    this.selectedSize,
    this.selectedExtras = const [],
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'menuItem': menuItem.toJson(),
        'quantity': quantity,
        'specialInstructions': specialInstructions,
        'selectedSize': selectedSize,
        'selectedExtras': selectedExtras,
        'totalPrice': totalPrice,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        menuItem: MenuItem.fromJson(json['menuItem']),
        quantity: json['quantity'],
        specialInstructions: json['specialInstructions'],
        selectedSize: json['selectedSize'],
        selectedExtras: List<String>.from(json['selectedExtras'] ?? []),
        totalPrice: json['totalPrice'].toDouble(),
      );
}
