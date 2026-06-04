import 'package:intl/intl.dart';

String numberFormatter(dynamic number, int decimalDigits) =>
    NumberFormat.decimalPatternDigits(
            locale: 'en_US', decimalDigits: decimalDigits)
        .format(number);

String Function(DateTime) dateFormatter =
    DateFormat('MMMM d, y hh:mm a', 'en_US').format;

enum NumberAbbreviation { B, M, K }

NumberAbbreviation? getAbbreviation(double number) {
  if (number.abs() >= 1000000000) return NumberAbbreviation.B;
  if (number.abs() >= 1000000) return NumberAbbreviation.M;
  if (number.abs() >= 1000) return NumberAbbreviation.K;
  return null;
}

double numberAbbreviated(double number, NumberAbbreviation? abbreviation) {
  switch (abbreviation) {
    case NumberAbbreviation.B:
      final double result = number / 1000000000;
      return double.parse(result.toStringAsFixed(2));
    case NumberAbbreviation.M:
      final double result = number / 1000000;
      return double.parse(result.toStringAsFixed(2));
    case NumberAbbreviation.K:
      final double result = number / 1000;
      return double.parse(result.toStringAsFixed(2));

    default:
      return double.parse(number.toStringAsFixed(2));
  }
}

String numberAbbreviatedFormatter(
    double number, NumberAbbreviation? abbreviation) {
  switch (abbreviation) {
    case NumberAbbreviation.B:
      final double result = number / 1000000000;
      return '${result.toStringAsFixed(2)}B';
    case NumberAbbreviation.M:
      final double result = number / 1000000;
      return '${result.toStringAsFixed(2)}M';
    case NumberAbbreviation.K:
      final double result = number / 1000;
      return '${result.toStringAsFixed(2)}K';

    default:
      return number.toStringAsFixed(2);
  }
}

/// Canonical display order for Indigo iAssets.
const _kAssetOrder = ['iUSD', 'iBTC', 'iETH', 'iSOL'];

int assetSortIndex(String asset) {
  final i = _kAssetOrder.indexOf(asset);
  return i >= 0 ? i : _kAssetOrder.length;
}

/// Sort a list of objects that expose an [asset] name by canonical order.
List<T> sortedByAsset<T>(List<T> items, String Function(T) getName) {
  final copy = List<T>.from(items);
  copy.sort((a, b) => assetSortIndex(getName(a))
      .compareTo(assetSortIndex(getName(b))));
  return copy;
}

/// Decode a Cardano collateral asset identifier to a human-readable label.
/// Empty string → "ADA"; policy.hexTokenName → decoded token name (e.g. "NIGHT").
String collateralLabel(String collateralAsset) {
  if (collateralAsset.isEmpty) return 'ADA';
  final parts = collateralAsset.split('.');
  if (parts.length == 2) {
    try {
      final hex = parts[1];
      final bytes = <int>[
        for (var i = 0; i + 1 < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ];
      final name = String.fromCharCodes(bytes);
      if (name.isNotEmpty) return name;
    } catch (_) {}
  }
  return collateralAsset.length > 8
      ? '${collateralAsset.substring(0, 8)}…'
      : collateralAsset;
}
