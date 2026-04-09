class InvoiceModel {
  final int? id;
  final int? orderId;
  final String? invoiceHashId;

  final double? taxPercentage;
  final int? discountType;
  final double? discountAmount;

  final double? totalCost;
  final double? taxCost;
  final double? taxableAmount;
  final double? netPaymentAmount;

  final String? createdDate;
  final String? modifiedDate;

  final int? customerId;
  final String? customerName;
  final String? phoneNumber;

  final int? paymentModeId;
  final String? paymentMethodName;

  final double? recordAmountPaid;
  final String? paymentMethodDetails;

  InvoiceModel({
    this.id,
    this.orderId,
    this.invoiceHashId,
    this.taxPercentage,
    this.discountType,
    this.discountAmount,
    this.totalCost,
    this.taxCost,
    this.taxableAmount,
    this.netPaymentAmount,
    this.createdDate,
    this.modifiedDate,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.paymentModeId,
    this.paymentMethodName,
    this.recordAmountPaid,
    this.paymentMethodDetails,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      orderId: json['orderId'],
      invoiceHashId: json['invoiceHashId'],
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble(),
      discountType: json['discountType'],
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      taxCost: (json['taxCost'] as num?)?.toDouble(),
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble(),
      netPaymentAmount: (json['netPaymentAmount'] as num?)?.toDouble(),
      createdDate: json['createdDate'],
      modifiedDate: json['modifiedDate'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      paymentModeId: json['paymentModeId'],
      paymentMethodName: json['paymentMethodName'],
      recordAmountPaid: (json['recordAmountPaid'] as num?)?.toDouble(),
      paymentMethodDetails: json['paymentMethodDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'invoiceHashId': invoiceHashId,
      'taxPercentage': taxPercentage,
      'discountType': discountType,
      'discountAmount': discountAmount,
      'totalCost': totalCost,
      'taxCost': taxCost,
      'taxableAmount': taxableAmount,
      'netPaymentAmount': netPaymentAmount,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
      'customerId': customerId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'paymentModeId': paymentModeId,
      'paymentMethodName': paymentMethodName,
      'recordAmountPaid': recordAmountPaid,
      'paymentMethodDetails': paymentMethodDetails,
    }..removeWhere((key, value) => value == null);
  }

  InvoiceModel copyWith({
    int? id,
    int? orderId,
    String? invoiceHashId,
    double? taxPercentage,
    int? discountType,
    double? discountAmount,
    double? totalCost,
    double? taxCost,
    double? taxableAmount,
    double? netPaymentAmount,
    String? createdDate,
    String? modifiedDate,
    int? customerId,
    String? customerName,
    String? phoneNumber,
    int? paymentModeId,
    String? paymentMethodName,
    double? recordAmountPaid,
    String? paymentMethodDetails,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      invoiceHashId: invoiceHashId ?? this.invoiceHashId,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      discountType: discountType ?? this.discountType,
      discountAmount: discountAmount ?? this.discountAmount,
      totalCost: totalCost ?? this.totalCost,
      taxCost: taxCost ?? this.taxCost,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      netPaymentAmount: netPaymentAmount ?? this.netPaymentAmount,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentModeId: paymentModeId ?? this.paymentModeId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      recordAmountPaid: recordAmountPaid ?? this.recordAmountPaid,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
    );
  }

  @override
  String toString() {
    return 'InvoiceModel{id: $id, orderId: $orderId, invoiceHashId: $invoiceHashId, taxPercentage: $taxPercentage, discountType: $discountType, discountAmount: $discountAmount, totalCost: $totalCost, taxCost: $taxCost, taxableAmount: $taxableAmount, netPaymentAmount: $netPaymentAmount, createdDate: $createdDate, modifiedDate: $modifiedDate, customerId: $customerId, customerName: $customerName, phoneNumber: $phoneNumber, paymentModeId: $paymentModeId, paymentMethodName: $paymentMethodName, recordAmountPaid: $recordAmountPaid, paymentMethodDetails: $paymentMethodDetails}';
  }
}
