import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/http_exeption..dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String? email, String? password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCL5pJfBKkRMfGv8STDBQK5m45MVKwlH-c';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      final pref = await SharedPreferences.getInstance();
      final userData = json.encode(
          {'token': _token, 'userId': _userId, 'expiryDate': _expiryDate});
      pref.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryOutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }
    final extaractedData =
        json.decode(pref.getString('userData')!) as Map<String, Object>;
    final date = DateTime.parse(extaractedData['expiryDate'].toString());
    if (date.isBefore(DateTime.now())) {
      return false;
    }

    _token = extaractedData['token'].toString();
    _userId = extaractedData['userId'].toString();
    _expiryDate = date;
    notifyListeners();
    return true;
  }

  Future<void> sighnup(String? email, String? password) async {
    _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }
}
