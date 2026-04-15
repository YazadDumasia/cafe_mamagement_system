import 'package:sqflite/sqflite.dart';
import '../../model/reservation_model.dart';
import '../database_tables.dart';

class ReservationsDao {
  final Database db;

  ReservationsDao(this.db);

  /// Create a new reservation
  Future<int> createReservation(ReservationModel reservation) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(
        DatabaseTables.reservationsTable,
        reservation.toJson(),
      );
    });
  }

  //Create a multiple new reservations
  Future<int> createMultipleReservations(
    List<ReservationModel> reservations,
  ) async {
    return await db.transaction<int>((Transaction txn) async {
      int count = 0;
      for (var reservation in reservations) {
        count += await txn.insert(
          DatabaseTables.reservationsTable,
          reservation.toJson(),
        );
      }
      return count;
    });
  }

  /// Get a single reservation by ID
  Future<ReservationModel?> getReservation(int id) async {
    final maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return maps.isNotEmpty ? ReservationModel.fromJson(maps.first) : null;
  }

  /// Get a list of reservations with pagination and optional search
  Future<List<ReservationModel>> getReservations({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final int offset = (pageNumber - 1) * limit;

    final whereClause = (search != null && search.isNotEmpty)
        ? 'customerName LIKE ? OR phoneNumber LIKE ? OR tableName LIKE ?'
        : null;

    final whereArgs = (search != null && search.isNotEmpty)
        ? ['%$search%', '%$search%', '%$search%']
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'reservationDateTime DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  /// Update a reservation
  Future<int> updateReservation(ReservationModel reservation) async {
    return await db.update(
      DatabaseTables.reservationsTable,
      reservation.toJson(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  ///update multiple reservations
  Future<int> updateMultipleReservations(
    List<ReservationModel> reservations,
  ) async {
    return await db.transaction<int>((Transaction txn) async {
      int count = 0;
      for (var reservation in reservations) {
        count += await txn.update(
          DatabaseTables.reservationsTable,
          reservation.toJson(),
          where: 'id = ?',
          whereArgs: [reservation.id],
        );
      }
      return count;
    });
  }

  /// Update reservation status
  Future<int> updateReservationStatus(
    int id,
    int status,
    String modificationDate,
  ) async {
    return await db.update(
      DatabaseTables.reservationsTable,
      {'status': status, 'modificationDate': modificationDate},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a reservation
  Future<int> deleteReservation(int id) async {
    return await db.delete(
      DatabaseTables.reservationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // get reservations by date
  Future<List<ReservationModel>> getReservationsByDate(String date) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'reservationDateTime LIKE ?',
      whereArgs: ['%$date%'],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  // get reservations by date range
  Future<List<ReservationModel>> getReservationsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'reservationDateTime BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  // get reservations by status
  Future<List<ReservationModel>> getReservationsByStatus(int status) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  // get reservations by table id
  Future<List<ReservationModel>> getReservationsByTableId(int tableId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'tableId = ?',
      whereArgs: [tableId],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  // get reservations by customer id
  Future<List<ReservationModel>> getReservationsByCustomerId(
    int customerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //delete mutiple reservations
  Future<int> deleteMultipleReservations(List<int> ids) async {
    return await db.transaction<int>((Transaction txn) async {
      int count = 0;
      for (var id in ids) {
        count += await txn.delete(
          DatabaseTables.reservationsTable,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      return count;
    });
  }

  //get all reservations
  Future<List<ReservationModel>> getAllReservations() async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and status
  Future<List<ReservationModel>> getReservationsByDateRangeAndStatus(
    String startDate,
    String endDate,
    int status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'reservationDateTime BETWEEN ? AND ? AND status = ?',
      whereArgs: [startDate, endDate, status],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id
  Future<List<ReservationModel>> getReservationsByDateRangeAndTableId(
    String startDate,
    String endDate,
    int tableId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'reservationDateTime BETWEEN ? AND ? AND tableId = ?',
      whereArgs: [startDate, endDate, tableId],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and customer id
  Future<List<ReservationModel>> getReservationsByDateRangeAndCustomerId(
    String startDate,
    String endDate,
    int customerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where: 'reservationDateTime BETWEEN ? AND ? AND customerId = ?',
      whereArgs: [startDate, endDate, customerId],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and status
  Future<List<ReservationModel>> getReservationsByDateRangeAndTableIdAndStatus(
    String startDate,
    String endDate,
    int tableId,
    int status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND status = ?',
      whereArgs: [startDate, endDate, tableId, status],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and customer id and status
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndCustomerIdAndStatus(
    String startDate,
    String endDate,
    int customerId,
    int status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND customerId = ? AND status = ?',
      whereArgs: [startDate, endDate, customerId, status],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and customer id
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndTableIdAndCustomerId(
    String startDate,
    String endDate,
    int tableId,
    int customerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND customerId = ?',
      whereArgs: [startDate, endDate, tableId, customerId],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and customer id and status
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndTableIdAndCustomerIdAndStatus(
    String startDate,
    String endDate,
    int tableId,
    int customerId,
    int status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND customerId = ? AND status = ?',
      whereArgs: [startDate, endDate, tableId, customerId, status],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and customer id and status and modification date
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndTableIdAndCustomerIdAndStatusAndModificationDate(
    String startDate,
    String endDate,
    int tableId,
    int customerId,
    int status,
    String modificationDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND customerId = ? AND status = ? AND modificationDate = ?',
      whereArgs: [
        startDate,
        endDate,
        tableId,
        customerId,
        status,
        modificationDate,
      ],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and customer id and status and modification date and creation date
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndTableIdAndCustomerIdAndStatusAndModificationDateAndCreationDate(
    String startDate,
    String endDate,
    int tableId,
    int customerId,
    int status,
    String modificationDate,
    String creationDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND customerId = ? AND status = ? AND modificationDate = ? AND creationDate = ?',
      whereArgs: [
        startDate,
        endDate,
        tableId,
        customerId,
        status,
        modificationDate,
        creationDate,
      ],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }

  //get reservations by date range and table id and customer id and status and modification date and creation date and reservation date
  Future<List<ReservationModel>>
  getReservationsByDateRangeAndTableIdAndCustomerIdAndStatusAndModificationDateAndCreationDateAndReservationDate(
    String startDate,
    String endDate,
    int tableId,
    int customerId,
    int status,
    String modificationDate,
    String creationDate,
    String reservationDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.reservationsTable,
      where:
          'reservationDateTime BETWEEN ? AND ? AND tableId = ? AND customerId = ? AND status = ? AND modificationDate = ? AND creationDate = ? AND reservationDateTime = ?',
      whereArgs: [
        startDate,
        endDate,
        tableId,
        customerId,
        status,
        modificationDate,
        creationDate,
        reservationDate,
      ],
    );
    return List.generate(
      maps.length,
      (i) => ReservationModel.fromJson(maps[i]),
    );
  }
}
