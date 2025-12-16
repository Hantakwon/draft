class Product{
  final int proId;
  final String proName;
  final String proDesc;
  final int proPrice;

  Product({
    required this.proId,
    required this.proName,
    required this.proDesc,
    required this.proPrice
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      proId: json['proId'],
      proName: json['proName'],
      proDesc: json['proDesc'],
      proPrice: json['proPrice'],
    );
  }
}