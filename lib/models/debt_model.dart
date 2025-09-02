class Debt {
  final int id;
  final String referenceCode;
  final int totalAmount;
  final DateTime dueDate;
  final String status;
  final String related;
  final String branchName;

  Debt({
    required this.id,
    required this.referenceCode,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
    required this.related,
    required this.branchName,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      referenceCode: json['reference_code'],
      totalAmount: json['total_amount'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date']),
      status: json['status'],
      related: json['related'],
      branchName: json['branch_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "reference_code": referenceCode,
      "total_amount": totalAmount,
      "due_date": dueDate.millisecondsSinceEpoch,
      "status": status,
      "related": related,
      "branch_name": branchName,
    };
  }
}
