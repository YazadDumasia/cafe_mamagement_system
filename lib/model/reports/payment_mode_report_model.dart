class PaymentModeReportModel {
  final String? paymentMethodName;
  final double? totalAmount;
  final int? totalTransactions;

  PaymentModeReportModel({
    this.paymentMethodName,
    this.totalAmount,
    this.totalTransactions,
  });

  factory PaymentModeReportModel.fromJson(Map<String, dynamic> json) {
    return PaymentModeReportModel(
      paymentMethodName: json['paymentMethodName'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      totalTransactions: json['totalTransactions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodName': paymentMethodName,
      'totalAmount': totalAmount,
      'totalTransactions': totalTransactions,
    }..removeWhere((k, v) => v == null);
  }

  PaymentModeReportModel copyWith({
    String? paymentMethodName,
    double? totalAmount,
    int? totalTransactions,
  }) {
    return PaymentModeReportModel(
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      totalAmount: totalAmount ?? this.totalAmount,
      totalTransactions: totalTransactions ?? this.totalTransactions,
    );
  }

  @override
  String toString() {
    return 'PaymentModeReportModel(paymentMethodName: $paymentMethodName, totalAmount: $totalAmount, totalTransactions: $totalTransactions)';
  }
}
