/// Substitution for EasyMyGo's `xpath_selector_html_parser` dependency.
///
/// The host does not depend on an XPath engine, so `HtmlXPath` rules are served
/// by translating the XPath subset the built-in sources used into CSS selectors
/// that the already-present `html` package can evaluate:
///
/// * `//tag`, `.//tag`, `/root/tag`  → descendant selector
/// * `[@attr='v']`, `[@attr="v"]`    → `[attr="v"]` (and `[@id='v']` → `#v`)
/// * `[contains(@class,'v')]`        → `.v`
/// * `[@attr]`                       → `[attr]`
///
/// Anything the translator cannot express (`text()`, `position()`, numeric
/// positional predicates) yields an empty selector, which matches nothing —
/// the same "empty result" the original produced for an unsatisfiable path.
String xpathToCss(String xpath) {
  var value = xpath.trim();
  if (value.isEmpty) return '';
  if (value.contains('text()') ||
      value.contains('position()') ||
      value.contains('last()')) {
    return '';
  }
  if (value.startsWith('//')) {
    value = value.substring(2);
  } else if (value.startsWith('.//')) {
    value = value.substring(3);
  } else if (value.startsWith('/')) {
    value = value.substring(1);
  }
  value = value.replaceAll('//', ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ');
  value = value.replaceAllMapped(
    RegExp(r"\[contains\(@class\s*,\s*'([^']+)'\)\]"),
    (m) => '.${m[1]}',
  );
  value = value.replaceAllMapped(
    RegExp(r'\[contains\(@class\s*,\s*"([^"]+)"\)\]'),
    (m) => '.${m[1]}',
  );
  value = value.replaceAllMapped(
    RegExp(r"\[@id\s*=\s*'([^']+)'\]"),
    (m) => '#${m[1]}',
  );
  value = value.replaceAllMapped(
    RegExp(r'\[@id\s*=\s*"([^"]+)"\]'),
    (m) => '#${m[1]}',
  );
  value = value.replaceAllMapped(
    RegExp(r"\[@([A-Za-z_:][-A-Za-z0-9_:.]*)\s*=\s*'([^']*)'\]"),
    (m) => '[${m[1]}="${m[2]}"]',
  );
  value = value.replaceAllMapped(
    RegExp(r'\[@([A-Za-z_:][-A-Za-z0-9_:.]*)\s*=\s*"([^"]*)"\]'),
    (m) => '[${m[1]}="${m[2]}"]',
  );
  value = value.replaceAllMapped(
    RegExp(r'\[@([A-Za-z_:][-A-Za-z0-9_:.]*)\]'),
    (m) => '[${m[1]}]',
  );
  value = value.trim();
  if (value.contains('[@') ||
      value.contains('(') ||
      RegExp(r'\[\s*\d').hasMatch(value)) {
    // A leftover predicate (positional index, unsupported function) cannot be
    // expressed in CSS — fail closed, exactly like an unsatisfiable XPath.
    return '';
  }
  return value;
}
