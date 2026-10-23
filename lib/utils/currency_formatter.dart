import 'package:intl/intl.dart';

/// Format angka menjadi mata uang Rupiah tanpa digit desimal,
/// contoh: `24000` -> `Rp 24.000`.
String formatRupiah(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
