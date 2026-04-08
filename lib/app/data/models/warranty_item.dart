class WarrantyItem {
  WarrantyItem({
    this.id,
    required this.productName,
    required this.brand,
    required this.shopName,
    required this.serialNumber,
    required this.purchaseDate,
    required this.expiryDate,
    required this.price,
    required this.notes,
    required this.hasReceipt,
    this.productImagePath,
    this.invoiceImagePath,
  });

  final int? id;
  final String productName;
  final String brand;
  final String shopName;
  final String serialNumber;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double price;
  final String notes;
  final bool hasReceipt;
  final String? productImagePath;
  final String? invoiceImagePath;

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'product_name': productName,
      'brand': brand,
      'shop_name': shopName,
      'serial_number': serialNumber,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'price': price,
      'notes': notes,
      'has_receipt': hasReceipt ? 1 : 0,
      'product_image_path': productImagePath,
      'invoice_image_path': invoiceImagePath,
    };
  }

  factory WarrantyItem.fromMap(Map<String, Object?> map) {
    return WarrantyItem(
      id: map['id'] as int?,
      productName: map['product_name'] as String,
      brand: map['brand'] as String,
      shopName: (map['shop_name'] as String?) ?? '',
      serialNumber: map['serial_number'] as String,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      expiryDate: DateTime.parse(map['expiry_date'] as String),
      price: (map['price'] as num).toDouble(),
      notes: map['notes'] as String,
      hasReceipt: (map['has_receipt'] as int) == 1,
      productImagePath: map['product_image_path'] as String?,
      invoiceImagePath: map['invoice_image_path'] as String?,
    );
  }
}
