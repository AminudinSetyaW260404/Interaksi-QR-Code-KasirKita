import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Halaman pemindai QR Code.
///
/// Mengembalikan string hasil pindai ke halaman kasir melalui
/// `Navigator.pop(context, hasilPindai)` ketika QR terdeteksi.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  /// Mencegah pemindaian yang sama memicu pop berkali-kali.
  bool _resultHandled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_resultHandled || capture.barcodes.isEmpty) {
      return;
    }

    final String? code = capture.barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) {
      return;
    }

    _resultHandled = true;
    Navigator.of(context).pop(code.trim());
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pindai QR Produk'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final bool torchAvailable =
                  state.torchState != TorchState.unavailable;
              final bool torchOn = state.torchState == TorchState.on;

              return IconButton(
                tooltip: 'Senter',
                onPressed: torchAvailable ? _toggleTorch : null,
                icon: Icon(torchOn ? Icons.flash_on : Icons.flash_off),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.no_photography,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error.errorCode.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const _ScanOverlay(),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: _ScanHint(),
          ),
        ],
      ),
    );
  }
}

/// Bingkai tengah sebagai panduan mengarahkan QR ke kamera.
class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white70, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ScanHint extends StatelessWidget {
  const _ScanHint();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'Arahkan kamera ke QR Code produk',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
