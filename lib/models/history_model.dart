class SaleHistory {
  final String code;
  final String customerName;
  final String status;
  final DateTime createdAt;
  final int branchId;

  SaleHistory({
    required this.code,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.branchId,
  });

  factory SaleHistory.fromJson(Map<String, dynamic> json) {
    return SaleHistory(
      code: json['code'] ?? '',
      customerName: json['customer_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      branchId: json['branch_id'] ?? 0,
    );
  }
}

class PurchaseHistory {
  final String code;
  final String salesName;
  final String distributorName;
  final String status;
  final DateTime createdAt;
  final int branchId;

  PurchaseHistory({
    required this.code,
    required this.salesName,
    required this.distributorName,
    required this.status,
    required this.createdAt,
    required this.branchId,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      code: json['code'] ?? '',
      salesName: json['sales_name'] ?? '',
      distributorName: json['distributor_name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      branchId: json['branch_id'] ?? 0,
    );
  }
}
