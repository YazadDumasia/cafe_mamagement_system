# Missing DAO Method Wrappers in database_helper.dart

## Summary
- **Total DAO Files:** 9
- **Total DAO Methods Wrapped:** 68
- **Total DAO Methods Missing:** 23
- **DAO Files with Missing Methods:** 2 (InvoicesDAO and ReportsDAO)

---

## FULLY WRAPPED DAO FILES ✓

### 1. RecipesDAO - 12/12 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 2. CategoriesDAO - 13/13 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 3. MenuItemsDAO - 14/14 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 4. CustomersDAO - 13/13 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 5. OrdersDAO - 9/9 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 6. InventoryDAO - 25/25 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

### 7. EmployeesDAO - 17/17 Methods Wrapped ✓
All methods are properly wrapped in database_helper.dart

---

## PARTIALLY WRAPPED DAO FILES ⚠️

---

## MISSING ALL WRAPPERS - InvoicesDAO ❌

### InvoicesDAO - 0/16 Methods Wrapped

#### Missing Method 1: `insertInvoice`
```dart
Future<int> insertInvoice(InvoiceModel invoice) async {
  return await db.insert(DatabaseTables.invoicesTable, invoice.toJson());
}
```

#### Missing Method 2: `getInvoiceById`
```dart
Future<InvoiceModel?> getInvoiceById(int id) async {
  final maps = await db.query(
    DatabaseTables.invoicesTable,
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isEmpty) return null;

  return InvoiceModel.fromJson(maps.first);
}
```

#### Missing Method 3: `getAllInvoices`
```dart
Future<List<InvoiceModel>> getAllInvoices() async {
  final maps = await db.query(
    DatabaseTables.invoicesTable,
    orderBy: 'id DESC',
  );

  return maps.map((e) => InvoiceModel.fromJson(e)).toList();
}
```

#### Missing Method 4: `updateInvoice`
```dart
Future<int> updateInvoice(InvoiceModel invoice) async {
  return await db.update(
    DatabaseTables.invoicesTable,
    invoice.toJson(),
    where: 'id = ?',
    whereArgs: [invoice.id],
  );
}
```

#### Missing Method 5: `deleteInvoice`
```dart
Future<int> deleteInvoice(int id) async {
  return await db.delete(
    DatabaseTables.invoicesTable,
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

#### Missing Method 6: `insertInvoiceItem`
```dart
Future<int> insertInvoiceItem(InvoiceItemModel item) async {
  return await db.insert(DatabaseTables.invoiceItemsTable, item.toJson());
}
```

#### Missing Method 7: `insertInvoiceItems`
```dart
Future<void> insertInvoiceItems(List<InvoiceItemModel> items) async {
  final batch = db.batch();

  for (final item in items) {
    batch.insert(DatabaseTables.invoiceItemsTable, item.toJson());
  }

  await batch.commit(noResult: true);
}
```

#### Missing Method 8: `getInvoiceItems`
```dart
Future<List<InvoiceItemModel>> getInvoiceItems(int invoiceId) async {
  final maps = await db.query(
    DatabaseTables.invoiceItemsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );

  return maps.map((e) => InvoiceItemModel.fromJson(e)).toList();
}
```

#### Missing Method 9: `deleteInvoiceItems`
```dart
Future<int> deleteInvoiceItems(int invoiceId) async {
  return await db.delete(
    DatabaseTables.invoiceItemsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );
}
```

#### Missing Method 10: `insertPaymentTransaction`
```dart
Future<int> insertPaymentTransaction(PaymentTransactionModel payment) async {
  return await db.insert(
    DatabaseTables.paymentTransactionsTable,
    payment.toJson(),
  );
}
```

#### Missing Method 11: `insertPaymentTransactions`
```dart
Future<void> insertPaymentTransactions(
  List<PaymentTransactionModel> payments,
) async {
  final batch = db.batch();

  for (final payment in payments) {
    batch.insert(DatabaseTables.paymentTransactionsTable, payment.toJson());
  }

  await batch.commit(noResult: true);
}
```

#### Missing Method 12: `getInvoicePayments`
```dart
Future<List<PaymentTransactionModel>> getInvoicePayments(
  int invoiceId,
) async {
  final maps = await db.query(
    DatabaseTables.paymentTransactionsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );

  return maps.map((e) => PaymentTransactionModel.fromJson(e)).toList();
}
```

#### Missing Method 13: `deleteInvoicePayments`
```dart
Future<int> deleteInvoicePayments(int invoiceId) async {
  return await db.delete(
    DatabaseTables.paymentTransactionsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );
}
```

#### Missing Method 14: `createInvoice` (Transaction Safe)
```dart
Future<int> createInvoice({
  required InvoiceModel invoice,
  required List<InvoiceItemModel> items,
  required List<PaymentTransactionModel> payments,
}) async {
  return await db.transaction((txn) async {
    /// Insert invoice
    final invoiceId = await txn.insert(
      DatabaseTables.invoicesTable,
      invoice.toJson(),
    );

    /// Insert items
    for (final item in items) {
      final newItem = item.copyWith(invoiceId: invoiceId);

      await txn.insert(DatabaseTables.invoiceItemsTable, newItem.toJson());
    }

    /// Insert payments
    for (final payment in payments) {
      final newPayment = payment.copyWith(invoiceId: invoiceId);

      await txn.insert(
        DatabaseTables.paymentTransactionsTable,
        newPayment.toJson(),
      );
    }

    return invoiceId;
  });
}
```

#### Missing Method 15: `getInvoiceFullDetails`
```dart
Future<Map<String, dynamic>?> getInvoiceFullDetails(int invoiceId) async {
  final invoiceResult = await db.query(
    DatabaseTables.invoicesTable,
    where: 'id = ?',
    whereArgs: [invoiceId],
  );

  if (invoiceResult.isEmpty) return null;

  final items = await db.query(
    DatabaseTables.invoiceItemsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );

  final payments = await db.query(
    DatabaseTables.paymentTransactionsTable,
    where: 'invoiceId = ?',
    whereArgs: [invoiceId],
  );
  return {
    "invoice": InvoiceModel.fromJson(invoiceResult.first),
    "items": items.map((e) => InvoiceItemModel.fromJson(e)).toList(),
    "payments": payments
        .map((e) => PaymentTransactionModel.fromJson(e))
        .toList(),
  };
}
```

#### Missing Method 16: `getFilteredInvoices`
```dart
Future<List<InvoiceModel>> getFilteredInvoices({
  int limit = 20,
  int pageNo = 1,
  String? paymentMethodDetails,
  String? sortField,
  bool ascending = true,
  String? search,
}) async {
  return await db.transaction<List<InvoiceModel>>((txn) async {
    final int offset = (pageNo - 1) * limit;

    final List<String> whereParts = [];
    final List<Object?> whereArgs = [];

    /// Filter by payment method
    if (paymentMethodDetails != null && paymentMethodDetails.isNotEmpty) {
      whereParts.add('paymentMethodDetails = ?');
      whereArgs.add(paymentMethodDetails);
    }

    /// Search filter
    if (search != null && search.trim().isNotEmpty) {
      final searchTerm = '%${search.trim()}%';

      whereParts.add(
        '(invoiceHashId LIKE ? OR netPaymentAmount LIKE ? OR customerName LIKE ? OR phoneNumber LIKE ?)',
      );

      whereArgs.addAll([searchTerm, searchTerm, searchTerm, searchTerm]);
    }

    final whereClause = whereParts.isEmpty ? null : whereParts.join(' AND ');

    /// Safe sorting fields
    const allowedSortFields = [
      'netPaymentAmount',
      'createdDate',
      'customerName',
      'recordAmountPaid',
    ];

    String orderBy = 'createdDate DESC';

    if (sortField != null && allowedSortFields.contains(sortField)) {
      orderBy = '$sortField ${ascending ? 'ASC' : 'DESC'}';
    }

    final result = await txn.query(
      DatabaseTables.invoicesTable,
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );

    return result.map((e) => InvoiceModel.fromJson(e)).toList();
  });
}
```

---

## MISSING ALL WRAPPERS - ReportsDAO ❌

### ReportsDAO - 0/7 Methods Wrapped

#### Missing Method 1: `getTodaySalesSummary`
```dart
Future<DailySalesSummaryModel> getTodaySalesSummary() async {
  final result = await db.rawQuery('''
  SELECT
    COUNT(id) as totalInvoices,
    SUM(totalCost) as totalSales,
    SUM(taxCost) as totalTax,
    SUM(discountAmount) as totalDiscount,
    SUM(recordAmountPaid) as totalPaid
  FROM invoices
  WHERE DATE(createdDate) = DATE('now','localtime')
''');

  return DailySalesSummaryModel.fromJson(result.first);
}
```

#### Missing Method 2: `getSalesSummary`
```dart
Future<DailySalesSummaryModel> getSalesSummary(
  String startDate,
  String endDate,
) async {
  final result = await db.rawQuery(
    '''
  SELECT
    COUNT(id) as totalInvoices,
    SUM(totalCost) as totalSales,
    SUM(taxCost) as totalTax,
    SUM(discountAmount) as totalDiscount,
    SUM(recordAmountPaid) as totalPaid
  FROM invoices
  WHERE createdDate BETWEEN ? AND ?
''',
    [startDate, endDate],
  );

  return DailySalesSummaryModel.fromJson(result.first);
}
```

#### Missing Method 3: `getSalesGraph`
```dart
Future<List<SalesGraphModel>> getSalesGraph(
  String startDate,
  String endDate,
) async {
  final result = await db.rawQuery(
    '''
  SELECT
    DATE(createdDate) as saleDate,
    SUM(netPaymentAmount) as totalSales,
    COUNT(id) as invoiceCount
  FROM invoices
  WHERE createdDate BETWEEN ? AND ?
  GROUP BY DATE(createdDate)
  ORDER BY saleDate
''',
    [startDate, endDate],
  );

  return result.map((e) => SalesGraphModel.fromJson(e)).toList();
}
```

#### Missing Method 4: `getPaymentModeTotals`
```dart
Future<List<PaymentModeReportModel>> getPaymentModeTotals(
  String startDate,
  String endDate,
) async {
  final result = await db.rawQuery(
    '''
  SELECT
    paymentMethodName,
    SUM(amount) as totalAmount,
    COUNT(id) as totalTransactions
  FROM payment_transactions
  WHERE createdDate BETWEEN ? AND ?
  GROUP BY paymentMethodName
''',
    [startDate, endDate],
  );

  return result.map((e) => PaymentModeReportModel.fromJson(e)).toList();
}
```

#### Missing Method 5: `getTopSellingItems`
```dart
Future<List<TopSellingItemModel>> getTopSellingItems(
  String startDate,
  String endDate,
) async {
  final result = await db.rawQuery(
    '''
  SELECT
    itemName,
    SUM(quantity) as totalQuantity,
    SUM(totalPrice) as totalRevenue
  FROM invoice_items
  WHERE createdDate BETWEEN ? AND ?
  GROUP BY itemId
  ORDER BY totalQuantity DESC
  LIMIT 10
''',
    [startDate, endDate],
  );

  return result.map((e) => TopSellingItemModel.fromJson(e)).toList();
}
```

#### Missing Method 6: `getSalesForecast`
```dart
Future<List<SalesForecastModel>> getSalesForecast({
  required String startDate,
  required String endDate,
  int forecastDays = 7,
}) async {
  final history = await _getDailySalesHistory(startDate, endDate);

  List<SalesForecastModel> result = [];

  List<double> salesValues = [];

  for (final row in history) {
    double sales = (row['totalSales'] as num?)?.toDouble() ?? 0;

    salesValues.add(sales);

    result.add(SalesForecastModel(date: row['date'], actualSales: sales));
  }

  /// Moving average forecast
  double avg = 0;
  if (salesValues.isNotEmpty) {
    avg = salesValues.reduce((a, b) => a + b) / salesValues.length;
  }

  DateTime lastDate = DateTime.parse(
    history.last['date'] ?? DateTime.now().toString(),
  );

  for (int i = 1; i <= forecastDays; i++) {
    DateTime nextDate = lastDate.add(Duration(days: i));

    result.add(
      SalesForecastModel(
        date: nextDate.toIso8601String().split('T').first,
        predictedSales: avg,
      ),
    );
  }

  return result;
}
```

#### Missing Method 7: `loadSalesDashboard`
```dart
Future<SalesDashboardModel> loadSalesDashboard() async {
  final today = await getTodaySalesSummary();

  final weekly = await getSalesGraph(
    DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
    DateTime.now().toIso8601String(),
  );

  final monthly = await getSalesGraph(
    DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
    DateTime.now().toIso8601String(),
  );

  final forecast = await getSalesForecast(
    startDate: DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
    endDate: DateTime.now().toIso8601String(),
  );

  final topItems = await getTopSellingItems(
    DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
    DateTime.now().toIso8601String(),
  );

  final payments = await getPaymentModeTotals(
    DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
    DateTime.now().toIso8601String(),
  );

  return SalesDashboardModel(
    todaySummary: today,
    weeklyTrend: weekly,
    monthlyTrend: monthly,
    forecast: forecast,
    topItems: topItems,
    paymentModes: payments,
  );
}
```

---

## Summary Table

| DAO File | Total Methods | Wrapped | Missing | Status |
|----------|---------------|---------|---------|--------|
| RecipesDAO | 12 | 12 | 0 | ✓ Complete |
| CategoriesDAO | 13 | 13 | 0 | ✓ Complete |
| MenuItemsDAO | 14 | 14 | 0 | ✓ Complete |
| CustomersDAO | 13 | 13 | 0 | ✓ Complete |
| OrdersDAO | 9 | 9 | 0 | ✓ Complete |
| InventoryDAO | 25 | 25 | 0 | ✓ Complete |
| EmployeesDAO | 17 | 17 | 0 | ✓ Complete |
| InvoicesDAO | 16 | 0 | **16** | ❌ Missing |
| ReportsDAO | 8 | 0 | **7** | ❌ Missing |
| **TOTAL** | **127** | **103** | **23** | |

---

## Next Steps

1. **Add InvoicesDAO wrapper** - Reference: [invoices_dao.dart](lib/database/database_dao/invoices_dao.dart)
   - First, ensure `_invoicesDao` reference is created in `database` getter
   - Add all 16 wrapper methods to database_helper.dart

2. **Add ReportsDAO wrapper** - Reference: [reports_dao.dart](lib/database/database_dao/reports_dao.dart)
   - First, ensure `_reportsDao` reference is created in `database` getter
   - Add all 7 wrapper methods to database_helper.dart

3. **Add necessary imports**:
   - `import 'database_dao/reports_dao.dart';`
   - Ensure all model imports are present for invoices and reports

