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
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final url =
        'https://shopapp-b3495.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';

    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      ///Error response
      if (response.statusCode >= 400) {
        setFavoriteValue(oldStatus);
      }
    } catch (error) {
      setFavoriteValue(oldStatus);
    }
  }

  void setFavoriteValue(bool oldStatus) {
    isFavorite = oldStatus;
    notifyListeners();
  }
}
