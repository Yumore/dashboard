/// A breadcrumb item of a thread page.
///
/// Ported from `tsdm_client/lib/features/thread/v1/models/thread_breadcrumb.dart`.
class TsdmThreadBreadcrumb {
  /// Create a breadcrumb.
  const TsdmThreadBreadcrumb({required this.description, required this.link});

  /// Description text of the breadcrumb.
  final String description;

  /// Link of the breadcrumb.
  final Uri link;
}
