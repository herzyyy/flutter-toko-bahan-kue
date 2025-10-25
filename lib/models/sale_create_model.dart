// models/transaksi_model.dart
class TransactionDetail {
  final int branchInventoryId;
  final int qty;

  TransactionDetail({required this.branchInventoryId, required this.qty});
}

class PaymentMethod {
  final String method;
  final double amount;
  final String note;

  PaymentMethod({
    required this.method,
    required this.amount,
    required this.note,
  });
}

class DebtPayment {
  final double amount;

  DebtPayment({required this.amount});
}

class Transaction {
  final String customerName;
  final List<TransactionDetail> details;
  final List<PaymentMethod>? payments;
  final DebtInfo? debt;

  Transaction({
    required this.customerName,
    required this.details,
    this.payments,
    this.debt,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'details': details
          .map(
            (d) => {'branch_inventory_id': d.branchInventoryId, 'qty': d.qty},
          )
          .toList(),
      if (payments != null)
        'payments': payments!
            .map(
              (p) => {
                'payment_method': p.method,
                'amount': p.amount,
                'note': p.note,
              },
            )
            .toList(),
      if (debt != null)
        'debt': {
          'due_date': debt!.dueDate,
          'debt_payments': debt!.payments
              .map((dp) => {'amount': dp.amount})
              .toList(),
        },
    };
  }
}

class DebtInfo {
  final String dueDate;
  final List<DebtPayment> payments;

  DebtInfo({required this.dueDate, required this.payments});
}
