import 'package:sqflite/sqflite.dart';
import '../../model/order_model/order_model.dart';
import '../../model/order_model/order_item.dart';
import '../database_tables.dart';

class OrdersDao {
  final Database db;

  OrdersDao(this.db);

  // Orders CRUD operations

  /// Create new order with optional customer
  Future<int?> createNewOrder(OrderModel order) async {
    return await db.transaction<int?>((txn) async {
      int? customerId;

      // Case 1: Structured customer object → insert into customers table
      if (order.customer != null) {
        customerId = await txn.insert(
          DatabaseTables.customersTable,
          order.customer!.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Prepare order data
      final Map<String, Object?> orderData = order.toJson();
      orderData.remove('customer');
      orderData.remove('orderItems');

      if (customerId != null) {
        // If inserted in customer table, link with customerId
        orderData['customerId'] = customerId;
      } else if (order.customer != null) {
        // If customer passed but not saved, store ad-hoc details
        orderData['customerName'] = order.customer!.name;
        orderData['phoneNumber'] = order.customer!.phoneNumber;
      }

      // Insert order
      final int orderId = await txn.insert(
        DatabaseTables.ordersTable,
        orderData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert order items batch
      final Batch batch = txn.batch();
      for (final OrderItem? orderItem in order.orderItems) {
        batch.insert(
          DatabaseTables.orderItemsTable,
          <String, Object?>{
            'orderId': orderId,
            'itemId': orderItem!.itemId,
            'quantity': orderItem.quantity,
            'status': orderItem.status,
            'isMenuItem': (orderItem.isMenuItem ?? false) ? 1 : 0,
            'menuItemId': orderItem.menuItem?.id,
            'selectedVariationId': orderItem.selectedVariation?.id,
            'sellingPrice': orderItem.sellingPrice,
            'costPrice': orderItem.costPrice,
            'remarks': orderItem.remarks ?? '',
            'creationDate':
                orderItem.creationDate ??
                DateTime.now().toUtc().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      return orderId;
    });
  }

  /// Update Order
  Future<void> updateOrder(OrderModel order) async {
    await db.transaction((Transaction txn) async {
      // Update the order table
      final Map<String, dynamic> orderData = order.toJson();
      orderData.remove('customer');
      orderData.remove('orderItems');

      await txn.update(
        DatabaseTables.ordersTable,
        orderData,
        where: 'id = ?',
        whereArgs: <Object?>[order.id],
      );

      // Delete existing order items for the order
      await txn.delete(
        DatabaseTables.orderItemsTable,
        where: 'orderId = ?',
        whereArgs: <Object?>[order.id],
      );

      // Insert the updated order items
      final Batch batch = txn.batch();
      for (final OrderItem? orderItem in order.orderItems) {
        batch.insert(DatabaseTables.orderItemsTable, <String, Object?>{
          'orderId': order.id,
          'itemId': orderItem!.itemId,
          'quantity': orderItem.quantity,
          'status': orderItem.status,
          'isMenuItem':
              (orderItem.isMenuItem != null && orderItem.isMenuItem == true)
              ? 1
              : 0,
          'menuItemId': orderItem.menuItem?.id,
          'selectedVariationId': orderItem.selectedVariation?.id,
          'sellingPrice': orderItem.sellingPrice,
          'costPrice': orderItem.costPrice,
          'remarks': orderItem.remarks ?? '',
          'creationDate':
              orderItem.creationDate ??
              DateTime.now().toUtc().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
    });
  }

  /// Insert multiple orders in batch
  Future<void> insertOrdersBatch(List<OrderModel> orders) async {
    if (orders.isEmpty) return;

    await db.transaction((Transaction txn) async {
      for (final OrderModel order in orders) {
        int? customerId;

        if (order.customer != null) {
          customerId = await txn.insert(
            DatabaseTables.customersTable,
            order.customer!.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        final Map<String, Object?> orderData = order.toJson();
        orderData.remove('customer');
        orderData.remove('orderItems');

        if (customerId != null) {
          orderData['customerId'] = customerId;
        } else if (order.customer != null) {
          orderData['customerName'] = order.customer!.name;
          orderData['phoneNumber'] = order.customer!.phoneNumber;
        }

        final int orderId = await txn.insert(
          DatabaseTables.ordersTable,
          orderData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final Batch itemBatch = txn.batch();
        for (final OrderItem? orderItem in order.orderItems) {
          itemBatch.insert(DatabaseTables.orderItemsTable, <String, Object?>{
            'orderId': orderId,
            'itemId': orderItem!.itemId,
            'quantity': orderItem.quantity,
            'status': orderItem.status,
            'isMenuItem':
                (orderItem.isMenuItem != null && orderItem.isMenuItem == true)
                ? 1
                : 0,
            'menuItemId': orderItem.menuItem?.id,
            'selectedVariationId': orderItem.selectedVariation?.id,
            'sellingPrice': orderItem.sellingPrice,
            'costPrice': orderItem.costPrice,
            'remarks': orderItem.remarks ?? '',
            'creationDate':
                orderItem.creationDate ??
                DateTime.now().toUtc().toIso8601String(),
          });
        }
        await itemBatch.commit(noResult: true);
      }
    });
  }

  /// Update multiple orders in batch
  Future<void> updateOrdersBatch(List<OrderModel> orders) async {
    if (orders.isEmpty) return;

    await db.transaction((Transaction txn) async {
      for (final OrderModel order in orders) {
        final Map<String, Object?> orderData = order.toJson();
        orderData.remove('customer');
        orderData.remove('orderItems');

        await txn.update(
          DatabaseTables.ordersTable,
          orderData,
          where: 'id = ?',
          whereArgs: <Object?>[order.id],
        );

        await txn.delete(
          DatabaseTables.orderItemsTable,
          where: 'orderId = ?',
          whereArgs: <Object?>[order.id],
        );

        final Batch itemBatch = txn.batch();
        for (final OrderItem? orderItem in order.orderItems) {
          itemBatch.insert(DatabaseTables.orderItemsTable, <String, Object?>{
            'orderId': order.id,
            'itemId': orderItem!.itemId,
            'quantity': orderItem.quantity,
            'status': orderItem.status,
            'isMenuItem':
                (orderItem.isMenuItem != null && orderItem.isMenuItem == true)
                ? 1
                : 0,
            'menuItemId': orderItem.menuItem?.id,
            'selectedVariationId': orderItem.selectedVariation?.id,
            'sellingPrice': orderItem.sellingPrice,
            'costPrice': orderItem.costPrice,
            'remarks': orderItem.remarks ?? '',
            'creationDate':
                orderItem.creationDate ??
                DateTime.now().toUtc().toIso8601String(),
          });
        }
        await itemBatch.commit(noResult: true);
      }
    });
  }

  /// Read a Single Order by ID:
  Future<OrderModel?> getOrderInfo(int orderId) async {
    return await db.transaction<OrderModel?>((txn) async {
      final List<Map<String, Object?>> orderResult = await txn.query(
        DatabaseTables.ordersTable,
        where: 'id = ?',
        whereArgs: <Object?>[orderId],
      );

      if (orderResult.isNotEmpty) {
        final Map<String, Object?> orderData = orderResult.first;

        final List<Map<String, Object?>> orderItemsResult = await txn.query(
          DatabaseTables.orderItemsTable,
          where: 'orderId = ?',
          whereArgs: <Object?>[orderId],
        );

        final List<OrderItem> orderItems = List<OrderItem>.generate(
          orderItemsResult.length,
          (int index) => OrderItem.fromJson(orderItemsResult[index]),
        );

        final Map<String, Object?> fullOrderData = Map<String, Object?>.from(
          orderData,
        );
        fullOrderData['orderItems'] = orderItems;

        return OrderModel.fromJson(fullOrderData);
      } else {
        return null;
      }
    });
  }

  /// Delete temporally Order
  Future<int?> updateOrderIsDeleted(int orderId, bool isDeleted) async {
    final OrderStatus currentStatus = isDeleted
        ? OrderStatus.deleted
        : OrderStatus.newOrder;
    final String currentDate = DateTime.now().toUtc().toIso8601String();

    return await db.transaction<int?>((txn) async {
      // Update order with new status and deletion flag
      await txn.update(
        DatabaseTables.ordersTable,
        <String, Object?>{
          'isDeleted': isDeleted ? 1 : 0,
          'status': currentStatus.name,
          if (!isDeleted) 'creationDate': currentDate,
          if (!isDeleted) 'modificationDate': currentDate,
        },
        where: 'id = ?',
        whereArgs: <Object?>[orderId],
      );

      // Batch update order items status accordingly
      final Batch batch = txn.batch();
      batch.update(
        DatabaseTables.orderItemsTable,
        <String, Object?>{
          'status': isDeleted
              ? OrderItemStatus.deleted.name
              : OrderItemStatus.newOrder.name,
        },
        where: 'orderId = ?',
        whereArgs: <Object?>[orderId],
      );
      await batch.commit(noResult: true);

      // Return how many order items were updated
      final result = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseTables.orderItemsTable} WHERE orderId = ?',
        [orderId],
      );
      return Sqflite.firstIntValue(result);
    });
  }

  /// Update Order Is Canceled
  Future<int?> updateOrderIsCanceled(int orderId, bool isCanceled) async {
    return await db.transaction<int?>((txn) async {
      final String currentStatus = isCanceled
          ? OrderStatus.canceled.name
          : OrderStatus.newOrder.name;

      final String currentDate = DateTime.now().toUtc().toIso8601String();

      // Update the order record
      await txn.update(
        DatabaseTables.ordersTable,
        <String, Object?>{
          'isCanceled': isCanceled ? 1 : 0,
          'status': currentStatus,
          'modificationDate': currentDate,
          if (!isCanceled) 'creationDate': currentDate,
        },
        where: 'id = ?',
        whereArgs: <Object?>[orderId],
      );

      if (!isCanceled) {
        // Reactivating: set status and reset creationDate for items
        final List<Map<String, Object?>> orderItemsResult = await txn.query(
          DatabaseTables.orderItemsTable,
          where: 'orderId = ?',
          whereArgs: <Object?>[orderId],
        );

        final Batch batch = txn.batch();

        for (final itemData in orderItemsResult) {
          batch.update(
            DatabaseTables.orderItemsTable,
            <String, Object?>{
              'status': OrderItemStatus.newOrder.name,
              'creationDate': currentDate,
            },
            where: 'id = ?',
            whereArgs: <Object?>[itemData['id']],
          );
        }

        await batch.commit(noResult: true);
      } else {
        // Canceling: only update status, don't touch creationDate
        await txn.update(
          DatabaseTables.orderItemsTable,
          <String, Object?>{'status': OrderItemStatus.canceled.name},
          where: 'orderId = ?',
          whereArgs: <Object?>[orderId],
        );
      }

      final result = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseTables.orderItemsTable} WHERE orderId = ?',
        [orderId],
      );
      return Sqflite.firstIntValue(result);
    });
  }

  ///get all order list
  Future<List<OrderModel>> getAllOrders() async {
    return await db.transaction<List<OrderModel>>((txn) async {
      final Batch batch = txn.batch();

      // Queue queries in batch
      batch.query(DatabaseTables.ordersTable, orderBy: 'creationDate DESC');
      batch.query(DatabaseTables.orderItemsTable);

      // Commit batch and get results
      final List<Object?> results = await batch.commit();

      final List<Map<String, Object?>> ordersData =
          (results[0] as List<Map<String, Object?>>);
      final List<Map<String, Object?>> orderItemsData =
          (results[1] as List<Map<String, Object?>>);

      // Build orderItemsMap
      final Map<int, List<OrderItem>> orderItemsMap = <int, List<OrderItem>>{};
      for (final Map<String, Object?> item in orderItemsData) {
        final OrderItem orderItem = OrderItem.fromJson(item);
        final int? orderId = orderItem.orderId;

        if (orderId != null) {
          orderItemsMap.putIfAbsent(orderId, () => <OrderItem>[]);
          orderItemsMap[orderId]!.add(orderItem);
        }
      }

      // Build orders list using List.generate
      final List<OrderModel> orders = List.generate(ordersData.length, (int i) {
        final OrderModel order = OrderModel.fromJson(ordersData[i]);
        final int? orderId = order.id;
        order.orderItems = orderItemsMap[orderId] ?? <OrderItem>[];
        return order;
      });

      return orders;
    });
  }

  ///get all order list with pagination
  Future<List<OrderModel>> getAllOrdersWithPagination({
    required int limit,
    required int pageNo,
  }) async {
    // Calculate offset from page number (page starts from 1)
    final int offset = (pageNo - 1) * limit;

    return await db.transaction<List<OrderModel>>((txn) async {
      final Batch batch = txn.batch();

      // Query orders with pagination
      batch.query(
        DatabaseTables.ordersTable,
        orderBy: 'creationDate DESC',
        limit: limit,
        offset: offset,
      );

      // Query all order items
      batch.query(DatabaseTables.orderItemsTable);

      // Execute both queries
      final List<Object?> results = await batch.commit();

      final List<Map<String, Object?>> ordersData =
          results[0] as List<Map<String, Object?>>;
      final List<Map<String, Object?>> orderItemsData =
          results[1] as List<Map<String, Object?>>;

      // Build orderItemsMap
      final Map<int, List<OrderItem>> orderItemsMap = <int, List<OrderItem>>{};
      for (final Map<String, Object?> item in orderItemsData) {
        final OrderItem orderItem = OrderItem.fromJson(item);
        final int? orderId = orderItem.orderId;

        if (orderId != null) {
          orderItemsMap.putIfAbsent(orderId, () => <OrderItem>[]);
          orderItemsMap[orderId]!.add(orderItem);
        }
      }

      // Build orders with List.generate
      final List<OrderModel> orders = List.generate(ordersData.length, (int i) {
        final OrderModel order = OrderModel.fromJson(ordersData[i]);
        final int? orderId = order.id;
        order.orderItems = orderItemsMap[orderId] ?? <OrderItem>[];
        return order;
      });

      return orders;
    });
  }

  ///to get all Active orders list except deleted one, only fetch associated order items
  Future<List<OrderModel>> getAllActiveOrders() async {
    return await db.transaction<List<OrderModel>>((txn) async {
      final Batch batch = txn.batch();

      // Fetch active (isDeleted = 0) orders
      batch.query(
        DatabaseTables.ordersTable,
        where: 'isDeleted = ?',
        whereArgs: <Object>[0],
        orderBy: 'creationDate ASC',
      );

      final List<Object?> results1 = await batch.commit();
      final List<Map<String, Object?>> ordersData =
          results1.first as List<Map<String, Object?>>;

      // Extract active order IDs
      final List<int> activeOrderIds = ordersData
          .map((order) => order['id'] as int)
          .toList();

      // If there are active orders, fetch only their items
      List<Map<String, Object?>> orderItemsData = <Map<String, Object?>>[];
      if (activeOrderIds.isNotEmpty) {
        // Prepare WHERE clause for IN
        final String whereClause =
            'orderId IN (${List.filled(activeOrderIds.length, '?').join(',')})';

        // Batch only the required query
        final Batch itemsBatch = txn.batch();
        itemsBatch.query(
          DatabaseTables.orderItemsTable,
          where: whereClause,
          whereArgs: activeOrderIds,
        );
        final List<Object?> itemResults = await itemsBatch.commit();
        orderItemsData = itemResults[0] as List<Map<String, Object?>>;
      }

      // Build orderItemsMap
      final Map<int, List<OrderItem>> orderItemsMap = <int, List<OrderItem>>{};
      for (final Map<String, Object?> item in orderItemsData) {
        final OrderItem orderItem = OrderItem.fromJson(item);
        final int? orderId = orderItem.orderId;
        if (orderId != null) {
          orderItemsMap.putIfAbsent(orderId, () => <OrderItem>[]);
          orderItemsMap[orderId]!.add(orderItem);
        }
      }

      // Build active orders with List.generate
      final List<OrderModel> activeOrders = List.generate(ordersData.length, (
        int i,
      ) {
        final OrderModel order = OrderModel.fromJson(ordersData[i]);
        final int? orderId = order.id;
        order.orderItems = orderItemsMap[orderId] ?? <OrderItem>[];
        return order;
      });

      return activeOrders;
    });
  }

  /// Get a list of order items and their overall total quantity to cook based on order statuses.
  Future<List<Map<String, dynamic>>> getOrderedItemsForKitchen(
    String status, {
    int chunkSize = 100,
  }) async {
    final String baseQuery =
        '''
    SELECT
      mi.name AS menuItemName,
      SUM(oi.quantity) AS TotalOrderedQuantity,
      CASE
        WHEN oi.isMenuItem = 1 THEN mi.quantity
        ELSE miv.quantity
      END AS quantity,
      CASE
        WHEN oi.isMenuItem = 1 THEN mi.purchaseUnit
        ELSE miv.purchaseUnit
      END AS purchaseUnit,
      GROUP_CONCAT(ti.name, ', ') AS tableInfoNames
    FROM ${DatabaseTables.orderItemsTable} oi
    LEFT JOIN ${DatabaseTables.menuItemsTable} mi ON oi.menuItemId = mi.id AND oi.isMenuItem = 1
    LEFT JOIN ${DatabaseTables.menuItemVariationsTable} miv ON oi.selectedVariationId = miv.id AND oi.isMenuItem = 0
    LEFT JOIN ${DatabaseTables.ordersTable} o ON oi.orderId = o.id
    LEFT JOIN ${DatabaseTables.tableInfoTable} ti ON o.tableInfoId = ti.id
    WHERE o.isCanceled = 0 AND o.isDeleted = 0
      AND o.status = ?
      AND oi.status IN ("inPreparation", "newOrder")
    GROUP BY mi.name, mi.quantity, mi.purchaseUnit, miv.quantity, miv.purchaseUnit
    ORDER BY o.creationDate ASC
    LIMIT ? OFFSET ?
  ''';

    // First: Get total count for orders in the selected status
    final countQuery =
        '''
    SELECT COUNT(*) as total FROM ${DatabaseTables.orderItemsTable} oi 
    LEFT JOIN ${DatabaseTables.ordersTable} o ON oi.orderId = o.id
    WHERE o.isCanceled = 0 AND o.isDeleted = 0 AND o.status = ? AND oi.status IN ("inPreparation", "newOrder");
  ''';

    final countResult = await db.rawQuery(countQuery, [status]);
    int totalCount = Sqflite.firstIntValue(countResult) ?? 0;

    List<Map<String, dynamic>> allResults = [];

    // Process in chunks
    for (int offset = 0; offset < totalCount; offset += chunkSize) {
      final List<Map<String, Object?>> chunkResults = await db.rawQuery(
        baseQuery,
        [status, chunkSize, offset],
      );

      final List<Map<String, dynamic>> processedChunk = List.generate(
        chunkResults.length,
        (int i) {
          final row = chunkResults[i];
          return <String, dynamic>{
            'orderItemName': row['menuItemName'] as String?,
            'TotalOrderedQuantity': row['TotalOrderedQuantity'] as int?,
            'measureInfoQuantity': row['quantity'],
            'measureInfoPurchaseUnit': row['purchaseUnit'] as String?,
            'tableInfoNames':
                (row['tableInfoNames'] as String?)
                    ?.split(', ')
                    .map((e) => e.trim())
                    .toList() ??
                <String>[],
          };
        },
      );

      allResults.addAll(processedChunk);
    }

    return allResults;
  }
}
