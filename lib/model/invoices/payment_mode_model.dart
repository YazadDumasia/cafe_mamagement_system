class PaymentModeModel {
  final int? id;
  final String? paymentMethodName;
  final String? uniqueHashId;

  PaymentModeModel({this.id, this.paymentMethodName, this.uniqueHashId});

  factory PaymentModeModel.fromJson(Map<String, dynamic> json) {
    return PaymentModeModel(
      id: json['id'],
      paymentMethodName: json['paymentMethodName'],
      uniqueHashId: json['uniqueHashId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethodName': paymentMethodName,
      'uniqueHashId': uniqueHashId,
    }..removeWhere((key, value) => value == null);
  }

  PaymentModeModel copyWith({
    int? id,
    String? paymentMethodName,
    String? uniqueHashId,
  }) {
    return PaymentModeModel(
      id: id ?? this.id,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      uniqueHashId: uniqueHashId ?? this.uniqueHashId,
    );
  }

  @override
  String toString() {
    return 'PaymentModeModel{id: $id, paymentMethodName: $paymentMethodName, uniqueHashId: $uniqueHashId}';
  }
}
