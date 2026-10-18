/// Ported from `BufferUtils` (`lib/plugin/source/utils/buffer/buffer_utils.dart`).
///
/// The JS engine let source authors stash intermediate values between action
/// calls; the port keeps the same `buffer@<counter>` key scheme so rule sources
/// that carry data through the buffer still behave identically.
class RuleBuffer {
  RuleBuffer();

  final Map<String, String> _values = <String, String>{};
  int _counter = 0;

  int get counter => _counter;

  Map<String, String> get values => Map<String, String>.unmodifiable(_values);

  /// Stores [value] and returns its generated key.
  String put(String value) {
    final key = 'buffer@$_counter';
    _counter++;
    _values[key] = value;
    return key;
  }

  String? get(String key) => _values[key];

  bool contains(String key) => _values.containsKey(key);

  void clear() {
    _values.clear();
    _counter = 0;
  }
}
