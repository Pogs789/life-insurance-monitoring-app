class CompanyProductsResponseModel {
  final String id;
  final String insuranceProductName;
  final String productContents;
  final double productAmount;
  final List<String> paymentTerms;

  CompanyProductsResponseModel({
    required this.id,
    required this.insuranceProductName,
    required this.productContents,
    required this.productAmount,
    required this.paymentTerms
  });

  factory CompanyProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return CompanyProductsResponseModel(
        id: json['id'],
        insuranceProductName: json['insuranceProductName'],
        productContents: json['productContents'],
        productAmount: double.parse(json['productAmount']),
        paymentTerms: List<String>.from(json['paymentTerms'])
    );
  }

  static List<CompanyProductsResponseModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (item) => CompanyProductsResponseModel.fromJson(item as Map<String, dynamic>),
    )
        .toList();
  }
}