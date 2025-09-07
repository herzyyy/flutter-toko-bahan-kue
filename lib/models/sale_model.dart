class Sale {
  final String code;
  final String customerName;
  final String status;
  final DateTime createdAt;
  final int branchId;

  Sale({
    required this.code,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.branchId,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      code: json['code'] ?? '',
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      branchId: json['branch_id'] ?? 0,
    );
  }
}

class Purchase {
  final String code;
  final String salesName;
  final String distributorName;
  final String status;
  final DateTime createdAt;
  final int branchId;

  Purchase({
    required this.code,
    required this.salesName,
    required this.distributorName,
    required this.status,
    required this.createdAt,
    required this.branchId,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      code: json['code'] ?? '',
      salesName: json['sales_name'] ?? '',
      distributorName: json['distributor_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      branchId: json['branch_id'] ?? 0,
    );
  }
}
