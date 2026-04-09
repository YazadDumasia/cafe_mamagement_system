class PaymentTransactionModel {
  final int? id;
  final int? invoiceId;
  final int? paymentModeId;

  final String? paymentMethodName;
  final double? amount;

  final String? transactionReference;
  final String? paymentStatus;

  final String? createdDate;

  PaymentTransactionModel({
    this.id,
    this.invoiceId,
    this.paymentModeId,
    this.paymentMethodName,
    this.amount,
    this.transactionReference,
    this.paymentStatus,
    this.createdDate,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'],
      invoiceId: json['invoiceId'],
      paymentModeId: json['paymentModeId'],
      paymentMethodName: json['paymentMethodName'],
      amount: (json['amount'] as num?)?.toDouble(),
      transactionReference: json['transactionReference'],
      paymentStatus: json['paymentStatus'],
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'paymentModeId': paymentModeId,
      'paymentMethodName': paymentMethodName,
      'amount': amount,
      'transactionReference': transactionReference,
      'paymentStatus': paymentStatus,
      'createdDate': createdDate,
    }..removeWhere((key, value) => value == null);
  }

  PaymentTransactionModel copyWith({
    int? id,
    int? invoiceId,
    int? paymentModeId,
    String? paymentMethodName,
    double? amount,
    String? transactionReference,
    String? paymentStatus,
    String? createdDate,
  }) {
    return PaymentTransactionModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentModeId: paymentModeId ?? this.paymentModeId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      amount: amount ?? this.amount,
      transactionReference: transactionReference ?? this.transactionReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  String toString() {
    return 'PaymentTransactionModel{id: $id, invoiceId: $invoiceId, paymentModeId: $paymentModeId, paymentMethodName: $paymentMethodName, amount: $amount, transactionReference: $transactionReference, paymentStatus: $paymentStatus, createdDate: $createdDate}';
  }
}
