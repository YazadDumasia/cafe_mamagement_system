class SalesForecastModel {
  final String? date;
  final double? actualSales;
  final double? predictedSales;

  SalesForecastModel({this.date, this.actualSales, this.predictedSales});

  factory SalesForecastModel.fromJson(Map<String, dynamic> json) {
    return SalesForecastModel(
      date: json['date'],
      actualSales: (json['actualSales'] as num?)?.toDouble(),
      predictedSales: (json['predictedSales'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'actualSales': actualSales,
      'predictedSales': predictedSales,
    }..removeWhere((k, v) => v == null);
  }

  SalesForecastModel copyWith({
    String? date,
    double? actualSales,
    double? predictedSales,
  }) {
    return SalesForecastModel(
      date: date ?? this.date,
      actualSales: actualSales ?? this.actualSales,
      predictedSales: predictedSales ?? this.predictedSales,
    );
  }

  @override
  String toString() {
    return 'SalesForecastModel(date: $date, actualSales: $actualSales, predictedSales: $predictedSales)';
  }
}
