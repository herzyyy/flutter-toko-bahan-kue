class DebtDetail {
  final int id;
  final String referenceType;
  final String referenceCode;
  final int totalAmount;
  final int paidAmount;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final List<DebtPayment> payments;
  final List<Item> items;

  DebtDetail({
    required this.id,
    required this.referenceType,
    required this.referenceCode,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.payments,
    required this.items,
  });

  factory DebtDetail.fromJson(Map<String, dynamic> json) {
    return DebtDetail(
      id: json['id'],
      referenceType: json['reference_type'],
      referenceCode: json['reference_code'],
      totalAmount: json['total_amount'],
      paidAmount: json['paid_amount'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date']),
      status: json['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      payments: (json['payments'] as List)
          .map((p) => DebtPayment.fromJson(p))
          .toList(),
      items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "reference_type": referenceType,
      "reference_code": referenceCode,
      "total_amount": totalAmount,
      "paid_amount": paidAmount,
      "due_date": dueDate.millisecondsSinceEpoch,
      "status": status,
      "created_at": createdAt.millisecondsSinceEpoch,
      "payments": payments.map((p) => p.toJson()).toList(),
      "items": items.map((i) => i.toJson()).toList(),
    };
  }
}

class DebtPayment {
  final int id;
  final int amount;
  final DateTime paymentDate;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
  });

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'],
      amount: json['amount'],
      paymentDate: DateTime.fromMillisecondsSinceEpoch(json['payment_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "amount": amount,
      "payment_date": paymentDate.millisecondsSinceEpoch,
    };
  }
}

class Item {
  final String productName;
  final String sizeName;
  final int qty;
  final int sellPrice;

  Item({
    required this.productName,
    required this.sizeName,
    required this.qty,
    required this.sellPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      productName: json['product_name'],
      sizeName: json['size_name'],
      qty: json['qty'],
      sellPrice: json['sell_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_name": productName,
      "size_name": sizeName,
      "qty": qty,
      "sell_price": sellPrice,
    };
  }
}
