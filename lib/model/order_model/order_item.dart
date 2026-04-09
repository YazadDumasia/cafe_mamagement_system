import '../menu_item.dart';

enum OrderItemStatus {
  newOrder, // 0
  inPreparation, // 1
  delivered, // 2
  canceled, // 3
  deleted, // 4
}

class OrderItem {
  OrderItem({
    this.id,
    this.orderId,
    this.itemId,
    this.quantity,
    this.costPrice,
    this.sellingPrice,
    this.status,
    this.isMenuItem,
    this.menuItem,
    this.selectedVariation,
    this.remarks,
    this.creationDate,
  }); // Reference to the selected variation

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // final int? statusIndex = json['status'] == null
    //     ? 0
    //     : json['status'] as int?;
    // final OrderItemStatus? status = statusIndex != null
    //     ? OrderItemStatus.values[statusIndex]
    //     : null;

    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      itemId: json['itemId'],
      quantity: json['quantity'],
      costPrice: json['costPrice'],
      sellingPrice: json['sellingPrice'],
      status: json['status'],

      // status: status,
      isMenuItem: json['isMenuItem'],
      menuItem: json['menuItem'] != null
          ? MenuItem.fromJson(json['menuItem'])
          : null,
      selectedVariation: json['selectedVariation'] != null
          ? MenuItemVariation.fromJson(json['selectedVariation'])
          : null,
      remarks: json['remarks'],
      creationDate: json['creationDate'],
    );
  }

  /// Unique ID for the order item
  int? id;

  /// ID of the associated order
  int? orderId;
  int? itemId; // ID of the menu item
  int? quantity; // Quantity of the menu item in the order
  String? status; //Status "New" ,"In Preparation", "Delivered"
  // OrderItemStatus? status; //Status "New" ,"In Preparation", "Delivered"

  double? costPrice = 0;
  double? sellingPrice = 0;
  bool?
  isMenuItem; // Flag to determine if the order item is a menu item or a variation
  MenuItem? menuItem; // Reference to the menu item
  MenuItemVariation? selectedVariation;
  String? remarks;
  String? creationDate;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'status': status,
      // 'status': status?.index,
      'isMenuItem': isMenuItem,
      'menuItem': menuItem?.toJson(),
      'selectedVariation': selectedVariation?.toJson(),
      'remarks': remarks,
      'creationDate': creationDate,
    }..removeWhere((key, value) => value == null);
  }
}
