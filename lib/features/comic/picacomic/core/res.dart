import 'package:flutter/foundation.dart';

/// Ports PicaComic's `lib/network/res.dart`.
///
/// A network result: either data or an error message. `subData` carries
/// out-of-band paging information (for comic lists it holds `maxPage`).
@immutable
class Res<T> {
  /// Error info, `null` when the request succeeded.
  final String? errorMessage;

  /// Data payload, `null` when the request failed.
  final T? dataOrNull;

  /// Paging/auxiliary payload, e.g. `maxPage` for comic list results.
  final dynamic subData;

  const Res(this.dataOrNull, {this.errorMessage, this.subData});

  const Res.error(String err)
    : dataOrNull = null,
      subData = null,
      errorMessage = err;

  Res.fromErrorRes(Res<dynamic> another, {this.subData})
    : dataOrNull = null,
      errorMessage = another.errorMessageWithoutNull;

  String get errorMessageWithoutNull => errorMessage ?? 'Unknown Error';

  /// Whether the request failed.
  bool get error => errorMessage != null;

  /// Whether the request succeeded.
  bool get success => !error;

  /// The payload; throws when called on a failed [Res].
  T get data => dataOrNull ?? (throw Exception(errorMessage));

  @override
  String toString() => dataOrNull.toString();
}
