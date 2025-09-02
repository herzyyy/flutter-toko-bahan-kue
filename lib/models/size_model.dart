class Size {
  final int id;
  final String name;
  final int sellPrice;
  final int stock;

  Size({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.stock,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id: json['size_id'],
      name: json['size'],
      sellPrice: json['sell_price'],
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'sell_price': sellPrice, 'stock': stock};
  }
}
