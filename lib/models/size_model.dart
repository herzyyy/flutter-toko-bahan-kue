class Size {
  final int branchInventoryId;
  final String name;
  final int sellPrice;
  final int stock;

  Size({
    required this.branchInventoryId,
    required this.name,
    required this.sellPrice,
    required this.stock,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      branchInventoryId: json['branch_inventory_id'] ?? 0,
      name: json['size']?.toString() ?? '',
      sellPrice: json['sell_price'] ?? 0,
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_inventory_id': branchInventoryId,
      'size': name,
      'sell_price': sellPrice,
      'stock': stock,
    };
  }
}
