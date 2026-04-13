import '../../model/table_info_model.dart';
import 'package:sqflite/sqflite.dart';
import '../../model/customer.dart';
import '../database_tables.dart';

class CustomersDao {
  final Database db;

  CustomersDao(this.db);

  // Customer CRUD operations
  /// Create a new customer
  Future<int> createCustomer(Customer customer) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(DatabaseTables.customersTable, customer.toJson());
    });
  }

  /// Insert multiple customers in batch
  Future<void> insertCustomersBatch(List<Customer> customers) async {
    if (customers.isEmpty) return;

    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final Customer customer in customers) {
        batch.insert(DatabaseTables.customersTable, customer.toJson());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Update multiple customers in batch
  Future<void> updateCustomersBatch(List<Customer> customers) async {
    if (customers.isEmpty) return;

    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final Customer customer in customers) {
        batch.update(
          DatabaseTables.customersTable,
          customer.toJson(),
          where: 'id = ?',
          whereArgs: [customer.id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Get a single customer by ID
  Future<Customer?> getCustomer(int id) async {
    final maps = await db.query(
      DatabaseTables.customersTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return maps.isNotEmpty ? Customer.fromJson(maps.first) : null;
  }

  /// Get a list of all customers with pagination and optional search
  Future<List<Customer>?> searchCustomers({
    int pageNumber = 1, // 1-based page number
    int limit = 20, // Number of items per page
    String? search, // Optional search term
  }) async {
    final int offset = (pageNumber - 1) * limit;

    final whereClause = (search != null && search.isNotEmpty)
        ? 'name LIKE ? OR phoneNumber LIKE ?'
        : null;

    final whereArgs = (search != null && search.isNotEmpty)
        ? ['%$search%', '%$search%']
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.customersTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    if (maps.isNotEmpty) {
      return List.generate(maps.length, (element) {
        return Customer.fromJson(maps[element]);
      });
    } else {
      return null;
    }
  }

  /// is customer exist or not
  Future<bool> isCustomerExist(String searchTerm) async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.customersTable,
      where: 'name LIKE ? OR phoneNumber LIKE ?',
      whereArgs: <Object?>['%$searchTerm%', '%$searchTerm%'],
      limit: 1, //  Only need one match
    );
    return maps.isNotEmpty;
  }

  /// Update a customer
  Future<int?> updateCustomer(Customer customer) async {
    return await db.transaction<int?>((txn) async {
      final batch = txn.batch();
      batch.update(
        DatabaseTables.customersTable,
        customer.toJson(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      // Commit batch and ignore result count list
      await batch.commit(noResult: true);
      // Return number of rows affected by update (approximate as batch.commit returns no results here)
      // For simplicity, return 1 assuming update attempted
      return 1;
    });
  }

  /// Delete a customer
  Future<int?> deleteCustomer(int id) async {
    return await db.transaction<int?>((txn) async {
      final batch = txn.batch();
      batch.delete(
        DatabaseTables.customersTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      await batch.commit(noResult: true);
      // Return 1 assuming deletion attempted
      return 1;
    });
  }

  // TableInfo CRUD operations

  /// Create a new table info
  Future<int?> addTableInfo(TableInfoModel newTableInfo) async {
    return await db.transaction<int?>((txn) async {
      final batch = txn.batch();

      // Get max sortOrderIndex inside transaction
      final List<Map<String, dynamic>>
      maxSortRecordIndexResult = await txn.rawQuery(
        'SELECT COALESCE(MAX(sortOrderIndex), -1) AS maxIndex FROM ${DatabaseTables.tableInfoTable}',
      );

      final int maxSortRecordIndex =
          Sqflite.firstIntValue(maxSortRecordIndexResult) ?? -1;

      // Assign next sortOrderIndex
      newTableInfo.sortOrderIndex = maxSortRecordIndex + 1;

      // Add insert to batch
      batch.rawInsert(
        '''
      INSERT INTO ${DatabaseTables.tableInfoTable} (name, sortOrderIndex, nosOfChairs, colorValue)
      VALUES (?, ?, ?, ?)
      ''',
        <Object?>[
          newTableInfo.name,
          newTableInfo.sortOrderIndex,
          newTableInfo.nosOfChairs,
          newTableInfo.colorValue,
        ],
      );

      await batch.commit(noResult: true);

      // Return the assigned sortOrderIndex as an indication of success (since rawInsert ID is unavailable here)
      return newTableInfo.sortOrderIndex;
    });
  }

  /// Get a list of all table infos
  Future<List<TableInfoModel>?> getTableInfos() async {
    return await db.transaction((Transaction txn) async {
      final batch = txn.batch();
      batch.query(
        DatabaseTables.tableInfoTable,
        orderBy:
            'sortOrderIndex ASC', // Order by sortOrderIndex in ascending order
      );
      final results = await batch.commit();
      final List<Map<String, dynamic>> maps =
          results.first as List<Map<String, dynamic>>;

      return maps.isNotEmpty
          ? List.generate(maps.length, (i) {
              return TableInfoModel.fromJson(maps[i]);
            })
          : null;
    });
  }

  /// Get table infos page (default: 20 per page, page 1)
  Future<List<TableInfoModel>?> getTableInfosPage({
    int limit = 20,
    int pageNumber = 1,
  }) async {
    // Calculate offset for pagination (pageNumber starts at 1)
    final int offset = (pageNumber - 1) * limit;

    return await db.transaction((Transaction txn) async {
      final batch = txn.batch();
      batch.query(
        DatabaseTables.tableInfoTable,
        orderBy: 'sortOrderIndex ASC',
        limit: limit,
        offset: offset,
      );
      final results = await batch.commit();
      final List<Map<String, dynamic>> maps =
          results.first as List<Map<String, dynamic>>;

      if (maps.isEmpty) {
        return null;
      }
      return List.generate(maps.length, (i) {
        return TableInfoModel.fromJson(maps[i]);
      });
    });
  }

  /// Get a single table info by ID
  Future<TableInfoModel?> getTableInfo(int id) async {
    return await db.transaction((Transaction txn) async {
      final batch = txn.batch();
      batch.query(
        DatabaseTables.tableInfoTable,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
      final results = await batch.commit();
      final List<Map<String, dynamic>> maps =
          results.first as List<Map<String, dynamic>>;

      return maps.isNotEmpty ? TableInfoModel.fromJson(maps.first) : null;
    });
  }

  /// Update a table info
  Future<int?> updateTableInfo(TableInfoModel tableInfo) async {
    return await db.transaction<int?>((txn) async {
      final batch = txn.batch();
      batch.update(
        DatabaseTables.tableInfoTable,
        tableInfo.toJson(),
        where: 'id = ?',
        whereArgs: <Object?>[tableInfo.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final results = await batch.commit();
      // batch.update returns number of affected rows, take first result
      return results.first as int?;
    });
  }

  /// Get table info record count (for pagination)
  Future<int> getTableInfoRecordCount() async {
    return await db.transaction<int>((txn) async {
      final batch = txn.batch();
      batch.rawQuery(
        'SELECT COUNT(*) AS count FROM ${DatabaseTables.tableInfoTable}',
      );
      final results = await batch.commit();
      final List<Map<String, dynamic>> result =
          results.first as List<Map<String, dynamic>>;

      return Sqflite.firstIntValue(result) ?? 0;
    });
  }

  /// Delete a table info
  Future<int?> deleteTableInfo(TableInfoModel model) async {
    // Start a transaction to ensure atomicity
    return db.transaction<int?>((Transaction txn) async {
      final int sortRecordIndexToDelete = model.sortOrderIndex ?? 0;

      // Step 1: Delete the item from the database
      final int rowsAffected = await txn.delete(
        DatabaseTables.tableInfoTable,
        where: 'id = ?',
        whereArgs: <Object?>[model.id],
      );

      // Step 2: Update sortOrderIndex for items with a higher index in batches
      const int batchSize =
          100; // Adjust this size based on performance testing

      // ignore: unused_local_variable
      int totalRowsUpdated = 0;

      // Calculate how many rows need to be updated
      final List<Map<String, Object?>> totalRowsToUpdate = await txn.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseTables.tableInfoTable} WHERE sortOrderIndex > ?',
        <Object?>[sortRecordIndexToDelete],
      );

      // Extracting the number of rows to update correctly
      int rowsToUpdate = totalRowsToUpdate.isNotEmpty
          ? (totalRowsToUpdate[0]['COUNT(*)'] as int?) ?? 0
          : 0;

      // Perform batched updates
      while (rowsToUpdate > 0) {
        // Calculate the number of rows to update in this batch
        final int currentBatchSize = (rowsToUpdate < batchSize)
            ? rowsToUpdate
            : batchSize;

        // Update the sortOrderIndex for the current batch
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.tableInfoTable} SET sortOrderIndex = sortOrderIndex - 1 '
          'WHERE sortOrderIndex > ? LIMIT ?',
          <Object?>[sortRecordIndexToDelete, currentBatchSize],
        );

        // Decrement the remaining rows to update
        rowsToUpdate -= currentBatchSize;
        totalRowsUpdated += currentBatchSize;
      }

      // Return the result of the transaction (number of rows deleted)
      return rowsAffected;
    });
  }
}
