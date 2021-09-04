import 'dart:convert';

import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;


  List<OrderItem> get orders {
    return [..._orders];
  }

    void updateToken(String? token,String? userId){
    this.authToken = token;
    this.userId = userId;
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final  data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) {
        return;
      }
      final List<OrderItem> temp = [];
      data.forEach((orderId, orderData) {
        temp.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    price: e['price'],
                    quantity: e['quantity']))
                .toList()));
      });
      _orders = temp;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> productItems, double total) async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final dateTemp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'date': dateTemp.toIso8601String(),
          'products': productItems
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: productItems,
            date: dateTemp));
    notifyListeners();
  }
}
