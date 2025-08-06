class Size {
  final int id;
  final String name;
  final int sellPrice;
  final int buyPrice;
  final int createdAt;
  final int updatedAt;

  Size({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.buyPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id: json['id'],
      name: json['name'],
      sellPrice: json['sell_price'],
      buyPrice: json['buy_price'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sell_price': sellPrice,
      'buy_price': buyPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
