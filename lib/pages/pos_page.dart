import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../utils/currency_formatter.dart';
import 'scanner_page.dart';

/// Mesin Kasir (POS).
///
/// - Tugas 1: logika keranjang, kode sama -> kuantitas bertambah.
/// - Tugas 2: tombol "Bayar Sekarang" + dialog konfirmasi + SnackBar.
/// - Tugas 3: item keranjang dibungkus [Dismissible] untuk dihapus.
class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  /// Daftar item di keranjang kasir.
  final List<CartItem> _cart = <CartItem>[];

  /// Total seluruh transaksi.
  double get _total => _cart.fold(
    0,
    (double sum, CartItem item) => sum + item.subtotal,
  );

  bool get _isEmpty => _cart.isEmpty;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Membuka halaman pemindai dan menambahkan hasil pindai ke keranjang.
  Future<void> _openScanner() async {
    final String? code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const ScannerPage()),
    );

    if (!mounted || code == null) {
      return;
    }

    addProductByCode(code);
  }

  /// Tugas 1: jika kode yang sama dipindai lagi, kuantitasnya bertambah.
  void addProductByCode(String code) {
    final Product? product = findProductByCode(code);

    if (product == null) {
      _showMessage('Produk dengan kode "$code" tidak ditemukan');
      return;
    }

    setState(() {
      final int index = _cart.indexWhere(
        (CartItem item) => item.product.code == product.code,
      );

      if (index == -1) {
        _cart.add(CartItem(product: product));
      } else {
        _cart[index].increaseQuantity();
      }
    });

    _showMessage('${product.name} ditambahkan ke keranjang');
  }

  /// Tugas 3: menghapus item setelah animasi swipe selesai.
  void _removeFromCart(CartItem item) {
    setState(() => _cart.remove(item));
    _showMessage('${item.product.name} dihapus dari keranjang');
  }

  /// Kosongkan seluruh keranjang (tombol di AppBar).
  Future<void> _resetCart() async {
    if (_isEmpty) {
      _showMessage('Keranjang sudah kosong');
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang?'),
        content: const Text(
          'Seluruh item di keranjang akan dihapus. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(_cart.clear);
    _showMessage('Keranjang dikosongkan');
  }

  /// Tugas 2: konfirmasi pembayaran, bersihkan keranjang, tampilkan SnackBar.
  Future<void> _checkout() async {
    if (_isEmpty) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text('Total transaksi ${formatRupiah(_total)}.\nBayar sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(_cart.clear);
    _showMessage('Transaksi Berhasil!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesin Kasir'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Kosongkan Keranjang',
            onPressed: _resetCart,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _TotalCard(total: _total),
          Expanded(child: _buildCartList()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    if (_isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Keranjang kosong\nPindai QR produk untuk mulai belanja',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _cart.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final CartItem item = _cart[index];

        return Dismissible(
          key: ValueKey<String>(item.product.code),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _removeFromCart(item),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('${item.quantity}x ${item.product.name}'),
              subtitle: Text(
                '${item.product.code} • ${formatRupiah(item.product.price)}/pcs',
              ),
              trailing: Text(
                formatRupiah(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _openScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Pindai QR Produk'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isEmpty ? null : _checkout,
                icon: const Icon(Icons.payment),
                label: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu ringkasan total transaksi.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Transaksi',
            style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(total),
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
