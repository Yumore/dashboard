import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One entry of `product_id_list`.
///
/// Unlike the other option lists, the backend sends `name` as an int here
/// (`2` for the comic product); verified against the source model.
///
/// Source: `lib/models/rank_types.dart` → `Product_id_list`.
class ManhuataiProductOption {
  const ManhuataiProductOption({required this.name, required this.value});

  final int name;
  final String value;

  factory ManhuataiProductOption.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiProductOption(
      name: ManhuataiJson.asInt(source['name']),
      value: ManhuataiJson.asString(source['value']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'value': value,
      };
}
