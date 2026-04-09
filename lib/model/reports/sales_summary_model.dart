class DailySalesSummaryModel {
  final int? totalInvoices;
  final double? totalSales;
  final double? totalTax;
  final double? totalDiscount;
  final double? totalPaid;

  DailySalesSummaryModel({
    this.totalInvoices,
    this.totalSales,
    this.totalTax,
    this.totalDiscount,
    this.totalPaid,
  });

  factory DailySalesSummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySalesSummaryModel(
      totalInvoices: json['totalInvoices'] as int?,
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalTax: (json['totalTax'] as num?)?.toDouble(),
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvoices': totalInvoices,
      'totalSales': totalSales,
      'totalTax': totalTax,
      'totalDiscount': totalDiscount,
      'totalPaid': totalPaid,
    }..removeWhere((key, value) => value == null);
  }

  DailySalesSummaryModel copyWith({
    int? totalInvoices,
    double? totalSales,
    double? totalTax,
    double? totalDiscount,
    double? totalPaid,
  }) {
    return DailySalesSummaryModel(
      totalInvoices: totalInvoices ?? this.totalInvoices,
      totalSales: totalSales ?? this.totalSales,
      totalTax: totalTax ?? this.totalTax,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      totalPaid: totalPaid ?? this.totalPaid,
    );
  }

  @override
  String toString() {
    return 'DailySalesSummaryModel(totalInvoices: $totalInvoices, totalSales: $totalSales, totalTax: $totalTax, totalDiscount: $totalDiscount, totalPaid: $totalPaid)';
  }
}
