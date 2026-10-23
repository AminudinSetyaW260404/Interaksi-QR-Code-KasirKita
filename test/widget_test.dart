import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kasir_kita/main.dart';
import 'package:kasir_kita/models/product_model.dart';
import 'package:kasir_kita/pages/catalog_page.dart';
import 'package:kasir_kita/pages/pos_page.dart';
import 'package:kasir_kita/utils/currency_formatter.dart';

void main() {
  testWidgets('menu utama menampilkan Mesin Kasir dan Katalog QR', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KasirKitaApp());

    expect(find.text('Mesin Kasir'), findsOneWidget);
    expect(find.text('Katalog QR'), findsOneWidget);
  });

  testWidgets('tombol bayar disabled saat keranjang kosong', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PosPage()));

    expect(find.text('Total Transaksi'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
    expect(find.textContaining('Keranjang kosong'), findsOneWidget);

    await tester.tap(find.text('Bayar Sekarang'));
    await tester.pumpAndSettle();

    expect(
      find.byType(AlertDialog),
      findsNothing,
      reason: 'pembayaran tidak boleh jalan saat keranjang kosong',
    );
  });

  testWidgets('katalog menampilkan 4 produk beserta QR Code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogPage()));

    expect(find.textContaining('BRG-001'), findsOneWidget);
    expect(find.textContaining('BRG-004'), findsOneWidget);
    expect(find.byType(QrImageView), findsNWidgets(4));
  });

  testWidgets('pemindaian ulang menambah kuantitas item yang sama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PosPage()));

    final dynamic pos = tester.state(find.byType(PosPage));
    pos.addProductByCode('BRG-001');
    await tester.pump();
    pos.addProductByCode('BRG-001');
    await tester.pump();

    expect(find.text('2x Roti Coklat'), findsOneWidget);
    expect(find.text('Rp 24.000'), findsNWidgets(2));
    expect(find.textContaining('1x Air Mineral'), findsNothing);
  });

  testWidgets('tombol bayar menampilkan konfirmasi lalu transaksi berhasil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PosPage()));

    final dynamic pos = tester.state(find.byType(PosPage));
    pos.addProductByCode('BRG-002');
    await tester.pump();

    await tester.tap(find.text('Bayar Sekarang'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    expect(find.textContaining('Rp 5.000'), findsAtLeastNWidgets(2));

    await tester.tap(find.text('Ya'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('Keranjang kosong'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
    expect(find.text('Transaksi Berhasil!'), findsOneWidget);
  });

  testWidgets('item keranjang bisa dihapus dengan menggeser (Dismissible)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PosPage()));

    final dynamic pos = tester.state(find.byType(PosPage));
    pos.addProductByCode('BRG-003');
    await tester.pump();

    // SnackBar juga memakai Dismissible internal, jadi batasi ke daftar item.
    final Finder itemFinder = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Dismissible),
    );

    expect(itemFinder, findsOneWidget);

    await tester.fling(
      find.text('1x Kopi Susu'),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(itemFinder, findsNothing);
    expect(find.textContaining('Keranjang kosong'), findsOneWidget);
  });

  test('format rupiah tanpa digit desimal', () {
    expect(formatRupiah(24000), 'Rp 24.000');
    expect(formatRupiah(0), 'Rp 0');
  });

  test('kode yang sama menambah kuantitas pada item yang sama', () {
    final Product product = findProductByCode('BRG-001')!;
    final CartItem item = CartItem(product: product);

    item.increaseQuantity();
    item.increaseQuantity();

    expect(item.quantity, 3);
    expect(item.subtotal, product.price * 3);
  });
}
