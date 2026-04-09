class TopSellingItemModel {
  final String? itemName;
  final int? totalQuantity;
  final double? totalRevenue;

  TopSellingItemModel({this.itemName, this.totalQuantity, this.totalRevenue});

  factory TopSellingItemModel.fromJson(Map<String, dynamic> json) {
    return TopSellingItemModel(
      itemName: json['itemName'],
      totalQuantity: json['totalQuantity'] as int?,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'totalQuantity': totalQuantity,
      'totalRevenue': totalRevenue,
    }..removeWhere((k, v) => v == null);
  }

  TopSellingItemModel copyWith({
    String? itemName,
    int? totalQuantity,
    double? totalRevenue,
  }) {
    return TopSellingItemModel(
      itemName: itemName ?? this.itemName,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }

  @override
  String toString() {
    return 'TopSellingItemModel(itemName: $itemName, totalQuantity: $totalQuantity, totalRevenue: $totalRevenue)';
  }
}
