class InvoiceItemModel {
  final int? id;
  final int? invoiceId;
  final int? orderItemId;

  final int? itemId;
  final String? itemName;

  final int? quantity;
  final double? sellingPrice;
  final double? totalPrice;

  final double? taxPercentage;
  final double? taxAmount;
  final double? discountAmount;

  final String? createdDate;

  InvoiceItemModel({
    this.id,
    this.invoiceId,
    this.orderItemId,
    this.itemId,
    this.itemName,
    this.quantity,
    this.sellingPrice,
    this.totalPrice,
    this.taxPercentage,
    this.taxAmount,
    this.discountAmount,
    this.createdDate,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      invoiceId: json['invoiceId'],
      orderItemId: json['orderItemId'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'orderItemId': orderItemId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'totalPrice': totalPrice,
      'taxPercentage': taxPercentage,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'createdDate': createdDate,
    }..removeWhere((key, value) => value == null);
  }

  @override
  String toString() {
    return 'InvoiceItemModel{id: $id, invoiceId: $invoiceId, orderItemId: $orderItemId, itemId: $itemId, itemName: $itemName, quantity: $quantity, sellingPrice: $sellingPrice, totalPrice: $totalPrice, taxPercentage: $taxPercentage, taxAmount: $taxAmount, discountAmount: $discountAmount, createdDate: $createdDate}';
  }

  InvoiceItemModel copyWith({
    int? id,
    int? invoiceId,
    int? orderItemId,
    int? itemId,
    String? itemName,
    int? quantity,
    double? sellingPrice,
    double? totalPrice,
    double? taxPercentage,
    double? taxAmount,
    double? discountAmount,
    String? createdDate,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      orderItemId: orderItemId ?? this.orderItemId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
