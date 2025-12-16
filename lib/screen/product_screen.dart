import 'package:flutter/material.dart';
import 'package:testing/model/product.dart';
import 'package:testing/service/product_service.dart';

class ProductListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  final service = ProductService();

  late Future<List<Product>> futureProductList;

  @override
  void initState() {
    super.initState();
    futureProductList = service.getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('상품 목록'),),
        body: FutureBuilder(
            future: futureProductList, // Future 비동기 처리 결과 참조
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }

              final productList = snapshot.data ?? [];

              if (productList.isEmpty) {
                return const Center(child: Text('상품이 없습니다.'));
              }

              return ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return ProductListScreen();
                  }
              );
            }
        )
    );
  }
}