import 'package:flutter/foundation.dart';

/// A tiny change bus used to tell sibling tabs that local data changed.
///
/// Importing a search hit must refresh the collection tab and the delete/dedup
/// tools must refresh every tab; rather than threading callbacks through the
/// page, the tabs listen to one [ChangeNotifier].
class AnimeTraceRefreshBus extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}
