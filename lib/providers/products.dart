import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
import '../models/http_exeption..dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? authToken;
  String? userId;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  void updateToken(String? token, String? userId) {
    this.authToken = token;
    this.userId = userId;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      url =
          'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> temp = [];
      data.forEach((prodId, prodData) {
        temp.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = temp;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product newproduct) async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final value = await http.post(Uri.parse(url),
          body: json.encode({
            'title': newproduct.title,
            'description': newproduct.description,
            'price': newproduct.price,
            'imageUrl': newproduct.imageUrl,
            'creatorId': userId,
          }));

      final pro = Product(
          id: json.decode(value.body)['name'],
          title: newproduct.title,
          description: newproduct.description,
          price: newproduct.price,
          imageUrl: newproduct.imageUrl);
      _items.add(pro);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/products/${newProduct.id}.json?auth=$authToken';
    try {
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      final productIndex =
          _items.indexWhere((element) => element.id == newProduct.id);

      _items[productIndex] = newProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeProduct(String id) async {
    final url =
        'https://flutter-shop-app-b01f4-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      throw HttpException('Deleting Failed');
    }
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
