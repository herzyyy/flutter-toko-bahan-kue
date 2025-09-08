// models/sale_model.dart
class SaleDetail {
  final String code;
  final String customerName;
  final String status;
  final DateTime createdAt;
  final String branchName;
  final List<Item> items;
  final List<Payment>? payments; // Bisa null
  final int total_price; // Dari API
  final int total_qty; // Dari API

  SaleDetail({
    required this.code,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.branchName,
    required this.items,
    this.payments,
    required this.total_price, // Ambil langsung dari API
    required this.total_qty, // Ambil langsung dari API
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      code: json['code'],
      customerName: json['customer_name'],
      status: json['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      branchName: json['branch_name'],
      items: (json['items'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList(),
      payments: json.containsKey('payments') && json['payments'] != null
          ? (json['payments'] as List)
                .map((paymentJson) => Payment.fromJson(paymentJson))
                .toList()
          : null,
      total_price: json['total_price'], // Ambil langsung
      total_qty: json['total_qty'], // Ambil langsung
    );
  }
}

class Item {
  final String productName;
  final String sizeName;
  final int quantity;
  final int price;

  Item({
    required this.productName,
    required this.sizeName,
    required this.quantity,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      productName: json['product']['name'],
      sizeName: json['size']['name'],
      quantity: json['qty'],
      price: json['price'],
    );
  }
}

class Payment {
  final String method;
  final int amount;
  final String? note;
  final DateTime createdAt;

  Payment({
    required this.method,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: json['payment_method'],
      amount: json['amount'],
      note: json['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }
}
