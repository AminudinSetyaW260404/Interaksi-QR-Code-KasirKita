/// Model produk yang dijual di toko.
class Product {
  const Product({
    required this.code,
    required this.name,
    required this.price,
  });

  /// Kode produk, sekaligus nilai yang di-encode ke dalam QR Code.
  final String code;

  /// Nama produk.
  final String name;

  /// Harga satuan produk dalam Rupiah.
  final double price;
}

/// Item keranjang belanja.
///
/// Menangani Tugas 1 (Kuantitas): satu produk yang sama dipindai berulang
/// kali akan menambah [quantity] pada item yang sudah ada, bukan membuat
/// item baru.
class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;

  /// Jumlah produk pada keranjang.
  int quantity;

  /// Harga total untuk item ini (harga satuan x kuantitas).
  double get subtotal => product.price * quantity;

  /// Menambah kuantitas item sebanyak satu.
  void increaseQuantity() => quantity++;
}

/// Data dummy produk toko.
const List<Product> storeProducts = <Product>[
  Product(code: 'BRG-001', name: 'Roti Coklat', price: 12000),
  Product(code: 'BRG-002', name: 'Air Mineral', price: 5000),
  Product(code: 'BRG-003', name: 'Kopi Susu', price: 15000),
  Product(code: 'BRG-004', name: 'Teh Manis', price: 8000),
];

/// Mencari produk berdasarkan kode yang didapat dari hasil pemindaian QR.
Product? findProductByCode(String code) {
  for (final Product product in storeProducts) {
    if (product.code == code) {
      return product;
    }
  }
  return null;
}
