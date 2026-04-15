import 'dart:convert';
import 'dart:io';

import 'package:cafe_mamagement_system/model/reservation_model.dart';

import '../model/invoices/invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:synchronized/synchronized.dart';
import '../model/daily_sales_report_entry.dart';
import '../model/recipe/recipe_model.dart';
import '../utils/components/constants.dart';
import '../utils/components/date_util.dart';
import '../utils/components/local_push_notifications_api.dart';
import 'database_dao/recipes_dao.dart';
import 'database_dao/categories_dao.dart';
import 'database_dao/menu_items_dao.dart';
import 'database_dao/customers_dao.dart';
import 'database_dao/orders_dao.dart';
import 'database_dao/inventory_dao.dart';
import 'database_dao/employees_dao.dart';
import 'database_dao/invoices_dao.dart';
import 'database_dao/reports_dao.dart';
import 'database_dao/reservations_dao.dart';
import 'database_tables.dart';
import '../model/category.dart';
import '../model/sub_category.dart';
import '../model/menu_item.dart';
import '../model/customer.dart';
import 'package:cafe_mamagement_system/model/order_model/order_model.dart';
import '../model/invoices/invoice_item_model.dart';
import '../model/invoices/payment_transaction_model.dart';
import '../model/inventory_model/inventory_model.dart';
import '../model/purchase_model/purchase_model.dart';
import '../model/attendance/employee.dart';
import '../model/attendance/attendance.dart';
import '../model/attendance/leave.dart';
import '../model/table_info_model.dart';
import '../model/menu_item_review.dart';
import '../model/reports/sales_summary_model.dart';
import '../model/reports/sales_graph_model.dart';
import '../model/reports/payment_mode_report_model.dart';
import '../model/reports/top_selling_item_model.dart';
import '../model/reports/sales_forecast_model.dart';
import '../model/reports/sales_dasdboard_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  // Database info
  static const String _databaseName = 'coozy_the_cafe';
  static const secretKey = "CoozyTheCafe";
  static const int _databaseVersion = 1;

  final Lock _dbLock = Lock();
  static Database? _database;

  // DAO references
  RecipesDao? _recipeDao;
  CategoriesDao? _categoriesDao;
  MenuItemsDao? _menuItemsDao;
  CustomersDao? _customersDao;
  OrdersDao? _ordersDao;
  InventoryDao? _inventoryDao;
  EmployeesDao? _employeesDao;
  InvoicesDao? _invoicesDao;
  ReportsDao? _reportsDao;
  ReservationsDao? _reservationsDao;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future get database async {
    if (_database == null) {
      _database = await _initDatabase();

      // Create DAO objects AFTER DB is ready
      _recipeDao = RecipesDao(_database!);
      _categoriesDao = CategoriesDao(_database!);
      _menuItemsDao = MenuItemsDao(_database!);
      _customersDao = CustomersDao(_database!);
      _ordersDao = OrdersDao(_database!);
      _inventoryDao = InventoryDao(_database!);
      _employeesDao = EmployeesDao(_database!);
      _invoicesDao = InvoicesDao(_database!);
      _reportsDao = ReportsDao(_database!);
      _reservationsDao = ReservationsDao(_database!);
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    debugPrint('DatabaseHelper: _initDatabase started');
    try {
      final dbDirectory = await getDatabasesPath();
      debugPrint('DatabaseHelper: Got database path: $dbDirectory');
      final path = join(dbDirectory, _databaseName);
      debugPrint('DatabaseHelper: Full database path: $path');
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      );
      debugPrint('DatabaseHelper: Database opened successfully');
      return db;
    } catch (e, stackTrace) {
      debugPrint('DatabaseHelper: Error in _initDatabase: $e');
      debugPrint('DatabaseHelper: StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<T> _withDb<T>(Future<T> Function(Database db) operation) async {
    return _dbLock.synchronized(() async {
      final db = await database;
      return await operation(db);
    });
  }

  // Future<T> _withDbAndTime<T>(Future<T> Function(Database db) operation) async {
  //   final db = await database;
  //   final stopwatch = Stopwatch()..start();
  //   final result = await operation(db);
  //   stopwatch.stop();
  //   debugPrint('Database query took ${stopwatch.elapsedMilliseconds}ms');
  //   return result;
  // }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await _createCategoriesTables(db);
    await _createMenuTables(db);
    await _createOrderTables(db);
    await _createCustomerTables(db);
    await _createInvoiceTables(db);
    await _createRecipeTables(db);
    await _createInventoryTables(db);
    await _createEmployeeTables(db);
    await _createReservationTables(db);
  }

  // [ALL YOUR EXISTING TABLE CREATION METHODS REMAIN EXACTLY THE SAME]
  Future<void> _createCategoriesTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.categoriesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        isActive INTEGER,
        position INTEGER,
        createdDate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.subcategoriesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        createdDate TEXT,
        categoryId INTEGER,
        isActive INTEGER,
        position INTEGER,
        FOREIGN KEY (categoryId) REFERENCES ${DatabaseTables.categoriesTable}(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');
  }

  Future<void> _createMenuTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.menuItemsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        foodType TEXT,
        creationDate TEXT,
        modificationDate TEXT,
        duration INTEGER,
        categoryId INTEGER,
        subcategoryId INTEGER,
        isTodayAvailable INTEGER,
        isSimpleVariation INTEGER,
        costPrice REAL,
        sellingPrice REAL,
        stockQuantity REAL,
        quantity TEXT,
        purchaseUnit TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.menuItemVariationsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menuItemId INTEGER,
        quantity INTEGER,
        purchaseUnit TEXT,
        isTodayAvailable INTEGER,
        costPrice REAL,
        sellingPrice REAL,
        stockQuantity INTEGER,
        sortOrderIndex INTEGER,
        creationDate TEXT,
        modificationDate TEXT,
        FOREIGN KEY (menuItemId) REFERENCES ${DatabaseTables.menuItemsTable}(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.menuItemReviewsTable} (
        id INTEGER PRIMARY KEY,
        itemId INTEGER,
        customerId INTEGER,
        rating FLOAT,
        reviewText TEXT,
        reviewDate DATETIME
      );
    ''');
  }

  Future<void> _createOrderTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.ordersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableInfoId INTEGER,
        creationDate TEXT,
        modificationDate TEXT,
        isCanceled INTEGER,
        isDeleted INTEGER,
        status TEXT,
        paymentMethodName TEXT,
        paymentMethodDetails TEXT,
        deliveryAddress TEXT,
        customerId INTEGER,
        customerName TEXT,
        phoneNumber TEXT,
        FOREIGN KEY (tableInfoId) REFERENCES ${DatabaseTables.tableInfoTable}(id),
        FOREIGN KEY (customerId) REFERENCES ${DatabaseTables.customersTable}(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.orderItemsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        itemId INTEGER,
        quantity INTEGER,
        sellingPrice REAL,
        costPrice REAL,
        status TEXT,
        isMenuItem INTEGER,
        menuItemId INTEGER,
        selectedVariationId INTEGER,
        remarks TEXT,
        creationDate TEXT,
        FOREIGN KEY (orderId) REFERENCES ${DatabaseTables.ordersTable}(id),
        FOREIGN KEY (itemId) REFERENCES ${DatabaseTables.menuItemsTable}(id),
        FOREIGN KEY (menuItemId) REFERENCES ${DatabaseTables.menuItemsTable}(id),
        FOREIGN KEY (selectedVariationId) REFERENCES ${DatabaseTables.menuItemVariationsTable}(id)
      );
    ''');
  }

  Future<void> _createCustomerTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.customersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phoneNumber TEXT,
        createdDate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.tableInfoTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        colorValue TEXT,
        sortOrderIndex INTEGER,
        nosOfChairs INTEGER
      );
    ''');
  }

  Future<void> _createInvoiceTables(Database db) async {
    /// PAYMENT MODES
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.paymentModeTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      paymentMethodName TEXT NOT NULL,
      uniqueHashId TEXT UNIQUE
    );
  ''');

    /// INVOICES
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.invoicesTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER,
      invoiceHashId TEXT UNIQUE,
      taxPercentage REAL DEFAULT 0,
      discountType INTEGER DEFAULT 0,
      discountAmount REAL DEFAULT 0,
      totalCost REAL DEFAULT 0,
      taxCost REAL DEFAULT 0,
      taxableAmount REAL DEFAULT 0,
      netPaymentAmount REAL DEFAULT 0,
      createdDate TEXT,
      modifiedDate TEXT,
      customerId INTEGER,
      customerName TEXT,
      phoneNumber TEXT,
      paymentModeId INTEGER,
      paymentMethodName TEXT,
      recordAmountPaid REAL DEFAULT 0,
      paymentMethodDetails TEXT,

      FOREIGN KEY (orderId)
        REFERENCES ${DatabaseTables.ordersTable}(id)
        ON DELETE CASCADE,

      FOREIGN KEY (customerId)
        REFERENCES ${DatabaseTables.customersTable}(id)
        ON DELETE SET NULL,

      FOREIGN KEY (paymentModeId)
        REFERENCES ${DatabaseTables.paymentModeTable}(id)
        ON DELETE SET NULL
    );
  ''');

    /// INVOICE ITEMS (snapshot of order items)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.invoiceItemsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoiceId INTEGER,
      orderItemId INTEGER,
      itemId INTEGER,
      itemName TEXT,
      quantity INTEGER,
      sellingPrice REAL,
      totalPrice REAL,
      taxPercentage REAL,
      taxAmount REAL,
      discountAmount REAL,
      createdDate TEXT,

      FOREIGN KEY (invoiceId)
        REFERENCES ${DatabaseTables.invoicesTable}(id)
        ON DELETE CASCADE
    );
  ''');

    /// PAYMENT TRANSACTIONS (split payments)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.paymentTransactionsTable} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoiceId INTEGER,
      paymentModeId INTEGER,
      paymentMethodName TEXT,
      amount REAL,
      transactionReference TEXT,
      paymentStatus TEXT,
      createdDate TEXT,

      FOREIGN KEY (invoiceId)
        REFERENCES ${DatabaseTables.invoicesTable}(id)
        ON DELETE CASCADE,

      FOREIGN KEY (paymentModeId)
        REFERENCES ${DatabaseTables.paymentModeTable}(id)
    );
  ''');

    /// INDEXES for performance optimization
    /// invoice -> order lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_orderId ON ${DatabaseTables.invoicesTable}(orderId);''',
    );

    /// invoice -> customer lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_customerId ON ${DatabaseTables.invoicesTable}(customerId);''',
    );

    /// invoice -> payment mode lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_paymentModeId ON ${DatabaseTables.invoicesTable}(paymentModeId);''',
    );

    /// invoice search optimization
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_search ON ${DatabaseTables.invoicesTable}(invoiceHashId, customerName, phoneNumber);''',
    );

    /// invoice sorting by date
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_createdDate ON ${DatabaseTables.invoicesTable}(createdDate);''',
    );

    /// invoice sorting by payment amount
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoices_netPaymentAmount ON ${DatabaseTables.invoicesTable}(netPaymentAmount);''',
    );

    /// invoice items -> invoice lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoiceItems_invoiceId ON ${DatabaseTables.invoiceItemsTable}(invoiceId);''',
    );

    /// invoice items -> item lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoiceItems_itemId ON ${DatabaseTables.invoiceItemsTable}(itemId);''',
    );

    /// payment transactions -> invoice lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_paymentTransactions_invoiceId ON ${DatabaseTables.paymentTransactionsTable}(invoiceId);''',
    );

    /// payment transactions -> payment mode lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_paymentTransactions_paymentModeId ON ${DatabaseTables.paymentTransactionsTable}(paymentModeId);''',
    );

    /// payment transactions -> date lookup
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_paymentTransactions_createdDate ON ${DatabaseTables.paymentTransactionsTable}(createdDate);''',
    );
    // Index on createdDate for faster pagination
    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoice_pagination ON ${DatabaseTables.invoicesTable}(createdDate DESC, id DESC);''',
    );

    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoice_report_date ON ${DatabaseTables.invoicesTable}(createdDate);''',
    );

    await db.execute(
      '''CREATE INDEX IF NOT EXISTS idx_invoice_items_report ON ${DatabaseTables.invoiceItemsTable}(createdDate, itemId);''',
    );
  }

  Future<void> _createRecipeTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.recipeModelTable} (
        recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
        id INTEGER,
        recipe_name TEXT,
        translated_recipe_name TEXT,
        recipe_ingredients TEXT,
        recipe_translated_ingredient_list TEXT,
        recipe_translated_ingredients TEXT,
        recipe_preparation_time_in_mins INTEGER,
        recipe_cooking_time_in_mins INTEGER,
        recipe_total_time_in_mins INTEGER,
        recipe_servings INTEGER,
        recipe_cuisine TEXT,
        recipe_course TEXT,
        recipe_diet TEXT,
        recipe_instructions TEXT,
        recipe_translated_instructions TEXT,
        recipe_reference_url TEXT,
        isBookmark INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.ingredientsRecipeModelTable} (
        ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_name TEXT NOT NULL,
        recipe_ids TEXT NOT NULL,
        counter INTEGER NOT NULL DEFAULT 1
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_ingredient_name ON ${DatabaseTables.ingredientsRecipeModelTable} (ingredient_name);',
    );
    await db.execute(
      'CREATE INDEX idx_counter ON ${DatabaseTables.ingredientsRecipeModelTable} (counter);',
    );
  }

  Future<void> _createInventoryTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.inventoryTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hashId TEXT,
        name TEXT,
        shortDescription TEXT,
        purchaseUnit TEXT,
        currentStock REAL,
        isEnabled INTEGER DEFAULT 1,
        createdDate TEXT,
        modifiedDate TEXT
      );
    ''');
    await db.execute(
      'CREATE INDEX idx_inventory_name ON ${DatabaseTables.inventoryTable} (name);',
    );
    await db.execute(
      'CREATE INDEX idx_inventory_isEnabled ON ${DatabaseTables.inventoryTable} (isEnabled);',
    );

    await db.execute('''
      CREATE TABLE ${DatabaseTables.purchaseTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hashId TEXT,
        inventoryId INTEGER,
        name TEXT,
        purchaseUnit TEXT,
        purchaseQty REAL,
        purchaseDateTime TEXT,
        purchasePrice REAL,
        createdDate TEXT,
        modifiedDate TEXT,
        FOREIGN KEY (inventoryId) REFERENCES ${DatabaseTables.inventoryTable}(id)
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_purchase_name ON ${DatabaseTables.purchaseTable} (name);',
    );
    await db.execute(
      'CREATE INDEX idx_purchase_inventoryId ON ${DatabaseTables.purchaseTable} (inventoryId);',
    );
    await db.execute(
      'CREATE INDEX idx_purchase_purchaseDateTime ON ${DatabaseTables.purchaseTable} (purchaseDateTime);',
    );
  }

  Future<void> _createEmployeeTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.employeesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        creationDate TEXT,
        modificationDate TEXT,
        phoneNumber TEXT,
        position TEXT,
        joiningDate TEXT,
        leavingDate TEXT,
        startWorkingTime TEXT,
        endWorkingTime TEXT,
        workingHours TEXT,
        isDeleted INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.attendanceTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId INTEGER,
        currentStatus INTEGER,
        creationDate TEXT,
        modificationDate TEXT,
        checkIn TEXT,
        checkOut TEXT,
        employeeWorkingDurations TEXT,
        workingTimeDurations TEXT,
        isDeleted INTEGER,
        FOREIGN KEY (employeeId) REFERENCES ${DatabaseTables.employeesTable}(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseTables.leavesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId INTEGER,
        currentStatus INTEGER,
        creationDate TEXT,
        modificationDate TEXT,
        startDate TEXT,
        endDate TEXT,
        reason TEXT,
        isDeleted INTEGER,
        FOREIGN KEY (employeeId) REFERENCES ${DatabaseTables.employeesTable}(id)
      );
    ''');
  }

  Future<void> _createReservationTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseTables.reservationsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT,
        phoneNumber TEXT,
        customerId INTEGER,
        tableId INTEGER,
        tableName TEXT,
        reservationDateTime TEXT,
        numberOfPeople INTEGER,
        status INTEGER,
        notes TEXT,
        creationDate TEXT,
        modificationDate TEXT,
        FOREIGN KEY (tableId) REFERENCES ${DatabaseTables.tableInfoTable}(id) ON DELETE SET NULL,
        FOREIGN KEY (customerId) REFERENCES ${DatabaseTables.customersTable}(id) ON DELETE SET NULL
      );
    ''');
  }

  /// Deletes all records from a specific table.
  Future<void> clearTable(String tableName) async {
    await _withDb((db) async {
      await db.delete(tableName);
      await db.delete(
        'sqlite_sequence',
        where: 'name = ?',
        whereArgs: [tableName],
      );
    });
  }

  /// Deletes all records from all tables in the database.
  Future<void> clearAllTables() async {
    await _withDb((db) async {
      final tables = await getAllTableNames();
      final batch = db.batch();
      for (var table in tables) {
        batch.delete(table);
        batch.delete('sqlite_sequence', where: 'name = ?', whereArgs: [table]);
      }
      await batch.commit(noResult: true);
    });
  }

  /// Wipes the entire database file from disk.
  Future<void> wipeDatabase() async {
    await _dbLock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      final dbPath = await getDbPath();
      await deleteDatabase(dbPath);
      debugPrint('Database wiped.');
    });
  }

  // -------------------- UTILITY METHODS --------------------
  Future<String> getDbPath() async {
    try {
      final dbDirectory = await getDatabasesPath();
      final path = join(dbDirectory, _databaseName);
      return path;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAllTableNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name NOT IN (?, ?, ?, ?)',
      [
        'table',
        'android_metadata',
        'sqlite_sequence',
        'room_master_table',
        'sqlite_master',
      ],
    );
    return maps.map((row) => row['name'] as String).toList(growable: false);
  }

  // -------------------- BACKUP & RESTORE --------------------
  Future<String> backupDatabase({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, "Requesting permissions...");
    await _requestPermissions();

    final sourceFilePath = await getDbPath();
    final sourceFile = File(sourceFilePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database file not found at $sourceFilePath');
    }

    onProgress?.call(0.05, "Closing active database...");
    // Close DB first to avoid locks
    await _dbLock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    });

    onProgress?.call(0.1, "Creating backup file...");
    // Create backup file
    final backupDir = await _getBackupDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFilename = 'coozy_backup_$timestamp.db';
    final backupFile = File(join(backupDir.path, backupFilename));

    // Copy database with stream chunking for progress
    final totalBytes = await sourceFile.length();
    int bytesCopied = 0;

    final readStream = sourceFile.openRead();
    final writeSink = backupFile.openWrite();

    await for (final chunk in readStream) {
      writeSink.add(chunk);
      bytesCopied += chunk.length;

      // Progress from 10% to 50%
      double copyProgress = 0.1 + ((bytesCopied / totalBytes) * 0.4);
      onProgress?.call(copyProgress, "Copying database file...");
    }
    await writeSink.close();

    String finalBackupPath = backupFile.path;

    // Encrypt backup if requested
    if (encryptBackup) {
      final encryptedFile = await _encryptFile(
        backupFile,
        onProgress: onProgress,
      );
      await backupFile.delete(); // Remove unencrypted backup
      finalBackupPath = encryptedFile.path;
    }

    onProgress?.call(0.95, "Reopening database...");
    // Reopen database
    _database = await _initDatabase();

    onProgress?.call(1.0, "Backup complete!");
    debugPrint('Backup completed: $finalBackupPath');
    return finalBackupPath;
  }

  Future<void> restoreDatabase(
    String backupFilePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, "Requesting permissions...");
    await _requestPermissions();

    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found: $backupFilePath');
    }

    onProgress?.call(0.02, "Closing active database...");
    // Close DB first using lock
    await _dbLock.synchronized(() async {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    });

    final dbPath = await getDbPath();
    final targetFile = File(dbPath);

    // Handle decryption if needed
    File sourceFile;
    if (backupFilePath.endsWith('.enc')) {
      sourceFile = await _decryptFile(backupFile, onProgress: onProgress);
    } else {
      sourceFile = backupFile;
      onProgress?.call(0.5, "Preparing unencrypted backup...");
    }

    // Copy restored database mapping progress from 50% to 95%
    onProgress?.call(0.5, "Restoring database file...");
    final totalBytes = await sourceFile.length();
    int bytesCopied = 0;

    final readStream = sourceFile.openRead();
    final writeSink = targetFile.openWrite();

    await for (final chunk in readStream) {
      writeSink.add(chunk);
      bytesCopied += chunk.length;

      double restoreProgress = 0.5 + ((bytesCopied / totalBytes) * 0.45);
      onProgress?.call(restoreProgress, "Restoring database file...");
    }
    await writeSink.close();

    // Clean up temporary decrypted file
    if (backupFilePath.endsWith('.enc') &&
        sourceFile.path.endsWith('.decrypted')) {
      await sourceFile.delete();
    }

    onProgress?.call(0.95, "Reopening database...");
    // Reopen database
    _database = await _initDatabase();

    onProgress?.call(1.0, "Database restored successfully!");
    debugPrint('Database restored from: $backupFilePath');
  }

  Future<Directory> _getBackupDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      if (await Permission.storage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<File> _encryptFile(
    File inputFile, {
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.55, "Preparing encryption securely...");
    final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '0'));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    onProgress?.call(0.65, "Reading backup data...");
    final inputBytes = await inputFile.readAsBytes();

    onProgress?.call(0.75, "Encrypting data...");
    final encrypted = encrypter.encryptBytes(inputBytes, iv: iv);

    onProgress?.call(0.85, "Saving encrypted backup...");
    final encryptedFile = File('${inputFile.path}.enc');
    await encryptedFile.writeAsBytes(encrypted.bytes);

    // Save IV for decryption
    final ivFile = File('${inputFile.path}.iv');
    await ivFile.writeAsString(iv.base64);

    Constants.debugLog(DatabaseHelper, 'Encryption IV saved: ${iv.base64}');
    return encryptedFile;
  }

  Future<String> backupCurrentDayOrdersAndInvoices({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    final now = DateTime.now().toUtc();
    final startDate = DateTime.utc(now.year, now.month, now.day);
    final endDate = DateTime.utc(now.year, now.month, now.day, 23, 59, 59, 999);
    return backupOrdersAndInvoicesRange(
      startDate,
      endDate,
      filePrefix: 'coozy_daily_orders_invoices',
      encryptBackup: encryptBackup,
      onProgress: onProgress,
    );
  }

  Future<String> backupCurrentWeekOrdersAndInvoices({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    final now = DateTime.now().toUtc();
    final startOfWeek = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final endDate = DateTime.utc(now.year, now.month, now.day, 23, 59, 59, 999);
    return backupOrdersAndInvoicesRange(
      startOfWeek,
      endDate,
      filePrefix: 'coozy_weekly_orders_invoices',
      encryptBackup: encryptBackup,
      onProgress: onProgress,
    );
  }

  Future<String> backupOrdersAndInvoicesRange(
    DateTime startDate,
    DateTime endDate, {
    String filePrefix = 'coozy_orders_invoices',
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Preparing order/invoice backup...');
    final db = await database;
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();
    const int batchSize = 200;

    onProgress?.call(0.1, 'Counting matching orders...');
    final List<Map<String, Object?>> orderCountResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.ordersTable} WHERE creationDate >= ? AND creationDate <= ?',
      [startIso, endIso],
    );
    final int totalOrders =
        int.tryParse(orderCountResult.first['count'].toString()) ?? 0;

    onProgress?.call(0.15, 'Counting matching invoices...');
    final List<Map<String, Object?>> invoiceCountResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.invoicesTable} WHERE createdDate >= ? AND createdDate <= ?',
      [startIso, endIso],
    );
    final int totalInvoices =
        int.tryParse(invoiceCountResult.first['count'].toString()) ?? 0;

    onProgress?.call(0.2, 'Creating backup file...');
    final backupDir = await _getBackupDirectory();
    final startLabel = DateUtil.formatDateLabel(startDate);
    final endLabel = DateUtil.formatDateLabel(endDate);
    final backupFilename = '${filePrefix}_${startLabel}_to_$endLabel.json';
    final backupFile = File(join(backupDir.path, backupFilename));
    final IOSink sink = backupFile.openWrite();

    sink.write('{\n');
    sink.write(
      '  "generatedDate": "${DateTime.now().toUtc().toIso8601String()}",\n',
    );
    sink.write('  "range": {\n');
    sink.write('    "startDate": "$startIso",\n');
    sink.write('    "endDate": "$endIso"\n');
    sink.write('  },\n');
    sink.write('  "orders": [\n');

    bool firstOrder = true;
    int processedOrders = 0;

    for (int offset = 0; offset < totalOrders; offset += batchSize) {
      final List<Map<String, Object?>> orderMaps = await db.query(
        DatabaseTables.ordersTable,
        where: 'creationDate >= ? AND creationDate <= ?',
        whereArgs: [startIso, endIso],
        orderBy: 'creationDate DESC, id DESC',
        limit: batchSize,
        offset: offset,
      );

      for (final orderMap in orderMaps) {
        final orderId = orderMap['id'] as int?;
        if (orderId != null) {
          final orderItems = await db.query(
            DatabaseTables.orderItemsTable,
            where: 'orderId = ?',
            whereArgs: [orderId],
          );
          orderMap['orderItems'] = orderItems;
        }

        final String orderJson = const JsonEncoder.withIndent(
          '  ',
        ).convert(orderMap);
        final String indentedOrderJson = orderJson
            .split('\n')
            .map((line) => '    $line')
            .join('\n');

        if (!firstOrder) {
          sink.write(',\n');
        }
        sink.write(indentedOrderJson);
        firstOrder = false;

        processedOrders++;
        if (totalOrders > 0) {
          final double progress = 0.2 + (processedOrders / totalOrders) * 0.25;
          onProgress?.call(progress.clamp(0.2, 0.45), 'Backing up orders...');
        }
      }
    }

    sink.write('\n  ],\n');
    sink.write('  "invoices": [\n');

    bool firstInvoice = true;
    int processedInvoices = 0;

    for (int offset = 0; offset < totalInvoices; offset += batchSize) {
      final List<Map<String, Object?>> invoiceMaps = await db.query(
        DatabaseTables.invoicesTable,
        where: 'createdDate >= ? AND createdDate <= ?',
        whereArgs: [startIso, endIso],
        orderBy: 'createdDate DESC, id DESC',
        limit: batchSize,
        offset: offset,
      );

      for (final invoiceMap in invoiceMaps) {
        final invoiceId = invoiceMap['id'] as int?;
        if (invoiceId != null) {
          final invoiceItems = await db.query(
            DatabaseTables.invoiceItemsTable,
            where: 'invoiceId = ?',
            whereArgs: [invoiceId],
          );
          final payments = await db.query(
            DatabaseTables.paymentTransactionsTable,
            where: 'invoiceId = ?',
            whereArgs: [invoiceId],
          );
          invoiceMap['items'] = invoiceItems;
          invoiceMap['payments'] = payments;
        }

        final String invoiceJson = const JsonEncoder.withIndent(
          '  ',
        ).convert(invoiceMap);
        final String indentedInvoiceJson = invoiceJson
            .split('\n')
            .map((line) => '    $line')
            .join('\n');

        if (!firstInvoice) {
          sink.write(',\n');
        }
        sink.write(indentedInvoiceJson);
        firstInvoice = false;

        processedInvoices++;
        if (totalInvoices > 0) {
          final double progress =
              0.45 + (processedInvoices / totalInvoices) * 0.25;
          onProgress?.call(progress.clamp(0.45, 0.7), 'Backing up invoices...');
        }
      }
    }

    sink.write('\n  ]\n');
    sink.write('}\n');
    await sink.close();

    onProgress?.call(0.75, 'Finalizing backup...');
    String finalBackupPath = backupFile.path;

    if (encryptBackup) {
      final encryptedFile = await _encryptFile(
        backupFile,
        onProgress: onProgress,
      );
      await backupFile.delete();
      finalBackupPath = encryptedFile.path;
    }

    onProgress?.call(1.0, 'Backup complete!');
    debugPrint('Orders and invoices backup completed: $finalBackupPath');
    return finalBackupPath;
  }

  Future<File> _decryptFile(
    File encryptedFile, {
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.05, "Preparing decryption securely...");
    final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '0'));

    // Read IV from companion file
    final ivPath = encryptedFile.path.replaceAll('.enc', '.iv');
    final ivFile = File(ivPath);
    if (!await ivFile.exists()) {
      throw Exception('IV file not found for decryption: $ivPath');
    }

    onProgress?.call(0.15, "Reading encryption parameters...");
    final ivBase64 = await ivFile.readAsString();
    final iv = encrypt.IV.fromBase64(ivBase64);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    onProgress?.call(0.25, "Reading encrypted backup data...");
    final encryptedBytes = await encryptedFile.readAsBytes();

    onProgress?.call(0.35, "Decrypting data...");
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(encryptedBytes),
      iv: iv,
    );

    onProgress?.call(0.45, "Saving decrypted temporary file...");
    final decryptedFile = File('${encryptedFile.path}.decrypted');
    await decryptedFile.writeAsBytes(decrypted);

    return decryptedFile;
  }

  // -------------------- Clear All Record from TABLES OF DATABASE --------------------
  Future<void> clearDatabase() => _withDb((db) async {
    await db.transaction((Transaction txn) async {
      final tables = await txn.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );

      for (final table in tables) {
        final tableName = table['name'] as String;
        await txn.delete(tableName);
        await txn.execute(
          "DELETE FROM sqlite_sequence WHERE name = '$tableName'",
        );
      }
    });
  });

  void scheduleDailyBusinessReport({TimeOfDay? reportTime}) {
    // Default to 11:00 PM if not specified
    NotificationApi.init(initScheduled: true);
    NotificationApi.requestNotificationPermission();

    final DateTime now = DateTime.now();
    final DateTime dailyTime = DateTime(
      now.year,
      now.month,
      now.day,
      reportTime?.hour ?? 23,
      reportTime?.minute ?? 0,
      0,
    );

    NotificationApi.showDailyNotification(
      time: dailyTime,
      title: "Daily Business Report",
      body: "Click to generate your daily business excel report.",
      payload: "run_business_report",
    );
  }

  // ------------------ Recipes DAO Wrappers ------------------

  /// Inserts the given list of recipes into the database.
  Future<void> insertRecipes(List<RecipeModel> recipes) async {
    await database;
    await _recipeDao?.insertRecipes(recipes);
  }

  /// Inserts recipe data in chunks to reduce memory pressure.
  Future<void> insertRecipesChunked(List<RecipeModel>? recipes) async {
    await database;
    await _recipeDao?.insertRecipesChunked(recipes);
  }

  /// Updates an existing recipe record.
  Future<int?> updateRecipe(RecipeModel recipe) async {
    await database;
    return await _recipeDao?.updateRecipe(recipe);
  }

  /// Deletes a recipe by its ID.
  Future<int?> deleteRecipe({int? id}) async {
    await database;
    return await _recipeDao?.deleteRecipe(id: id);
  }

  /// Deletes multiple recipes by their IDs.
  Future<List<int>> deleteRecipesBatch(List<int> ids) async {
    await database;
    return await _recipeDao?.deleteRecipesBatch(ids) ?? [];
  }

  /// Returns all recipes in chunks to avoid loading large datasets at once.
  Future<List<RecipeModel>?> getRecipes({int chunkSize = 200}) async {
    await database;
    return await _recipeDao?.getRecipes(chunkSize: chunkSize);
  }

  /// Returns all bookmarked recipes.
  Future<List<RecipeModel>?> getBookmarkedRecipes() async {
    await database;
    return await _recipeDao?.getBookmarkedRecipes();
  }

  /// Processes ingredients for all recipes in the database.
  Future<void> processRecipeIngredients({
    int chunkSize = 200,
    void Function(double progress)? onProgress,
  }) async {
    await database;
    await _recipeDao?.processRecipeIngredients(
      chunkSize: chunkSize,
      onProgress: onProgress,
    );
  }

  /// Processes ingredients for a single recipe.
  Future<void> processSingleRecipeIngredients(RecipeModel recipe) async {
    await database;
    await _recipeDao?.processSingleRecipeIngredients(recipe);
  }

  /// Extracts ingredient names from a raw ingredient string.
  List<String>? extractIngredients(String rawIngredients) {
    return _recipeDao?.extractIngredients(rawIngredients);
  }

  /// Searches ingredients by a term using a case-insensitive lookup.
  Future<List<Map<String, dynamic>>?> searchIngredients(
    String? searchTerm,
  ) async {
    await database;
    return await _recipeDao?.searchIngredients(searchTerm);
  }

  /// Fetches all ingredient records.
  Future<List<Map<String, dynamic>>?> fetchAllIngredients() async {
    await database;
    return await _recipeDao?.fetchAllIngredients();
  }

  // ------------------ Categories DAO Wrappers ------------------
  /// Adds a new category record.
  Future<int?> addCategory(Category category) async {
    await database;
    return await _categoriesDao?.addCategory(category);
  }

  /// Retrieves all categories ordered by position.
  Future<List<Category>?> getCategories() async {
    await database;
    return await _categoriesDao?.getCategories();
  }

  /// Updates a category record.
  Future<int?> updateCategory(Category category) async {
    await database;
    return await _categoriesDao?.updateCategory(category);
  }

  /// Retrieves a category by its name.
  Future<Category?> getCategoryBasedOnName({String? name}) async {
    await database;
    return await _categoriesDao?.getCategoryBasedOnName(name: name);
  }

  /// Retrieves a category by its ID.
  Future<Category?> getCategoryBasedOnCategoryId({
    required int? categoryId,
  }) async {
    await database;
    return await _categoriesDao?.getCategoryBasedOnCategoryId(
      categoryId: categoryId,
    );
  }

  /// Deletes a category and maintains ordering.
  Future<int?> deleteCategory(Category? model) async {
    await database;
    return await _categoriesDao?.deleteCategory(model);
  }

  // ------------------ Subcategory DAO Wrappers ------------------
  /// Creates a new subcategory record.
  Future<int?> createSubcategory(SubCategory subcategory) async {
    await database;
    return await _categoriesDao?.createSubcategory(subcategory);
  }

  /// Retrieves all subcategories.
  Future<List<SubCategory>?> getSubcategories() async {
    await database;
    return await _categoriesDao?.getSubcategories();
  }

  /// Retrieves all subcategories for a specific category.
  Future<List<SubCategory>?> getSubcategoryBaseCategoryId(
    int categoryId,
  ) async {
    await database;
    return await _categoriesDao?.getSubcategoryBaseCategoryId(categoryId);
  }

  /// Updates a subcategory record.
  Future<int?> updateSubcategory(SubCategory subcategory) async {
    await database;
    return await _categoriesDao?.updateSubcategory(subcategory);
  }

  /// Deletes a subcategory by ID.
  Future<int?> deleteSubcategory(int id) async {
    await database;
    return await _categoriesDao?.deleteSubcategory(id);
  }

  /// Deletes all subcategories for a category ID.
  Future<int?> deleteAllSubcategoryBasedOnCategoryId({int? categoryId}) async {
    await database;
    return await _categoriesDao?.deleteAllSubcategoryBasedOnCategoryId(
      categoryId: categoryId,
    );
  }

  /// Inserts subcategories for a given category.
  Future<void> insertSubCategoriesForCategoryId({
    required int? categoryId,
    required List<SubCategory> subCategories,
  }) async {
    await database;
    await _categoriesDao?.insertSubCategoriesForCategoryId(
      categoryId: categoryId,
      subCategories: subCategories,
    );
  }

  // ------------------ Menu Items DAO Wrappers ------------------
  /// Creates a new menu item and associated variations.
  Future<int?> createMenuItem(MenuItem menuItem) async {
    await database;
    return await _menuItemsDao?.createMenuItem(menuItem);
  }

  /// Updates an existing menu item and its variations.
  Future<int?> updateMenuItem(MenuItem menuItem) async {
    await database;
    return await _menuItemsDao?.updateMenuItem(menuItem);
  }

  /// Retrieves a menu item by its ID.
  Future<MenuItem?> getMenuItemById(int id) async {
    await database;
    return await _menuItemsDao?.getMenuItemById(id);
  }

  /// Deletes a menu item and its associated variations.
  Future<void> deleteMenuItem(int? menuItemId) async {
    await database;
    await _menuItemsDao?.deleteMenuItem(menuItemId);
  }

  /// Retrieves all menu items.
  Future<List<MenuItem>?> getAllMenuItems() async {
    await database;
    return await _menuItemsDao?.getAllMenuItems();
  }

  /// Retrieves all menu items that are available today.
  Future<List<MenuItem>> getAvailableMenuItems() async {
    await database;
    return await _menuItemsDao?.getAvailableMenuItems() ?? [];
  }

  /// Returns a paginated list of available menu items.
  Future<List<MenuItem>> getAvailableMenuItemsPagination({
    required int pageNumber,
    required int limit,
    String? searchTerm,
  }) async {
    await database;
    return await _menuItemsDao?.getAvailableMenuItemsPagination(
          pageNumber: pageNumber,
          limit: limit,
          searchTerm: searchTerm,
        ) ??
        [];
  }

  /// Fetches paginated menu items with optional search.
  Future<List<MenuItem>> fetchAllMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    await database;
    return await _menuItemsDao?.fetchAllMenuItemsPaged(
          pageNumber: pageNumber,
          limit: limit,
          search: search,
        ) ??
        [];
  }

  /// Counts menu items matching an optional search query.
  Future<int> fetchMenuItemsCount({String? search}) async {
    await database;
    return await _menuItemsDao?.fetchMenuItemsCount(search: search) ?? 0;
  }

  /// Fetches paginated available menu items with optional search.
  Future<List<MenuItem>?> fetchAvailableMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    await database;
    return await _menuItemsDao?.fetchAvailableMenuItemsPaged(
      pageNumber: pageNumber,
      limit: limit,
      search: search,
    );
  }

  // ------------------ Menu Item Reviews DAO Wrappers ------------------
  /// Retrieves reviews for the given menu item.
  Future<List<MenuItemReview>> getReviewsForMenuItem(int itemId) async {
    await database;
    return await _menuItemsDao?.getReviewsForMenuItem(itemId) ?? [];
  }

  /// Calculates the average rating for a specific menu item.
  Future<double> calculateAverageRatingForMenuItem(int itemId) async {
    await database;
    return await _menuItemsDao?.calculateAverageRatingForMenuItem(itemId) ??
        0.0;
  }

  // ------------------ Menu Item Sales Reports DAO Wrappers ------------------
  /// Generates daily sales report data for a menu item or variation.
  Future<List<MenuItemSalesReport>> generateDailySalesReportForMenuItem({
    required int itemId,
    required DateTime fromDate,
    required DateTime toDate,
    bool isMenuItem = true,
  }) async {
    await database;
    return await _menuItemsDao?.generateDailySalesReportForMenuItem(
          itemId: itemId,
          fromDate: fromDate,
          toDate: toDate,
          isMenuItem: isMenuItem,
        ) ??
        [];
  }

  /// Generates monthly sales report data for a menu item or variation.
  Future<List<MenuItemSalesReport>> generateMonthlySalesReportForMenuItem({
    required int itemId,
    required DateTime fromDate,
    required DateTime toDate,
    bool isMenuItem = true,
  }) async {
    await database;
    return await _menuItemsDao?.generateMonthlySalesReportForMenuItem(
          itemId: itemId,
          fromDate: fromDate,
          toDate: toDate,
          isMenuItem: isMenuItem,
        ) ??
        [];
  }

  // ------------------ Customers DAO Wrappers ------------------
  /// Creates a new customer record.
  Future<int> createCustomer(Customer customer) async {
    await database;
    return await _customersDao?.createCustomer(customer) ?? 0;
  }

  /// Retrieves a customer by ID.
  Future<Customer?> getCustomer(int id) async {
    await database;
    return await _customersDao?.getCustomer(id);
  }

  /// Searches customers with optional pagination.
  Future<List<Customer>?> searchCustomers({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    await database;
    return await _customersDao?.searchCustomers(
      pageNumber: pageNumber,
      limit: limit,
      search: search,
    );
  }

  /// Checks whether a customer exists by name or phone number.
  Future<bool> isCustomerExist(String searchTerm) async {
    await database;
    return await _customersDao?.isCustomerExist(searchTerm) ?? false;
  }

  /// Updates an existing customer record.
  Future<int?> updateCustomer(Customer customer) async {
    await database;
    return await _customersDao?.updateCustomer(customer);
  }

  /// Deletes a customer by ID.
  Future<int?> deleteCustomer(int id) async {
    await database;
    return await _customersDao?.deleteCustomer(id);
  }

  // ------------------ Table Info DAO Wrappers ------------------
  /// Inserts a new table information record.
  Future<int?> addTableInfo(TableInfoModel newTableInfo) async {
    await database;
    return await _customersDao?.addTableInfo(newTableInfo);
  }

  /// Retrieves all table information records.
  Future<List<TableInfoModel>?> getTableInfos() async {
    await database;
    return await _customersDao?.getTableInfos();
  }

  /// Retrieves a page of table information records.
  Future<List<TableInfoModel>?> getTableInfosPage({
    int limit = 20,
    int pageNumber = 1,
  }) async {
    await database;
    return await _customersDao?.getTableInfosPage(
      limit: limit,
      pageNumber: pageNumber,
    );
  }

  /// Retrieves table information by ID.
  Future<TableInfoModel?> getTableInfo(int id) async {
    await database;
    return await _customersDao?.getTableInfo(id);
  }

  /// Updates a table information record.
  Future<int?> updateTableInfo(TableInfoModel tableInfo) async {
    await database;
    return await _customersDao?.updateTableInfo(tableInfo);
  }

  /// Returns the total count of table information records.
  Future<int> getTableInfoRecordCount() async {
    await database;
    return await _customersDao?.getTableInfoRecordCount() ?? 0;
  }

  /// Deletes a table information record.
  Future<int?> deleteTableInfo(TableInfoModel model) async {
    await database;
    return await _customersDao?.deleteTableInfo(model);
  }

  // ------------------ Orders DAO Wrappers ------------------
  /// Creates a new order with its items.
  Future<int?> createNewOrder(OrderModel order) async {
    await database;
    return await _ordersDao?.createNewOrder(order);
  }

  /// Updates an existing order and its items.
  Future<void> updateOrder(OrderModel order) async {
    await database;
    await _ordersDao?.updateOrder(order);
  }

  /// Retrieves order details by ID.
  Future<OrderModel?> getOrderInfo(int orderId) async {
    await database;
    return await _ordersDao?.getOrderInfo(orderId);
  }

  /// Marks an order as deleted or active.
  Future<int?> updateOrderIsDeleted(int orderId, bool isDeleted) async {
    await database;
    return await _ordersDao?.updateOrderIsDeleted(orderId, isDeleted);
  }

  /// Cancels or restores an order.
  Future<int?> updateOrderIsCanceled(int orderId, bool isCanceled) async {
    await database;
    return await _ordersDao?.updateOrderIsCanceled(orderId, isCanceled);
  }

  /// Retrieves all orders.
  Future<List<OrderModel>> getAllOrders() async {
    await database;
    return await _ordersDao?.getAllOrders() ?? [];
  }

  /// Retrieves orders with pagination.
  Future<List<OrderModel>> getAllOrdersWithPagination({
    required int limit,
    required int pageNo,
  }) async {
    await database;
    return await _ordersDao?.getAllOrdersWithPagination(
          limit: limit,
          pageNo: pageNo,
        ) ??
        [];
  }

  /// Retrieves all active (non-deleted) orders.
  Future<List<OrderModel>> getAllActiveOrders() async {
    await database;
    return await _ordersDao?.getAllActiveOrders() ?? [];
  }

  /// Retrieves kitchen order summaries for the specified status.
  Future<List<Map<String, dynamic>>> getOrderedItemsForKitchen(
    String status, {
    int chunkSize = 100,
  }) async {
    await database;
    return await _ordersDao?.getOrderedItemsForKitchen(
          status,
          chunkSize: chunkSize,
        ) ??
        [];
  }

  // ------------------ Inventory DAO Wrappers ------------------
  /// Inserts a new inventory item.
  Future<int> insertInventory(InventoryModel inventory) async {
    await database;
    return await _inventoryDao?.insertInventory(inventory) ?? 0;
  }

  /// Updates an existing inventory item.
  Future<int> updateInventory(InventoryModel inventory) async {
    await database;
    return await _inventoryDao?.updateInventory(inventory) ?? 0;
  }

  /// Deletes an inventory item by ID.
  Future<int> deleteInventory(int id) async {
    await database;
    return await _inventoryDao?.deleteInventory(id) ?? 0;
  }

  /// Inserts multiple inventory items in batch.
  Future<void> insertInventoryBatch(List<InventoryModel> items) async {
    await database;
    await _inventoryDao?.insertInventoryBatch(items);
  }

  /// Updates multiple inventory items in batch.
  Future<void> updateInventoryBatch(List<InventoryModel> items) async {
    await database;
    await _inventoryDao?.updateInventoryBatch(items);
  }

  /// Deletes multiple inventory items by IDs.
  Future<void> deleteInventoryBatch(List<int> ids) async {
    await database;
    await _inventoryDao?.deleteInventoryBatch(ids);
  }

  /// Retrieves all enabled inventory items.
  Future<List<InventoryModel>> getAllEnableInventory() async {
    await database;
    return await _inventoryDao?.getAllEnableInventory() ?? [];
  }

  /// Retrieves a page of enabled inventory items.
  Future<List<InventoryModel>> getAllEnableInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    await database;
    return await _inventoryDao?.getAllEnableInventoryPage(
          page: page,
          pageSize: pageSize,
          searchQuery: searchQuery,
        ) ??
        [];
  }

  /// Searches enabled inventory items by name or description.
  Future<List<InventoryModel>> searchInventoryByNameOrDescription({
    required String query,
  }) async {
    await database;
    return await _inventoryDao?.searchInventoryByNameOrDescription(
          query: query,
        ) ??
        [];
  }

  /// Retrieves all inventory items.
  Future<List<InventoryModel>> getInventory() async {
    await database;
    return await _inventoryDao?.getInventory() ?? [];
  }

  /// Retrieves a page of inventory items.
  Future<List<InventoryModel>> getInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    await database;
    return await _inventoryDao?.getInventoryPage(
          page: page,
          pageSize: pageSize,
          searchQuery: searchQuery,
        ) ??
        [];
  }

  /// Retrieves distinct first letters of enabled inventory items.
  Future<List<String>> getEnabledInventoryFirstLetters({
    String? searchQuery,
  }) async {
    await database;
    return await _inventoryDao?.getEnabledInventoryFirstLetters(
          searchQuery: searchQuery,
        ) ??
        [];
  }

  /// Retrieves distinct first letters for all inventory items.
  Future<List<String>> getAllInventoryFirstLetters({
    String? searchQuery,
  }) async {
    await database;
    return await _inventoryDao?.getAllInventoryFirstLetters(
          searchQuery: searchQuery,
        ) ??
        [];
  }

  // ------------------ Purchases DAO Wrappers ------------------
  /// Inserts a new purchase record.
  Future<int> insertPurchase(PurchaseModel purchase) async {
    await database;
    return await _inventoryDao?.insertPurchase(purchase) ?? 0;
  }

  /// Updates an existing purchase record.
  Future<int> updatePurchase(PurchaseModel purchase) async {
    await database;
    return await _inventoryDao?.updatePurchase(purchase) ?? 0;
  }

  /// Deletes a purchase record by ID.
  Future<int> deletePurchase(int id) async {
    await database;
    return await _inventoryDao?.deletePurchase(id) ?? 0;
  }

  /// Inserts purchase records in batch.
  Future<void> insertPurchaseBatch(List<PurchaseModel> purchases) async {
    await database;
    await _inventoryDao?.insertPurchaseBatch(purchases);
  }

  /// Updates purchase records in batch.
  Future<void> updatePurchaseBatch(List<PurchaseModel> purchases) async {
    await database;
    await _inventoryDao?.updatePurchaseBatch(purchases);
  }

  /// Deletes purchase records in batch.
  Future<void> deletePurchaseBatch(List<int> ids) async {
    await database;
    await _inventoryDao?.deletePurchaseBatch(ids);
  }

  /// Retrieves all purchase records.
  Future<List<PurchaseModel>> getAllPurchases() async {
    await database;
    return await _inventoryDao?.getAllPurchases() ?? [];
  }

  /// Retrieves total expenditure cost for a specific date.
  Future<double> getDailyExpenditureCost(String currentDate) async {
    await database;
    return await _inventoryDao?.getDailyExpenditureCost(currentDate) ?? 0.0;
  }

  /// Retrieves total expenditure cost for a specific month.
  Future<double> getMonthlyExpenditureCost(String month) async {
    await database;
    return await _inventoryDao?.getMonthlyExpenditureCost(month) ?? 0.0;
  }

  /// Retrieves purchases between two timestamps.
  Future<List<PurchaseModel>> getPurchasesBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    await database;
    return await _inventoryDao?.getPurchasesBetweenDates(
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        ) ??
        [];
  }

  /// Retrieves expenditure data between two timestamps.
  Future<double> getExpenditureBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    await database;
    return await _inventoryDao?.getExpenditureBetweenDates(
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        ) ??
        0.0;
  }

  /// Retrieves expenditure graph data for the provided range.
  Future<Map<String, List<Map<String, dynamic>>>> getExpenditureGraphData({
    required String month,
    required String year,
    required String fromDateTime,
    required String toDateTime,
  }) async {
    await database;
    return await _inventoryDao?.getExpenditureGraphData(
          month: month,
          year: year,
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        ) ??
        {};
  }

  // ------------------ Employees DAO Wrappers ------------------
  /// Adds a new employee record.
  Future<int> addEmployee(Employee employee) async {
    await database;
    return await _employeesDao?.addEmployee(employee) ?? 0;
  }

  /// Updates an existing employee record.
  Future<int> updateEmployee(Employee employee) async {
    await database;
    return await _employeesDao?.updateEmployee(employee) ?? 0;
  }

  /// Soft deletes an employee record.
  Future<int> deleteSoftEmployee(int id) async {
    await database;
    return await _employeesDao?.deleteSoftEmployee(id) ?? 0;
  }

  /// Permanently deletes an employee record.
  Future<int> deletePermanentEmployee(int id) async {
    await database;
    return await _employeesDao?.deletePermanentEmployee(id) ?? 0;
  }

  /// Retrieves all non-deleted employees.
  Future<List<Employee>> getEmployees() async {
    await database;
    return await _employeesDao?.getEmployees() ?? [];
  }

  /// Retrieves a paginated list of employees.
  Future<List<Employee>> getEmployeesPaged({
    int pageNumber = 1,
    int limit = 20,
  }) async {
    await database;
    return await _employeesDao?.getEmployeesPaged(
          pageNumber: pageNumber,
          limit: limit,
        ) ??
        [];
  }

  // ------------------ Attendance DAO Wrappers ------------------
  /// Retrieves all attendance records.
  Future<List<Attendance>?> getAttendance() async {
    await database;
    return await _employeesDao?.getAttendance();
  }

  /// Adds a new attendance record.
  Future<int> addAttendance(Attendance attendance) async {
    await database;
    return await _employeesDao?.addAttendance(attendance) ?? 0;
  }

  /// Updates an attendance record.
  Future<int> updateAttendance(Attendance attendance) async {
    await database;
    return await _employeesDao?.updateAttendance(attendance) ?? 0;
  }

  /// Soft deletes an attendance record.
  Future<int> deleteAttendance(int id) async {
    await database;
    return await _employeesDao?.deleteAttendance(id) ?? 0;
  }

  /// Permanently deletes an attendance record.
  Future<int> deletePermanentlyAttendance(int id) async {
    await database;
    return await _employeesDao?.deletePermanentlyAttendance(id) ?? 0;
  }

  // ------------------ Leaves DAO Wrappers ------------------
  /// Retrieves all leave records.
  Future<List<Leave>> getLeaves() async {
    await database;
    return await _employeesDao?.getLeaves() ?? [];
  }

  /// Adds a new leave record.
  Future<int> addLeave(Leave leave) async {
    await database;
    return await _employeesDao?.addLeave(leave) ?? 0;
  }

  /// Updates a leave record.
  Future<int> updateLeave(Leave leave) async {
    await database;
    return await _employeesDao?.updateLeave(leave) ?? 0;
  }

  /// Updates leave records in batch.
  Future<void> updateLeavesBatch(List<Leave> leaves) async {
    await database;
    await _employeesDao?.updateLeavesBatch(leaves);
  }

  /// Soft deletes a leave record.
  Future<int> deleteLeave(int id) async {
    await database;
    return await _employeesDao?.deleteLeave(id) ?? 0;
  }

  /// Permanently deletes a leave record.
  Future<int> deleteLeavePermanent(int id) async {
    await database;
    return await _employeesDao?.deleteLeavePermanent(id) ?? 0;
  }

  // ------------------ Invoices DAO Wrappers ------------------
  /// Inserts a new invoice record.
  Future<int> insertInvoice(InvoiceModel invoice) async {
    await database;
    return await _invoicesDao?.insertInvoice(invoice) ?? 0;
  }

  /// Retrieves a single invoice by ID.
  Future<InvoiceModel?> getInvoiceById(int id) async {
    await database;
    return await _invoicesDao?.getInvoiceById(id);
  }

  /// Retrieves all invoices.
  Future<List<InvoiceModel>> getAllInvoices() async {
    await database;
    return await _invoicesDao?.getAllInvoices() ?? [];
  }

  /// Updates an existing invoice.
  Future<int> updateInvoice(InvoiceModel invoice) async {
    await database;
    return await _invoicesDao?.updateInvoice(invoice) ?? 0;
  }

  /// Deletes an invoice.
  Future<int> deleteInvoice(int id) async {
    await database;
    return await _invoicesDao?.deleteInvoice(id) ?? 0;
  }

  // ------------------ Invoice Items DAO Wrappers ------------------
  /// Inserts a single invoice item.
  Future<int> insertInvoiceItem(InvoiceItemModel item) async {
    await database;
    return await _invoicesDao?.insertInvoiceItem(item) ?? 0;
  }

  /// Inserts multiple invoice items.
  Future<void> insertInvoiceItems(List<InvoiceItemModel> items) async {
    await database;
    await _invoicesDao?.insertInvoiceItems(items);
  }

  /// Retrieves items for a specific invoice.
  Future<List<InvoiceItemModel>> getInvoiceItems(int invoiceId) async {
    await database;
    return await _invoicesDao?.getInvoiceItems(invoiceId) ?? [];
  }

  /// Deletes invoice items for a given invoice.
  Future<int> deleteInvoiceItems(int invoiceId) async {
    await database;
    return await _invoicesDao?.deleteInvoiceItems(invoiceId) ?? 0;
  }

  // ------------------ Payment Transactions DAO Wrappers ------------------
  /// Inserts a payment transaction.
  Future<int> insertPaymentTransaction(PaymentTransactionModel payment) async {
    await database;
    return await _invoicesDao?.insertPaymentTransaction(payment) ?? 0;
  }

  /// Inserts multiple payment transactions.
  Future<void> insertPaymentTransactions(
    List<PaymentTransactionModel> payments,
  ) async {
    await database;
    await _invoicesDao?.insertPaymentTransactions(payments);
  }

  /// Retrieves payment transactions for an invoice.
  Future<List<PaymentTransactionModel>> getInvoicePayments(
    int invoiceId,
  ) async {
    await database;
    return await _invoicesDao?.getInvoicePayments(invoiceId) ?? [];
  }

  /// Deletes payment transactions for an invoice.
  Future<int> deleteInvoicePayments(int invoiceId) async {
    await database;
    return await _invoicesDao?.deleteInvoicePayments(invoiceId) ?? 0;
  }

  // ------------------ Invoice Transaction DAO Wrappers ------------------
  /// Creates an invoice together with its items and payments.
  Future<int> createInvoice({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required List<PaymentTransactionModel> payments,
  }) async {
    await database;
    return await _invoicesDao?.createInvoice(
          invoice: invoice,
          items: items,
          payments: payments,
        ) ??
        0;
  }

  /// Retrieves full invoice details including items and payments.
  Future<Map<String, dynamic>?> getInvoiceFullDetails(int invoiceId) async {
    await database;
    return await _invoicesDao?.getInvoiceFullDetails(invoiceId);
  }

  /// Retrieves filtered invoices with optional search and sort.
  Future<List<InvoiceModel>> getFilteredInvoices({
    int limit = 20,
    int pageNo = 1,
    String? paymentMethodDetails,
    String? sortField,
    bool ascending = true,
    String? search,
  }) async {
    await database;
    return await _invoicesDao?.getFilteredInvoices(
          limit: limit,
          pageNo: pageNo,
          paymentMethodDetails: paymentMethodDetails,
          sortField: sortField,
          ascending: ascending,
          search: search,
        ) ??
        [];
  }

  // ------------------ Reports DAO Wrappers ------------------
  /// Retrieves today's sales summary.
  Future<DailySalesSummaryModel> getTodaySalesSummary() async {
    await database;
    return await _reportsDao?.getTodaySalesSummary() ??
        DailySalesSummaryModel(
          totalInvoices: 0,
          totalSales: 0.0,
          totalTax: 0.0,
          totalDiscount: 0.0,
          totalPaid: 0.0,
        );
  }

  /// Retrieves sales summary between two dates.
  Future<DailySalesSummaryModel> getSalesSummary(
    String startDate,
    String endDate,
  ) async {
    await database;
    return await _reportsDao?.getSalesSummary(startDate, endDate) ??
        DailySalesSummaryModel(
          totalInvoices: 0,
          totalSales: 0.0,
          totalTax: 0.0,
          totalDiscount: 0.0,
          totalPaid: 0.0,
        );
  }

  /// Retrieves sales graph data for the date range.
  Future<List<SalesGraphModel>> getSalesGraph(
    String startDate,
    String endDate,
  ) async {
    await database;
    return await _reportsDao?.getSalesGraph(startDate, endDate) ?? [];
  }

  /// Retrieves payment mode totals between two dates.
  Future<List<PaymentModeReportModel>> getPaymentModeTotals(
    String startDate,
    String endDate,
  ) async {
    await database;
    return await _reportsDao?.getPaymentModeTotals(startDate, endDate) ?? [];
  }

  /// Retrieves top-selling items between two dates.
  Future<List<TopSellingItemModel>> getTopSellingItems(
    String startDate,
    String endDate,
  ) async {
    await database;
    return await _reportsDao?.getTopSellingItems(startDate, endDate) ?? [];
  }

  /// Retrieves sales forecast data for a range.
  Future<List<SalesForecastModel>> getSalesForecast({
    required String startDate,
    required String endDate,
    int forecastDays = 7,
  }) async {
    await database;
    return await _reportsDao?.getSalesForecast(
          startDate: startDate,
          endDate: endDate,
          forecastDays: forecastDays,
        ) ??
        [];
  }

  /// Loads the overall sales dashboard data.
  Future<SalesDashboardModel> loadSalesDashboard() async {
    await database;
    return await _reportsDao?.loadSalesDashboard() ??
        SalesDashboardModel(
          todaySummary: DailySalesSummaryModel(
            totalInvoices: 0,
            totalSales: 0.0,
            totalTax: 0.0,
            totalDiscount: 0.0,
            totalPaid: 0.0,
          ),
          weeklyTrend: [],
          monthlyTrend: [],
          forecast: [],
          topItems: [],
          paymentModes: [],
        );
  }

  // ------------------ Reservation DAO Wrappers ------------------
  Future<int> createReservation(ReservationModel reservation) async {
    await database;
    return await _reservationsDao?.createReservation(reservation) ?? 0;
  }

  Future<int> createMultipleReservations(
    List<ReservationModel> reservations,
  ) async {
    await database;
    return await _reservationsDao?.createMultipleReservations(reservations) ??
        0;
  }

  Future<ReservationModel?> getReservation(int id) async {
    await database;
    return await _reservationsDao?.getReservation(id);
  }

  Future<List<ReservationModel>> getReservations({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    await database;
    return await _reservationsDao?.getReservations(
          pageNumber: pageNumber,
          limit: limit,
          search: search,
        ) ??
        [];
  }

  Future<int> updateReservation(ReservationModel reservation) async {
    await database;
    return await _reservationsDao?.updateReservation(reservation) ?? 0;
  }

  Future<int> updateMultipleReservations(
    List<ReservationModel> reservations,
  ) async {
    await database;
    return await _reservationsDao?.updateMultipleReservations(reservations) ??
        0;
  }

  Future<int> updateReservationStatus(
    int id,
    int status,
    String modificationDate,
  ) async {
    await database;
    return await _reservationsDao?.updateReservationStatus(
          id,
          status,
          modificationDate,
        ) ??
        0;
  }

  Future<int> deleteReservation(int id) async {
    await database;
    return await _reservationsDao?.deleteReservation(id) ?? 0;
  }

  Future<int> deleteMultipleReservations(List<int> ids) async {
    await database;
    return await _reservationsDao?.deleteMultipleReservations(ids) ?? 0;
  }

  Future<List<ReservationModel>> getReservationsByDate(String date) async {
    await database;
    return await _reservationsDao?.getReservationsByDate(date) ?? [];
  }

  Future<List<ReservationModel>> getReservationsByDateRange(
    String startDate,
    String endDate,
  ) async {
    await database;
    return await _reservationsDao?.getReservationsByDateRange(
          startDate,
          endDate,
        ) ??
        [];
  }

  Future<List<ReservationModel>> getReservationsByStatus(int status) async {
    await database;
    return await _reservationsDao?.getReservationsByStatus(status) ?? [];
  }

  Future<List<ReservationModel>> getAllReservations() async {
    await database;
    return await _reservationsDao?.getAllReservations() ?? [];
  }
}
