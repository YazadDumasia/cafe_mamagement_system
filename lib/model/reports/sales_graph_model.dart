class SalesGraphModel {
  final String? saleDate;
  final double? totalSales;
  final int? invoiceCount;

  SalesGraphModel({this.saleDate, this.totalSales, this.invoiceCount});

  factory SalesGraphModel.fromJson(Map<String, dynamic> json) {
    return SalesGraphModel(
      saleDate: json['saleDate'],
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      invoiceCount: json['invoiceCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleDate': saleDate,
      'totalSales': totalSales,
      'invoiceCount': invoiceCount,
    }..removeWhere((k, v) => v == null);
  }

  SalesGraphModel copyWith({
    String? saleDate,
    double? totalSales,
    int? invoiceCount,
  }) {
    return SalesGraphModel(
      saleDate: saleDate ?? this.saleDate,
      totalSales: totalSales ?? this.totalSales,
      invoiceCount: invoiceCount ?? this.invoiceCount,
    );
  }

  @override
  String toString() {
    return 'SalesGraphModel(saleDate: $saleDate, totalSales: $totalSales, invoiceCount: $invoiceCount)';
  }
}
