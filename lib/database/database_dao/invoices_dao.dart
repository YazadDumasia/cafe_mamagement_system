import '../../model/invoices/invoice_model.dart';
import 'package:sqflite/sqflite.dart';
import '../database_tables.dart';
import '../../model/invoices/invoice_item_model.dart';
import '../../model/invoices/payment_transaction_model.dart';

class InvoicesDao {
  final Database db;

  InvoicesDao(this.db);

  /// ------------------------------
  /// INSERT INVOICE
  /// ------------------------------
  Future<int> insertInvoice(InvoiceModel invoice) async {
    return await db.insert(DatabaseTables.invoicesTable, invoice.toJson());
  }

  /// ------------------------------
  /// GET INVOICE BY ID
  /// ------------------------------
  Future<InvoiceModel?> getInvoiceById(int id) async {
    final maps = await db.query(
      DatabaseTables.invoicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return InvoiceModel.fromJson(maps.first);
  }

  /// ------------------------------
  /// GET ALL INVOICES
  /// ------------------------------
  Future<List<InvoiceModel>> getAllInvoices() async {
    final maps = await db.query(
      DatabaseTables.invoicesTable,
      orderBy: 'id DESC',
    );

    return maps.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  /// ------------------------------
  /// UPDATE INVOICE
  /// ------------------------------
  Future<int> updateInvoice(InvoiceModel invoice) async {
    return await db.update(
      DatabaseTables.invoicesTable,
      invoice.toJson(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  /// ------------------------------
  /// DELETE INVOICE
  /// ------------------------------
  Future<int> deleteInvoice(int id) async {
    return await db.delete(
      DatabaseTables.invoicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ======================================================
  /// INVOICE ITEMS
  /// ======================================================

  /// INSERT SINGLE ITEM
  Future<int> insertInvoiceItem(InvoiceItemModel item) async {
    return await db.insert(DatabaseTables.invoiceItemsTable, item.toJson());
  }

  /// INSERT MULTIPLE ITEMS
  Future<void> insertInvoiceItems(List<InvoiceItemModel> items) async {
    final batch = db.batch();

    for (final item in items) {
      batch.insert(DatabaseTables.invoiceItemsTable, item.toJson());
    }

    await batch.commit(noResult: true);
  }

  /// GET ITEMS OF INVOICE
  Future<List<InvoiceItemModel>> getInvoiceItems(int invoiceId) async {
    final maps = await db.query(
      DatabaseTables.invoiceItemsTable,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );

    return maps.map((e) => InvoiceItemModel.fromJson(e)).toList();
  }

  /// DELETE ITEMS
  Future<int> deleteInvoiceItems(int invoiceId) async {
    return await db.delete(
      DatabaseTables.invoiceItemsTable,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
  }

  /// ======================================================
  /// PAYMENT TRANSACTIONS
  /// ======================================================

  /// INSERT PAYMENT
  Future<int> insertPaymentTransaction(PaymentTransactionModel payment) async {
    return await db.insert(
      DatabaseTables.paymentTransactionsTable,
      payment.toJson(),
    );
  }

  /// INSERT MULTIPLE PAYMENTS
  Future<void> insertPaymentTransactions(
    List<PaymentTransactionModel> payments,
  ) async {
    final batch = db.batch();

    for (final payment in payments) {
      batch.insert(DatabaseTables.paymentTransactionsTable, payment.toJson());
    }

    await batch.commit(noResult: true);
  }

  /// GET PAYMENTS OF INVOICE
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

  /// DELETE PAYMENTS
  Future<int> deleteInvoicePayments(int invoiceId) async {
    return await db.delete(
      DatabaseTables.paymentTransactionsTable,
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
  }

  /// ======================================================
  /// CREATE FULL INVOICE (TRANSACTION SAFE)
  /// ======================================================

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

  /// ======================================================
  /// GET FULL INVOICE DETAILS
  /// ======================================================

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
}
