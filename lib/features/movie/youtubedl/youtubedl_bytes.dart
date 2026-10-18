/// Port of the source app's `bytesToString` helper (binary units, 2 decimals).
class YoutubeDlBytes {
  const YoutubeDlBytes._();

  static const List<String> _symbols = <String>['B', 'KB', 'MB', 'GB', 'TB'];

  static String format(int bytes) {
    var value = bytes.toDouble();
    var unit = 0;
    while (value.abs() >= 1024 && unit < _symbols.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(2)} ${_symbols[unit]}';
  }
}
