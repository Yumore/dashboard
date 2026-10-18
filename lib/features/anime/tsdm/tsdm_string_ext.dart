/// String helpers used by the tsdm parsers.
///
/// Ported from `tsdm_client/lib/extensions/string.dart` (the pure string
/// helpers only; the routing helpers of that file are not part of the port).
extension TsdmStringParseExtension on String {
  /// Parse this string as an [int], null when invalid.
  int? parseToInt() => int.tryParse(this);

  /// Parse `"yyyy-MM-DD HH:mm:ss"` or `"yyyy-MM-DD"` into a [DateTime].
  ///
  /// Allows `"yyyy-M-D"` and pads each part to two digits. Returns null when
  /// the string has more than two space separated parts or is not a date.
  DateTime? parseToDateTimeUtc8() {
    final list = split(' ');
    if (list.isEmpty || list.length > 2) {
      return null;
    }
    final timePart = list.length > 1 ? list[1] : null;

    final datePartList = list[0].split('-');
    if (datePartList.length != 3) {
      return DateTime.tryParse(this);
    }
    final formattedDateString =
        '${datePartList[0]}-'
        '${datePartList[1].padLeft(2, '0')}-'
        '${datePartList[2].padLeft(2, '0')}';
    return DateTime.tryParse(
      timePart == null ? formattedDateString : '$formattedDateString $timePart',
    );
  }
}

/// String helpers used by the tsdm parsers.
extension TsdmStringEnhanceExtension on String {
  /// Prepend the tsdm host when this string is a relative url.
  String prependHost() {
    if (startsWith('https://') ||
        startsWith('http://') ||
        startsWith('mailto:')) {
      return this;
    }
    return 'https://www.tsdm39.com/$this';
  }

  /// Truncate this string at [size].
  String truncate(int size, {bool ellipsis = false}) {
    return length > size
        ? '${substring(0, size)}${ellipsis ? '...' : ''}'
        : this;
  }

  /// Trim the trailing web page title.
  String trimTitle() {
    return replaceFirst(' -  天使动漫论坛 - 梦开始的地方  -  Powered by Discuz!', '');
  }

  /// Parse url encoded query parameters of this string, null when invalid.
  Map<String, String>? tryGetQueryParameters() {
    try {
      return Uri.parse(this).queryParameters;
    } on FormatException {
      return null;
    }
  }

  /// Parse this string as a [Uri], null when invalid.
  Uri? tryParseAsUri() {
    try {
      return Uri.parse(this);
    } on FormatException {
      return null;
    }
  }

  /// Get the value of query parameter [name] of this string, null when absent.
  String? uriQueryParameter(String name) {
    try {
      return Uri.parse(this).queryParameters[name];
    } on FormatException {
      return null;
    }
  }
}

/// Privacy helpers, so credentials and identifiers never reach a log.
extension TsdmStringObscureExtension on String {
  /// Obscure this string, keeping only its length and the first characters
  /// replaced by `*`. An empty string is reported as `<empty string>`.
  String obscured([int length = 8]) {
    if (isEmpty) {
      return '<empty string>';
    }
    final visible = this.length > length ? substring(0, 1) : '';
    final hidden = length - visible.length;
    final stars = '*' * (hidden < 1 ? 1 : hidden);
    return '$visible$stars';
  }
}
