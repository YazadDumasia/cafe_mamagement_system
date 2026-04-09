import '../../model/attendance/attendance.dart';
import '../../model/attendance/employee.dart';
import '../../model/attendance/leave.dart';
import 'package:sqflite/sqflite.dart';
import '../../utils/components/date_util.dart';
import '../database_tables.dart';

class EmployeesDao {
  final Database db;

  EmployeesDao(this.db);

  // Employee CRUD operations

  /// Insert a new employee record
  Future<int> addEmployee(Employee employee) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(DatabaseTables.employeesTable, employee.toMap());
    });
  }

  /// Update an existing employee record
  Future<int> updateEmployee(Employee employee) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.update(
        DatabaseTables.employeesTable,
        employee.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[employee.id],
      );
    });
  }

  /// Soft delete an employee by marking `isDeleted` and update the modification date
  Future<int> deleteSoftEmployee(int id) async {
    return await db.transaction<int>((Transaction txn) async {
      final currentDate = DateUtil.dateToString(
        DateTime.now(),
        DateUtil.dateFormat15,
      );
      return await txn.update(
        DatabaseTables.employeesTable,
        <String, Object?>{'isDeleted': 1, 'modificationDate': currentDate},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  /// Permanently delete an employee record
  Future<int> deletePermanentEmployee(int id) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.delete(
        DatabaseTables.employeesTable,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  /// Fetch all non-deleted employees ordered by descending id
  Future<List<Employee>> getEmployees() async {
    return await db.transaction<List<Employee>>((Transaction txn) async {
      final List<Map<String, Object?>> res = await txn.query(
        DatabaseTables.employeesTable,
        where: 'isDeleted = ?',
        whereArgs: <Object?>[0], // Only not deleted employees
        orderBy: 'id DESC',
      );
      return List<Employee>.generate(
        res.length,
        (i) => Employee.fromMap(res[i]),
      );
    });
  }

  /// Fetch a paginated list of non-deleted employees, ordered by descending id
  Future<List<Employee>> getEmployeesPaged({
    int pageNumber = 1, // Default to page 1
    int limit = 20, // Default to 20 items per page
  }) async {
    return await db.transaction<List<Employee>>((Transaction txn) async {
      final int offset = (pageNumber - 1) * limit;
      final List<Map<String, Object?>> res = await txn.query(
        DatabaseTables.employeesTable,
        where: 'isDeleted = ?',
        whereArgs: <Object?>[0],
        // Only not deleted employees
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );
      return List<Employee>.generate(
        res.length,
        (i) => Employee.fromMap(res[i]),
      );
    });
  }

  // Attendance CRUD operations

  /// Fetch all non-deleted attendance records ordered by descending id
  Future<List<Attendance>?> getAttendance() async {
    return await db.transaction<List<Attendance>?>((txn) async {
      final List<Map<String, Object?>> res = await txn.query(
        DatabaseTables.attendanceTable,
        where: 'isDeleted = ?',
        whereArgs: <Object?>[0], // 0 for false
        orderBy: 'id DESC',
      );
      return res.isNotEmpty
          ? List<Attendance>.generate(
              res.length,
              (i) => Attendance.fromMap(res[i]),
            )
          : <Attendance>[];
    });
  }

  /// Insert a new attendance record
  Future<int> addAttendance(Attendance attendance) async {
    return await db.transaction<int>((txn) async {
      final Batch batch = txn.batch();
      batch.insert(DatabaseTables.attendanceTable, attendance.toMap());
      final List<dynamic> results = await batch.commit(noResult: false);
      return results.isNotEmpty && results[0] is int ? results[0] as int : 0;
    });
  }

  /// Update an existing attendance record
  Future<int> updateAttendance(Attendance attendance) async {
    return await db.transaction<int>((txn) async {
      final Batch batch = txn.batch();
      batch.update(
        DatabaseTables.attendanceTable,
        attendance.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[attendance.id],
      );
      final List<dynamic> results = await batch.commit(noResult: false);
      return results.isNotEmpty && results[0] is int ? results[0] as int : 0;
    });
  }

  /// Soft delete an attendance record by marking `isDeleted` and update the modification date
  Future<int> deleteAttendance(int id) async {
    final String? currentDate = DateUtil.dateToString(
      DateTime.now(),
      DateUtil.dateFormat15,
    );
    return await db.transaction<int>((txn) async {
      final Batch batch = txn.batch();
      batch.update(
        DatabaseTables.attendanceTable,
        <String, Object?>{'isDeleted': 1, 'modificationDate': currentDate},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
      final List<dynamic> results = await batch.commit(noResult: false);
      return results.isNotEmpty && results[0] is int ? results[0] as int : 0;
    });
  }

  /// Permanently delete an attendance record by id
  Future<int> deletePermanentlyAttendance(int id) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.delete(
        DatabaseTables.attendanceTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // CRUD operations for LeaveModel

  ///Get all non-deleted leaves
  Future<List<Leave>> getLeaves() async {
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.leavesTable,
      where: 'isDeleted = ?',
      whereArgs: <Object?>[0],
      orderBy: 'id DESC',
    );
    return res.isNotEmpty
        ? List<Leave>.generate(res.length, (int i) => Leave.fromMap(res[i]))
        : <Leave>[];
  }

  ///Insert a new leave record
  Future<int> addLeave(Leave leave) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(DatabaseTables.leavesTable, leave.toMap());
    });
  }

  ///Update a single leave record
  Future<int> updateLeave(Leave leave) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.update(
        DatabaseTables.leavesTable,
        leave.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[leave.id],
      );
    });
  }

  ///Update multiple leave records in batch
  Future<void> updateLeavesBatch(List<Leave> leaves) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (Leave leave in leaves) {
        batch.update(
          DatabaseTables.leavesTable,
          leave.toMap(),
          where: 'id = ?',
          whereArgs: <Object?>[leave.id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  ///Soft delete a leave record
  Future<int> deleteLeave(int id) async {
    return await db.transaction((Transaction txn) async {
      return await txn.update(
        DatabaseTables.leavesTable,
        <String, Object?>{
          'isDeleted': 1,
          'modificationDate': DateUtil.dateToString(
            DateTime.now(),
            DateUtil.dateFormat15,
          ),
        },
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  ///Hard delete a leave record (permanent)
  Future<int> deleteLeavePermanent(int id) async {
    return await db.transaction((Transaction txn) async {
      return await txn.delete(
        DatabaseTables.leavesTable,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }
}
