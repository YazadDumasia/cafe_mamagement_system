import '../../widgets/widgets.dart';

class Employee extends ISuspensionBean {
  // 0 is false and 1 is for true

  Employee({
    this.id,
    this.hashID,
    this.name,
    this.phoneNumber,
    this.position,
    this.joiningDate,
    this.leavingDate,
    this.startWorkingTime,
    this.endWorkingTime,
    this.workingHours,
    this.creationDate,
    this.modificationDate,
    this.isDeleted,
  });

  factory Employee.fromMap(Map<String, dynamic> json) => Employee(
    id: json['id'],
    hashID: json['hashID'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    position: json['position'],
    joiningDate: json['joiningDate'],
    leavingDate: json['leavingDate'],
    startWorkingTime: json['startWorkingTime'],
    endWorkingTime: json['endWorkingTime'],
    workingHours: json['workingHours'],
    creationDate: json['creationDate'],
    modificationDate: json['modificationDate'],
    isDeleted: json['isDeleted'] ?? 0,
  );
  final int? id;
  String? hashID;
  final String? name;
  final String? phoneNumber;
  final String? position;
  String? joiningDate;
  String? leavingDate;
  String? startWorkingTime;
  String? endWorkingTime;
  String? workingHours;
  String? creationDate;
  String? modificationDate;
  int? isDeleted;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'hashID': hashID,
    'name': name,
    'creationDate': creationDate,
    'modificationDate': modificationDate,
    'phoneNumber': phoneNumber,
    'position': position,
    'joiningDate': joiningDate,
    'leavingDate': leavingDate,
    'startWorkingTime': startWorkingTime,
    'endWorkingTime': endWorkingTime,
    'workingHours': workingHours,
    'isDeleted': isDeleted ?? 0,
  }..removeWhere((key, value) => value == null);

  @override
  String toString() {
    return 'Employee{id: $id, hashID: $hashID, name: $name, phoneNumber: $phoneNumber, position: $position, joiningDate: $joiningDate, leavingDate: $leavingDate, startWorkingTime: $startWorkingTime, endWorkingTime: $endWorkingTime, workingHours: $workingHours, creationDate: $creationDate, modificationDate: $modificationDate, isDeleted: $isDeleted}';
  }

  @override
  String getSuspensionTag() {
    return name != null && name!.isNotEmpty ? name![0].toUpperCase() : '';
  }
}
