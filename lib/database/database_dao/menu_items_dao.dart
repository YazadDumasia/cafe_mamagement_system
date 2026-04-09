import 'package:sqflite/sqflite.dart';
import '../../model/menu_item.dart';
import '../../model/menu_item_review.dart';
import '../../model/daily_sales_report_entry.dart';
import '../../utlis/components/constants.dart';
import '../database_tables.dart';

class MenuItemsDao {
  final Database db;

  MenuItemsDao(this.db);

  // Menu Items CRUD operations

  /// Create a new menu item
  Future<int> createMenuItem(MenuItem menuItem) async {
    return await db.transaction<int>((txn) async {
      final int menuItemId = await txn.insert(
        DatabaseTables.menuItemsTable,
        menuItem.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (menuItem.variations != null && menuItem.variations!.isNotEmpty) {
        final Batch batch = txn.batch();
        for (final MenuItemVariation variation in menuItem.variations!) {
          variation.menuItemId = menuItemId;
          batch.insert(
            DatabaseTables.menuItemVariationsTable,
            variation.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }

      return menuItemId;
    });
  }

  /// Update an existing menu item
  Future<int> updateMenuItem(MenuItem menuItem) async {
    return await db.transaction<int>((txn) async {
      final int rowsAffected = await txn.update(
        DatabaseTables.menuItemsTable,
        menuItem.toJson(),
        where: 'id = ?',
        whereArgs: [menuItem.id],
      );

      // Delete existing variations and insert updated ones
      await txn.delete(
        DatabaseTables.menuItemVariationsTable,
        where: 'menuItemId = ?',
        whereArgs: [menuItem.id],
      );

      if (menuItem.variations != null && menuItem.variations!.isNotEmpty) {
        final Batch batch = txn.batch();
        for (final MenuItemVariation variation in menuItem.variations!) {
          variation.menuItemId = menuItem.id;
          batch.insert(
            DatabaseTables.menuItemVariationsTable,
            variation.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }

      return rowsAffected;
    });
  }

  /// Get a single menu item by ID
  Future<MenuItem?> getMenuItemById(int id) async {
    final List<Map<String, Object?>> itemMaps = await db.query(
      DatabaseTables.menuItemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (itemMaps.isEmpty) return null;

    final List<Map<String, Object?>> variationsMaps = await db.query(
      DatabaseTables.menuItemVariationsTable,
      where: 'menuItemId = ?',
      whereArgs: [id],
    );

    final List<MenuItemVariation> variations = List.generate(
      variationsMaps.length,
      (i) => MenuItemVariation.fromJson(variationsMaps[i]),
    );

    final MenuItem item = MenuItem.fromJson(itemMaps.first);
    item.variations = variations;
    return item;
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(int? menuItemId) async {
    if (menuItemId == null) return;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseTables.menuItemsTable,
        where: 'id = ?',
        whereArgs: [menuItemId],
      );
      await txn.delete(
        DatabaseTables.menuItemVariationsTable,
        where: 'menuItemId = ?',
        whereArgs: [menuItemId],
      );
    });
  }

  /// Get all menu items
  Future<List<MenuItem>> getAllMenuItems() async {
    final List<Map<String, Object?>> itemMaps = await db.query(
      DatabaseTables.menuItemsTable,
      orderBy: 'name ASC',
    );

    if (itemMaps.isEmpty) return [];

    final List<Map<String, Object?>> variationsMaps = await db.query(
      DatabaseTables.menuItemVariationsTable,
    );

    final Map<int, List<MenuItemVariation>> variationsMap = {};
    for (final Map<String, Object?> varMap in variationsMaps) {
      final int mId = varMap['menuItemId'] as int;
      variationsMap.putIfAbsent(mId, () => []);
      variationsMap[mId]!.add(MenuItemVariation.fromJson(varMap));
    }

    return List.generate(itemMaps.length, (i) {
      final MenuItem item = MenuItem.fromJson(itemMaps[i]);
      item.variations = variationsMap[item.id] ?? [];
      return item;
    });
  }

  /// Get available menu items
  Future<List<MenuItem>> getAvailableMenuItems() async {
    final List<Map<String, Object?>> itemMaps = await db.query(
      DatabaseTables.menuItemsTable,
      where: 'isTodayAvailable = 1',
      orderBy: 'name ASC',
    );

    if (itemMaps.isEmpty) return [];

    final List<Map<String, Object?>> variationsMaps = await db.query(
      DatabaseTables.menuItemVariationsTable,
      where: 'isTodayAvailable = 1',
    );

    final Map<int, List<MenuItemVariation>> variationsMap = {};
    for (final Map<String, Object?> varMap in variationsMaps) {
      final int mId = varMap['menuItemId'] as int;
      variationsMap.putIfAbsent(mId, () => []);
      variationsMap[mId]!.add(MenuItemVariation.fromJson(varMap));
    }

    return List.generate(itemMaps.length, (i) {
      final MenuItem item = MenuItem.fromJson(itemMaps[i]);
      item.variations = variationsMap[item.id] ?? [];
      return item;
    });
  }

  Future<List<MenuItem>> getAvailableMenuItemsPagination({
    required int pageNumber,
    required int limit,
    String? searchTerm,
  }) async {
    final int offset = (pageNumber - 1) * limit;
    String? where;
    List<Object?>? whereArgs;

    if (searchTerm != null && searchTerm.isNotEmpty) {
      where = 'isTodayAvailable = 1 AND name LIKE ?';
      whereArgs = ['%$searchTerm%'];
    } else {
      where = 'isTodayAvailable = 1';
    }

    final List<Map<String, Object?>> itemMaps = await db.query(
      DatabaseTables.menuItemsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    if (itemMaps.isEmpty) return [];

    final List<int> ids = itemMaps.map((m) => m['id'] as int).toList();
    final String inClause = List.filled(ids.length, '?').join(',');

    final List<Map<String, Object?>> variationsMaps = await db.query(
      DatabaseTables.menuItemVariationsTable,
      where: 'menuItemId IN ($inClause) AND isTodayAvailable = 1',
      whereArgs: ids,
    );

    final Map<int, List<MenuItemVariation>> variationsMap = {};
    for (final Map<String, Object?> varMap in variationsMaps) {
      final int mId = varMap['menuItemId'] as int;
      variationsMap.putIfAbsent(mId, () => []);
      variationsMap[mId]!.add(MenuItemVariation.fromJson(varMap));
    }

    return List.generate(itemMaps.length, (i) {
      final MenuItem item = MenuItem.fromJson(itemMaps[i]);
      item.variations = variationsMap[item.id] ?? [];
      return item;
    });
  }

  /// Fetches a paginated list of all menu items (with optional name search), including their variations.
  Future<List<MenuItem>> fetchAllMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final int offset = (pageNumber - 1) * limit;

    String? whereClause;
    List<Object?>? whereArgs;
    if (search != null && search.trim().isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs = ['%${search.trim()}%'];
    }

    try {
      final List<Map<String, Object?>> itemMaps = await db.query(
        DatabaseTables.menuItemsTable,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
        limit: limit,
        offset: offset,
      );

      if (itemMaps.isEmpty) return [];

      final List<int> menuItemIds = itemMaps
          .map<int>((map) => map['id'] as int)
          .toList();

      final String placeholders = List.filled(
        menuItemIds.length,
        '?',
      ).join(',');
      final List<Map<String, Object?>> allVariationsMaps = await db.query(
        DatabaseTables.menuItemVariationsTable,
        where: 'menuItemId IN ($placeholders)',
        whereArgs: menuItemIds,
      );

      final Map<int, List<MenuItemVariation>> variationsMap = {};
      for (final Map<String, Object?> variationMap in allVariationsMaps) {
        final int menuItemId = variationMap['menuItemId'] as int;
        variationsMap.putIfAbsent(menuItemId, () => []);
        variationsMap[menuItemId]!.add(
          MenuItemVariation.fromJson(variationMap),
        );
      }

      return List.generate(itemMaps.length, (int index) {
        final MenuItem item = MenuItem.fromJson(itemMaps[index]);
        item.variations = variationsMap[item.id] ?? [];
        return item;
      });
    } catch (e, stacktrace) {
      Constants.debugLog(
        MenuItemsDao,
        'fetchAllMenuItemsPaged:Error: $e stacktrace: $stacktrace',
      );
      return [];
    }
  }

  /// Fetch all menu items count (with optional name search).
  Future<int> fetchMenuItemsCount({String? search}) async {
    String? whereClause;
    List<Object?>? whereArgs;
    if (search != null && search.trim().isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs = ['%${search.trim()}%'];
    }

    final List<Map<String, Object?>> results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.menuItemsTable}${whereClause != null ? ' WHERE $whereClause' : ''}',
      whereArgs,
    );

    return Sqflite.firstIntValue(results) ?? 0;
  }

  /// Fetches a paginated list of available compound menu items with optional name search, including their variations.
  Future<List<MenuItem>?> fetchAvailableMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final int offset = (pageNumber - 1) * limit;

    final List<String> whereParts = [
      'isTodayAvailable = 1',
      'isSimpleVariation = 0',
    ];
    final List<Object?> whereArgs = [];

    if (search != null && search.trim().isNotEmpty) {
      whereParts.add('name LIKE ?');
      whereArgs.add('%${search.trim()}%');
    }

    final String whereClause = whereParts.join(' AND ');

    try {
      final List<Map<String, Object?>> itemMaps = await db.query(
        DatabaseTables.menuItemsTable,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
        limit: limit,
        offset: offset,
      );

      if (itemMaps.isEmpty) return [];

      final List<int> menuItemIds = itemMaps
          .map<int>((map) => map['id'] as int)
          .toList();

      final String inClause = List.filled(menuItemIds.length, '?').join(',');
      final List<Map<String, Object?>> allVariationsMaps = await db.query(
        DatabaseTables.menuItemVariationsTable,
        where: 'menuItemId IN ($inClause)',
        whereArgs: menuItemIds,
      );

      final Map<int, List<MenuItemVariation>> variationsMap = {};
      for (final variationMap in allVariationsMaps) {
        final int menuItemId = variationMap['menuItemId'] as int;
        variationsMap.putIfAbsent(menuItemId, () => []);
        variationsMap[menuItemId]!.add(
          MenuItemVariation.fromJson(variationMap),
        );
      }

      return List.generate(itemMaps.length, (int index) {
        final MenuItem item = MenuItem.fromJson(itemMaps[index]);
        List<MenuItemVariation> variations = variationsMap[item.id] ?? [];
        if (variations.isNotEmpty &&
            variations.every((v) => v.isTodayAvailable != true)) {
          variations = [];
        }
        item.variations = variations;
        return item;
      });
    } catch (e, stacktrace) {
      Constants.debugLog(
        MenuItemsDao,
        'fetchAvailableMenuItemsPaged:Error: $e stacktrace: $stacktrace',
      );
      return [];
    }
  }

  // Reviews operations

  /// Get reviews for a menu item
  Future<List<MenuItemReview>> getReviewsForMenuItem(int itemId) async {
    final List<Map<String, Object?>> results = await db.query(
      DatabaseTables.menuItemReviewsTable,
      where: 'itemId = ?',
      whereArgs: <Object?>[itemId],
    );
    return List<MenuItemReview>.generate(
      results.length,
      (i) => MenuItemReview.fromJson(results[i]),
    );
  }

  /// Calculate average rating for a menu item
  Future<double> calculateAverageRatingForMenuItem(int itemId) async {
    final List<MenuItemReview> reviews = await getReviewsForMenuItem(itemId);
    if (reviews.isEmpty) return 0.0;
    final int totalRating = reviews.fold(0, (sum, r) => sum + (r.rating ?? 0));
    return totalRating / reviews.length;
  }

  // Sales Report operations

  /// Generate daily sales report for a specific menu item or variation
  Future<List<MenuItemSalesReport>> generateDailySalesReportForMenuItem({
    required int itemId,
    required DateTime fromDate,
    required DateTime toDate,
    bool isMenuItem = true,
  }) async {
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
    SELECT SUBSTR(o.creationDate, 1, 10) AS salesDay, 
           SUM(oi.quantity) AS quantitySold, 
           SUM(oi.sellingPrice * oi.quantity) AS totalAmount,
           SUM(oi.costPrice * oi.quantity) AS totalCost
    FROM ${DatabaseTables.ordersTable} o
    JOIN ${DatabaseTables.orderItemsTable} oi ON o.id = oi.orderId
    WHERE (oi.itemId = ? OR oi.selectedVariationId = ?) 
      AND oi.isMenuItem = ?
      AND o.creationDate >= ? AND o.creationDate <= ? AND o.status = 'Completed'
    GROUP BY salesDay
    ''',
      <Object?>[
        itemId,
        itemId,
        isMenuItem ? 1 : 0,
        fromDate.toIso8601String(),
        toDate.toIso8601String(),
      ],
    );

    return List.generate(results.length, (i) {
      final result = results[i];
      final String salesDay = result['salesDay'] as String? ?? '';
      final double quantitySold =
          (result['quantitySold'] as num?)?.toDouble() ?? 0.0;
      final double totalAmount =
          (result['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final double totalCost = (result['totalCost'] as num?)?.toDouble() ?? 0.0;
      final double totalProfit = totalAmount - totalCost;
      double? profitPercentage;
      try {
        profitPercentage = totalAmount != 0
            ? (totalProfit / totalAmount) * 100
            : null;
      } catch (_) {
        profitPercentage = null;
      }
      return MenuItemSalesReport(
        salesDay: salesDay,
        quantitySold: quantitySold,
        totalAmount: totalAmount,
        totalCost: totalCost,
        totalProfit: totalProfit,
        profitPercentage: profitPercentage,
      );
    });
  }

  /// Generate monthly sales report for a specific menu item or variation
  Future<List<MenuItemSalesReport>> generateMonthlySalesReportForMenuItem({
    required int itemId,
    required DateTime fromDate,
    required DateTime toDate,
    bool isMenuItem = true,
  }) async {
    final String joinTable = isMenuItem
        ? DatabaseTables.menuItemsTable
        : DatabaseTables.menuItemVariationsTable;
    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
    SELECT SUBSTR(o.creationDate, 1, 7) AS salesMonth,
           SUM(oi.quantity) AS quantitySold,
           SUM(oi.sellingPrice * oi.quantity) AS totalAmount,
           SUM(oi.costPrice * oi.quantity) AS totalCost
    FROM ${DatabaseTables.ordersTable} o
    JOIN ${DatabaseTables.orderItemsTable} oi ON o.id = oi.orderId
    JOIN $joinTable mi ON oi.itemId = mi.id
    WHERE oi.itemId = ? AND o.creationDate >= ? AND o.creationDate <= ? AND o.status = 'Completed'
    GROUP BY salesMonth
    ''',
      <Object?>[itemId, fromDate.toIso8601String(), toDate.toIso8601String()],
    );

    return List.generate(results.length, (i) {
      final result = results[i];
      final String salesMonth = result['salesMonth'] as String? ?? '';
      final double quantitySold =
          (result['quantitySold'] as num?)?.toDouble() ?? 0.0;
      final double totalAmount =
          (result['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final double totalCost = (result['totalCost'] as num?)?.toDouble() ?? 0.0;
      final double totalProfit = totalAmount - totalCost;
      double? profitPercentage;
      try {
        profitPercentage = totalAmount != 0
            ? (totalProfit / totalAmount) * 100
            : null;
      } catch (_) {
        profitPercentage = null;
      }
      return MenuItemSalesReport(
        salesDay: salesMonth,
        quantitySold: quantitySold,
        totalAmount: totalAmount,
        totalCost: totalCost,
        totalProfit: totalProfit,
        profitPercentage: profitPercentage,
      );
    });
  }
}
