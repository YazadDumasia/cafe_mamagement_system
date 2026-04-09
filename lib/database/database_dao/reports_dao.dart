import '../../model/reports/payment_mode_report_model.dart';
import '../../model/reports/sales_dasdboard_model.dart';
import '../../model/reports/sales_forecast_model.dart';
import '../../model/reports/sales_graph_model.dart';

import '../../model/reports/sales_summary_model.dart';

import 'package:sqflite/sqflite.dart';

import '../../model/reports/top_selling_item_model.dart';

class ReportsDao {
  final Database db;

  ReportsDao(this.db);

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

  Future<List<Map<String, dynamic>>> _getDailySalesHistory(
    String startDate,
    String endDate,
  ) async {
    return await db.rawQuery(
      '''
    SELECT
      DATE(createdDate) as date,
      SUM(netPaymentAmount) as totalSales
    FROM invoices
    WHERE createdDate BETWEEN ? AND ?
    GROUP BY DATE(createdDate)
    ORDER BY date ASC
  ''',
      [startDate, endDate],
    );
  }

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
}
