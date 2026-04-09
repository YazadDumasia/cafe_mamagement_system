import 'payment_mode_report_model.dart';
import 'sales_forecast_model.dart';
import 'sales_graph_model.dart';
import 'sales_summary_model.dart';
import 'top_selling_item_model.dart';

class SalesDashboardModel {
  final DailySalesSummaryModel? todaySummary;
  final List<SalesGraphModel>? weeklyTrend;
  final List<SalesGraphModel>? monthlyTrend;
  final List<SalesForecastModel>? forecast;
  final List<TopSellingItemModel>? topItems;
  final List<PaymentModeReportModel>? paymentModes;

  SalesDashboardModel({
    this.todaySummary,
    this.weeklyTrend,
    this.monthlyTrend,
    this.forecast,
    this.topItems,
    this.paymentModes,
  });

  factory SalesDashboardModel.fromJson(Map<String, dynamic> json) {
    return SalesDashboardModel(
      todaySummary: json['todaySummary'] != null
          ? DailySalesSummaryModel.fromJson(json['todaySummary'])
          : null,
      weeklyTrend: (json['weeklyTrend'] as List?)
          ?.map((e) => SalesGraphModel.fromJson(e))
          .toList(),
      monthlyTrend: (json['monthlyTrend'] as List?)
          ?.map((e) => SalesGraphModel.fromJson(e))
          .toList(),
      forecast: (json['forecast'] as List?)
          ?.map((e) => SalesForecastModel.fromJson(e))
          .toList(),
      topItems: (json['topItems'] as List?)
          ?.map((e) => TopSellingItemModel.fromJson(e))
          .toList(),
      paymentModes: (json['paymentModes'] as List?)
          ?.map((e) => PaymentModeReportModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todaySummary': todaySummary?.toJson(),
      'weeklyTrend': weeklyTrend?.map((e) => e.toJson()).toList(),
      'monthlyTrend': monthlyTrend?.map((e) => e.toJson()).toList(),
      'forecast': forecast?.map((e) => e.toJson()).toList(),
      'topItems': topItems?.map((e) => e.toJson()).toList(),
      'paymentModes': paymentModes?.map((e) => e.toJson()).toList(),
    }..removeWhere((k, v) => v == null);
  }

  SalesDashboardModel copyWith({
    DailySalesSummaryModel? todaySummary,
    List<SalesGraphModel>? weeklyTrend,
    List<SalesGraphModel>? monthlyTrend,
    List<SalesForecastModel>? forecast,
    List<TopSellingItemModel>? topItems,
    List<PaymentModeReportModel>? paymentModes,
  }) {
    return SalesDashboardModel(
      todaySummary: todaySummary ?? this.todaySummary,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      forecast: forecast ?? this.forecast,
      topItems: topItems ?? this.topItems,
      paymentModes: paymentModes ?? this.paymentModes,
    );
  }

  @override
  String toString() {
    return 'SalesDashboardModel(todaySummary: $todaySummary, weeklyTrend: $weeklyTrend, monthlyTrend: $monthlyTrend, forecast: $forecast, topItems: $topItems, paymentModes: $paymentModes)';
  }
}
