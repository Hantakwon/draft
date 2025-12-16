import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:testing/model/product.dart';

class ProductService {

  final String baseUrl = "http://10.0.2.2:8080/"; // 10.0.2.2

  Future<List<Product>> getProductList() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/getProduct'));

      log('GetProduct Processing...');

      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);

        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(response.statusCode);
      }
    }catch(err){
      throw Exception(err);
    }
  }
}