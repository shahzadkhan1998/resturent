import 'package:flutter/foundation.dart';
import 'package:resturent/models/cart_item.dart';
import 'package:resturent/models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount => _items.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  int get itemCount => _items.length;

  void addItem(CartItem cartItem) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menuItem.id == cartItem.menuItem.id &&
          item.selectedSize == cartItem.selectedSize &&
          listEquals(item.selectedExtras, cartItem.selectedExtras),
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        menuItem: cartItem.menuItem,
        quantity: _items[existingIndex].quantity + cartItem.quantity,
        selectedSize: cartItem.selectedSize,
        selectedExtras: cartItem.selectedExtras,
        totalPrice: (_items[existingIndex].totalPrice /
                _items[existingIndex].quantity) *
            (_items[existingIndex].quantity + cartItem.quantity),
        specialInstructions: cartItem.specialInstructions,
      );
    } else {
      _items.add(cartItem);
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final menuItem = _items[index].menuItem;
        _items[index] = CartItem(
          menuItem: menuItem,
          quantity: quantity,
          selectedSize: _items[index].selectedSize,
          selectedExtras: _items[index].selectedExtras,
          totalPrice: menuItem.finalPrice * quantity,
          specialInstructions: _items[index].specialInstructions,
        );
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
