/// A collection label (the source app's `Label`).
///
/// Label id `-1` with an empty name is the "no label" sentinel used by filter
/// dropdowns.
class AnimeTraceLabel {
  const AnimeTraceLabel(this.id, this.name);

  final int id;
  final String name;

  factory AnimeTraceLabel.none() => const AnimeTraceLabel(-1, '');

  bool get isNone => id == -1 && name.isEmpty;

  bool get isValid => !isNone;

  Map<String, Object?> toMap() => <String, Object?>{'id': id, 'name': name};

  factory AnimeTraceLabel.fromMap(Map<String, Object?> map) {
    final rawId = map['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final rawName = map['name'];
    return AnimeTraceLabel(id, rawName is String ? rawName : '');
  }

  @override
  bool operator ==(Object other) =>
      other is AnimeTraceLabel && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'AnimeTraceLabel($id, $name)';
}
