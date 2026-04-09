import '../../model/inventory_model/inventory_model.dart';
import '../../model/purchase_model/purchase_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/components/constants.dart';
import '../database_tables.dart';

class InventoryDao {
  final Database db;

  InventoryDao(this.db);

  // CRUD for InventoryModel

  ///Insert new inventory record
  Future<int> insertInventory(InventoryModel inventory) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(
        DatabaseTables.inventoryTable,
        inventory.toJson(),
      );
    });
  }

  ///Update existing inventory record
  Future<int> updateInventory(InventoryModel inventory) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.update(
        DatabaseTables.inventoryTable,
        inventory.toJson(),
        where: 'id = ?',
        whereArgs: <Object?>[inventory.id],
      );
    });
  }

  ///Delete inventory by id (permanent)
  Future<int> deleteInventory(int id) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.delete(
        DatabaseTables.inventoryTable,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  ///Bulk insert inventory list
  Future<void> insertInventoryBatch(List<InventoryModel> items) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final InventoryModel item in items) {
        batch.insert(DatabaseTables.inventoryTable, item.toJson());
      }
      await batch.commit(noResult: true);
    });
  }

  ///Bulk update inventory list
  Future<void> updateInventoryBatch(List<InventoryModel> items) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final InventoryModel item in items) {
        batch.update(
          DatabaseTables.inventoryTable,
          item.toJson(),
          where: 'id = ?',
          whereArgs: <Object?>[item.id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  ///Bulk delete inventory ids
  Future<void> deleteInventoryBatch(List<int> ids) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final int id in ids) {
        batch.delete(
          DatabaseTables.inventoryTable,
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  ///Get all enabled inventory
  Future<List<InventoryModel>> getAllEnableInventory() async {
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.inventoryTable,
      where: 'isEnabled = ?',
      whereArgs: <Object?>[1],
      orderBy: 'LOWER(name) ASC',
    );
    return res.isNotEmpty
        ? List<InventoryModel>.generate(
            res.length,
            (int i) => InventoryModel.fromJson(res[i]),
          )
        : <InventoryModel>[];
  }

  ///Get enabled inventory with pagination
  Future<List<InventoryModel>> getAllEnableInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    String whereClause = 'isEnabled = ?';
    List<Object?> whereArgs = <Object?>[1];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause +=
          ' AND (LOWER(name) LIKE ? OR LOWER(shortDescription) LIKE ?)';
      final String searchPattern = '%${searchQuery.toLowerCase()}%';
      whereArgs.addAll(<Object?>[searchPattern, searchPattern]);
    }

    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.inventoryTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'LOWER(name) ASC',
      limit: pageSize,
      offset: page * pageSize,
    );

    return res.isNotEmpty
        ? List<InventoryModel>.generate(
            res.length,
            (int i) => InventoryModel.fromJson(res[i]),
          )
        : <InventoryModel>[];
  }

  ///Search inventory by name/description
  Future<List<InventoryModel>> searchInventoryByNameOrDescription({
    required String query,
  }) async {
    final String searchPattern = '%${query.toLowerCase()}%';
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.inventoryTable,
      where: 'LOWER(name) LIKE ? OR LOWER(shortDescription) LIKE ?',
      whereArgs: <Object?>[searchPattern, searchPattern],
      orderBy: 'LOWER(name) ASC',
    );

    return res.isNotEmpty
        ? List<InventoryModel>.generate(
            res.length,
            (int i) => InventoryModel.fromJson(res[i]),
          )
        : <InventoryModel>[];
  }

  ///Get all inventory
  Future<List<InventoryModel>> getInventory() async {
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.inventoryTable,
      orderBy: 'LOWER(name) ASC',
    );

    return res.isNotEmpty
        ? List<InventoryModel>.generate(
            res.length,
            (int i) => InventoryModel.fromJson(res[i]),
          )
        : <InventoryModel>[];
  }

  ///Get inventory with pagination
  Future<List<InventoryModel>> getInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    String? whereClause;
    List<Object?>? whereArgs;

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'LOWER(name) LIKE ? OR LOWER(shortDescription) LIKE ?';
      final String searchPattern = '%${searchQuery.toLowerCase()}%';
      whereArgs = <Object?>[searchPattern, searchPattern];
    }

    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.inventoryTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'LOWER(name) ASC',
      limit: pageSize,
      offset: page * pageSize,
    );

    return res.isNotEmpty
        ? List<InventoryModel>.generate(
            res.length,
            (int i) => InventoryModel.fromJson(res[i]),
          )
        : <InventoryModel>[];
  }

  ///Get distinct first letters of enabled inventory (alphabetical index)
  Future<List<String>> getEnabledInventoryFirstLetters({
    String? searchQuery,
  }) async {
    String whereClause = 'isEnabled = ?';
    List<Object?> whereArgs = [1];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause +=
          ' AND (LOWER(name) LIKE ? OR LOWER(shortDescription) LIKE ?)';
      final String searchPattern = '%${searchQuery.toLowerCase()}%';
      whereArgs.addAll([searchPattern, searchPattern]);
    }

    final List<Map<String, Object?>> res = await db.rawQuery(
      'SELECT DISTINCT UPPER(SUBSTR(name, 1, 1)) AS firstLetter '
      'FROM ${DatabaseTables.inventoryTable} '
      'WHERE $whereClause '
      'ORDER BY firstLetter ASC',
      whereArgs,
    );

    return res.isNotEmpty
        ? res.map((map) => (map['firstLetter'] as String)).toList()
        : <String>[];
  }

  ///Get distinct first letters for all inventory
  Future<List<String>> getAllInventoryFirstLetters({
    String? searchQuery,
  }) async {
    String whereClause = '1=1';
    List<Object?> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'LOWER(name) LIKE ? OR LOWER(shortDescription) LIKE ?';
      final String searchPattern = '%${searchQuery.toLowerCase()}%';
      whereArgs = [searchPattern, searchPattern];
    }

    final List<Map<String, Object?>> res = await db.rawQuery(
      'SELECT DISTINCT UPPER(SUBSTR(name, 1, 1)) AS firstLetter '
      'FROM ${DatabaseTables.inventoryTable} '
      'WHERE $whereClause '
      'ORDER BY firstLetter ASC',
      whereArgs,
    );

    return res.isNotEmpty
        ? res.map((map) => (map['firstLetter'] as String)).toList()
        : <String>[];
  }

  // CRUD for PurchaseModel

  ///Insert new purchase record
  Future<int> insertPurchase(PurchaseModel purchase) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(DatabaseTables.purchaseTable, purchase.toJson());
    });
  }

  ///Update existing purchase record
  Future<int> updatePurchase(PurchaseModel purchase) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.update(
        DatabaseTables.purchaseTable,
        purchase.toJson(),
        where: 'id = ?',
        whereArgs: <Object?>[purchase.id],
      );
    });
  }

  ///Delete purchase by id
  Future<int> deletePurchase(int id) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.delete(
        DatabaseTables.purchaseTable,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
  }

  ///Bulk insert purchases
  Future<void> insertPurchaseBatch(List<PurchaseModel> purchases) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final PurchaseModel purchase in purchases) {
        batch.insert(DatabaseTables.purchaseTable, purchase.toJson());
      }
      await batch.commit(noResult: true);
    });
  }

  ///Bulk update purchases
  Future<void> updatePurchaseBatch(List<PurchaseModel> purchases) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final PurchaseModel purchase in purchases) {
        batch.update(
          DatabaseTables.purchaseTable,
          purchase.toJson(),
          where: 'id = ?',
          whereArgs: <Object?>[purchase.id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  ///Bulk delete purchases
  Future<void> deletePurchaseBatch(List<int> ids) async {
    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final int id in ids) {
        batch.delete(
          DatabaseTables.purchaseTable,
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  ///Get all purchases by date desc
  Future<List<PurchaseModel>> getAllPurchases() async {
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.purchaseTable,
      orderBy: 'purchaseDateTime DESC',
    );

    return res.isNotEmpty
        ? List<PurchaseModel>.generate(
            res.length,
            (int i) => PurchaseModel.fromJson(res[i]),
          )
        : <PurchaseModel>[];
  }

  ///Get daily expenditure cost
  Future<double> getDailyExpenditureCost(String currentDate) async {
    final List<Map<String, Object?>> res = await db.rawQuery(
      'SELECT SUM(purchasePrice) as total FROM ${DatabaseTables.purchaseTable} '
      'WHERE purchaseDateTime LIKE ?',
      <Object?>['$currentDate%'],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  ///Get monthly expenditure cost
  Future<double> getMonthlyExpenditureCost(String month) async {
    final List<Map<String, Object?>> res = await db.rawQuery(
      'SELECT SUM(purchasePrice) as total FROM ${DatabaseTables.purchaseTable} '
      'WHERE purchaseDateTime LIKE ?',
      <Object?>['$month%'],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  ///Get purchases between two dates
  Future<List<PurchaseModel>> getPurchasesBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    final List<Map<String, Object?>> res = await db.query(
      DatabaseTables.purchaseTable,
      where: 'purchaseDateTime BETWEEN ? AND ?',
      whereArgs: <Object?>[fromDateTime, toDateTime],
      orderBy: 'purchaseDateTime ASC',
    );

    return res.isNotEmpty
        ? List<PurchaseModel>.generate(
            res.length,
            (int i) => PurchaseModel.fromJson(res[i]),
          )
        : <PurchaseModel>[];
  }

  ///Get expenditure between two dates
  Future<double> getExpenditureBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    final List<Map<String, Object?>> res = await db.rawQuery(
      'SELECT SUM(purchasePrice) as total FROM ${DatabaseTables.purchaseTable} '
      'WHERE purchaseDateTime BETWEEN ? AND ?',
      <Object?>[fromDateTime, toDateTime],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  ///Get combined graph data for expenditures with null safety and error handling
  ///
  ///Returns a map with keys:
  /// - 'daily': List of daily totals for the specified month (YYYY-MM),
  ///   each entry contains {'day': 'YYYY-MM-DD', 'total': double}.
  /// - 'monthly': List of monthly totals for the specified year (YYYY),
  ///   each entry contains {'month': 'YYYY-MM', 'total': double}.
  /// - 'range': List of daily totals for the custom date range,
  ///   each entry contains {'day': 'YYYY-MM-DD', 'total': double}.
  ///
  ///Use this data to plot graphs such as line charts or bar charts for daily,
  ///monthly, and custom date range expenditure visualization.
  ///
  ///Parameters:
  /// - month: e.g. '2025-08' for daily data within a month.
  /// - year: e.g. '2025' for monthly data within a year.
  /// - fromDateTime: ISO8601 UTC string, e.g. '2025-08-01T00:00:00Z' start of range.
  /// - toDateTime: ISO8601 UTC string, e.g. '2025-08-17T23:59:59Z' end of range.
  Future<Map<String, List<Map<String, dynamic>>>> getExpenditureGraphData({
    required String month,
    required String year,
    required String fromDateTime,
    required String toDateTime,
  }) async {
    try {
      return await db.transaction<Map<String, List<Map<String, dynamic>>>>((
        txn,
      ) async {
        final Batch batch = txn.batch();

        // Daily expenditure totals grouped by day for the given month
        batch.rawQuery(
          '''
        SELECT substr(purchaseDateTime, 1, 10) AS day, 
               SUM(purchasePrice) AS total 
        FROM ${DatabaseTables.purchaseTable}
        WHERE purchaseDateTime LIKE ?
        GROUP BY day
        ORDER BY day ASC
      ''',
          ['$month%'],
        );

        // Monthly expenditure totals grouped by month for the given year
        batch.rawQuery(
          '''
        SELECT substr(purchaseDateTime, 1, 7) AS month, 
               SUM(purchasePrice) AS total 
        FROM ${DatabaseTables.purchaseTable}
        WHERE purchaseDateTime LIKE ?
        GROUP BY month
        ORDER BY month ASC
      ''',
          ['$year%'],
        );

        // Daily expenditure totals grouped by day for the custom date range
        batch.rawQuery(
          '''
        SELECT substr(purchaseDateTime, 1, 10) AS day, 
               SUM(purchasePrice) AS total 
        FROM ${DatabaseTables.purchaseTable}
        WHERE purchaseDateTime BETWEEN ? AND ?
        GROUP BY day
        ORDER BY day ASC
      ''',
          [fromDateTime, toDateTime],
        );

        final List<dynamic> results = await batch.commit();

        // Helper function to safely parse query result and return list of maps
        List<Map<String, dynamic>> parseResults(
          List<Map<String, Object?>> rawList,
          String dateKey,
        ) {
          return List<Map<String, dynamic>>.generate(rawList.length, (int i) {
            final String? dateValue = rawList[i][dateKey] as String?;
            final num? totalNum = rawList[i]['total'] as num?;
            return {
              dateKey: dateValue ?? '',
              'total': totalNum?.toDouble() ?? 0.0,
            };
          });
        }

        final List<Map<String, Object?>> dailyRaw =
            List<Map<String, Object?>>.from(results[0]);
        final List<Map<String, dynamic>> daily = parseResults(dailyRaw, 'day');

        final List<Map<String, Object?>> monthlyRaw =
            List<Map<String, Object?>>.from(results[1]);
        final List<Map<String, dynamic>> monthly = parseResults(
          monthlyRaw,
          'month',
        );

        final List<Map<String, Object?>> rangeRaw =
            List<Map<String, Object?>>.from(results[2]);
        final List<Map<String, dynamic>> range = parseResults(rangeRaw, 'day');

        return {'daily': daily, 'monthly': monthly, 'range': range};
      });
    } catch (e, stacktrace) {
      Constants.debugLog(
        InventoryDao,
        'getExpenditureGraphData:Error:$e\n$stacktrace',
      );

      return {
        'daily': <Map<String, dynamic>>[],
        'monthly': <Map<String, dynamic>>[],
        'range': <Map<String, dynamic>>[],
      };
    }
  }
}
