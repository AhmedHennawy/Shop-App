import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(
      String productId, String token, String userId) async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/userFavorites/$userId/$productId.json?auth=$token';
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.put(Uri.parse(url),
        body: json.encode(
          isFavorite,
        ));
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
