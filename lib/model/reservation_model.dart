class ReservationModel {
  int? id;
  String? customerName;
  String? phoneNumber;
  int? customerId;
  int? tableId;
  String? tableName;
  String? reservationDateTime;
  int? numberOfPeople;
  int? status; // 0: Pending, 1: Confirmed, 2: Cancelled, 3: Completed
  String? notes;
  String? creationDate;
  String? modificationDate;

  ReservationModel({
    this.id,
    this.customerName,
    this.phoneNumber,
    this.customerId,
    this.tableId,
    this.tableName,
    this.reservationDateTime,
    this.numberOfPeople,
    this.status = 0,
    this.notes,
    this.creationDate,
    this.modificationDate,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      customerId: json['customerId'],
      tableId: json['tableId'],
      tableName: json['tableName'],
      reservationDateTime: json['reservationDateTime'],
      numberOfPeople: json['numberOfPeople'],
      status: json['status'],
      notes: json['notes'],
      creationDate: json['creationDate'],
      modificationDate: json['modificationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'customerId': customerId,
      'tableId': tableId,
      'tableName': tableName,
      'reservationDateTime': reservationDateTime,
      'numberOfPeople': numberOfPeople,
      'status': status,
      'notes': notes,
      'creationDate': creationDate,
      'modificationDate': modificationDate,
    }..removeWhere((key, value) => value == null);
  }

  ReservationModel copyWith({
    int? id,
    String? customerName,
    String? phoneNumber,
    int? customerId,
    int? tableId,
    String? tableName,
    String? reservationDateTime,
    int? numberOfPeople,
    int? status,
    String? notes,
    String? creationDate,
    String? modificationDate,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      customerId: customerId ?? this.customerId,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      reservationDateTime: reservationDateTime ?? this.reservationDateTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
    );
  }

  @override
  String toString() {
    return 'ReservationModel(id: $id, customerName: $customerName, table: $tableName, dateTime: $reservationDateTime, status: $status)';
  }
}
