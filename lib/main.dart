import 'package:flutter/material.dart';

import 'pages/catalog_page.dart';
import 'pages/pos_page.dart';

void main() {
  runApp(const KasirKitaApp());
}

/// Aplikasi utama KasirKita.
class KasirKitaApp extends StatelessWidget {
  const KasirKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasirKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

/// Menu utama dengan navigasi ke Mesin Kasir dan Katalog QR.
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KasirKita'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.point_of_sale, size: 72, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              'Interaksi QR Code & POS Kasir',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            _MenuButton(
              icon: Icons.point_of_sale,
              title: 'Mesin Kasir',
              subtitle: 'Pindai QR dan transaksi penjualan',
              onTap: () => _open(context, const PosPage()),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.qr_code_2,
              title: 'Katalog QR',
              subtitle: 'Daftar produk beserta QR Code',
              onTap: () => _open(context, const CatalogPage()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => page));
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
