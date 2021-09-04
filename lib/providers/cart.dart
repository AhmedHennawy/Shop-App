import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount{
    return _items.length;
  }

  double get totalPrice{
    var total = 0.0;
    _items.forEach((key, value) { 
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (item) => CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              quantity: item.quantity + 1));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              price: price,
              title: title,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId){
    if(_items[productId]!.quantity > 1){
      _items.update(
          productId,
          (item) => CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              quantity: item.quantity - 1));
    }else{
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear(){
    _items = {};
    notifyListeners();
  }
}
