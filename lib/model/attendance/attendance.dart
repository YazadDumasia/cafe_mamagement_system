class Attendance {
  Attendance({
    this.id,
    this.employeeId,
    this.currentStatus,
    this.isDeleted,
    this.creationDate,
    this.modificationDate,
    this.checkIn,
    this.checkOut,
    this.employeeWorkingDurations,
    this.workingTimeDurations,
  });

  factory Attendance.fromMap(Map<String, dynamic> json) => Attendance(
    id: json['id'],
    employeeId: json['employeeId'],
    currentStatus: json['currentStatus'],
    isDeleted: json['isDeleted'] ?? 0,
    creationDate: json['creationDate'],
    modificationDate: json['modificationDate'],
    checkIn: json['checkIn'],
    checkOut: json['checkOut'],
    employeeWorkingDurations: json['employeeWorkingDurations'],
    workingTimeDurations: json['workingTimeDurations'],
  );
  int? id;
  int? employeeId;
  int? currentStatus;
  int? isDeleted; // 0 is false and 1 is for true
  String? checkIn;
  String? checkOut;
  String? employeeWorkingDurations;
  String? workingTimeDurations;
  String? creationDate;
  String? modificationDate;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'employeeId': employeeId,
    'currentStatus': currentStatus,
    'isDeleted': isDeleted ?? 0,
    'creationDate': creationDate,
    'modificationDate': modificationDate,
    'checkIn': checkIn,
    'checkOut': checkOut,
    'employeeWorkingDurations': employeeWorkingDurations,
    'workingTimeDurations': workingTimeDurations,
  }..removeWhere((key, value) => value == null);

  @override
  String toString() {
    return 'Attendance{id: $id, employeeId: $employeeId, currentStatus: $currentStatus, isDeleted: $isDeleted, checkIn: $checkIn, checkOut: $checkOut, employeeWorkingDurations: $employeeWorkingDurations, workingTimeDurations: $workingTimeDurations, creationDate: $creationDate, modificationDate: $modificationDate}';
  }
}
