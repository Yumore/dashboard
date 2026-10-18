import 'package:html/dom.dart' as dom;

/// Selector compatibility layer for the TSDM parsers.
///
/// `package:html`'s csslib resolves `:nth-child(n)` by counting *all* child
/// nodes, including whitespace text nodes, so `td:nth-child(2)` only matched
/// the second cell when the markup happened to be written on a single line.
/// Real Discuz markup is pretty-printed, which made every `:nth-child(n)`
/// selector beyond the first element child silently return nothing.
///
/// [TsdmSelector] strips the pseudo class, evaluates the rest of the selector
/// with csslib and then applies the index against the element children of the
/// parent. Every parser in this package goes through [TsdmSelectorCompat.q] /
/// [TsdmSelectorCompat.qAll] so the ported selectors keep the semantics the
/// original `universal_html` implementation had.
class TsdmSelector {
  const TsdmSelector._();

  /// Resolve [selector] against [root] and return all matching descendants.
  static List<dom.Element> resolve(dom.Element root, String selector) {
    final steps = parse(selector);
    if (steps.isEmpty) {
      return const [];
    }
    var current = <dom.Element>[root];
    for (var index = 0; index < steps.length; index += 1) {
      final step = steps[index];
      final next = <dom.Element>[];
      for (final base in current) {
        if (index == 0) {
          if (step.selector.isEmpty) {
            continue;
          }
          for (final element in base.querySelectorAll(step.selector)) {
            if (_matchesIndex(element, step.childIndex)) {
              next.add(element);
            }
          }
          continue;
        }
        if (step.combinator == _combinatorChild) {
          for (final element in base.children) {
            if (!_matchesSelector(base, element, step.selector)) {
              continue;
            }
            if (_matchesIndex(element, step.childIndex)) {
              next.add(element);
            }
          }
        } else {
          for (final element in base.querySelectorAll(step.selector)) {
            if (_matchesIndex(element, step.childIndex)) {
              next.add(element);
            }
          }
        }
      }
      current = _dedupe(next);
      if (current.isEmpty) {
        return const [];
      }
    }
    return current;
  }

  /// Parse a selector into its combinators, simple selectors and indices.
  static List<TsdmSelectorStep> parse(String selector) {
    final steps = <TsdmSelectorStep>[];
    final buffer = StringBuffer();
    String? pendingCombinator;
    var depth = 0;
    var quote = '';
    var i = 0;

    void flush(String combinator) {
      final raw = buffer.toString().trim();
      buffer.clear();
      if (raw.isEmpty) {
        return;
      }
      final match = _nthChildPattern.firstMatch(raw);
      steps.add(
        TsdmSelectorStep(
          combinator: combinator,
          selector: match == null
              ? raw
              : raw.replaceFirst(_nthChildPattern, '').trim(),
          childIndex: match == null ? null : int.tryParse(match.group(1)!),
        ),
      );
    }

    while (i < selector.length) {
      final char = selector[i];
      if (quote.isNotEmpty) {
        buffer.write(char);
        if (char == quote) {
          quote = '';
        }
        i += 1;
        continue;
      }
      if (char == '"' || char == "'") {
        quote = char;
        buffer.write(char);
        i += 1;
        continue;
      }
      if (char == '[') {
        depth += 1;
      } else if (char == ']') {
        depth -= 1;
      }
      if (depth == 0 && char == '>') {
        flush(
          pendingCombinator ??
              (steps.isEmpty ? _combinatorDescendant : _combinatorDescendant),
        );
        pendingCombinator = _combinatorChild;
        i += 1;
        while (i < selector.length && selector[i].trim().isEmpty) {
          i += 1;
        }
        continue;
      }
      if (depth == 0 && char.trim().isEmpty) {
        final raw = buffer.toString().trim();
        if (raw.isNotEmpty) {
          flush(pendingCombinator ?? _combinatorDescendant);
          pendingCombinator = _combinatorDescendant;
        }
        i += 1;
        continue;
      }
      buffer.write(char);
      i += 1;
    }
    flush(pendingCombinator ?? _combinatorDescendant);
    return steps;
  }

  static final _nthChildPattern = RegExp(r':nth-child\(\s*(\d+)\s*\)');

  static const _combinatorChild = '>';
  static const _combinatorDescendant = ' ';

  static bool _matchesSelector(
    dom.Element base,
    dom.Element element,
    String selector,
  ) {
    if (selector.isEmpty) {
      return true;
    }
    for (final candidate in base.querySelectorAll(selector)) {
      if (identical(candidate, element)) {
        return true;
      }
    }
    return false;
  }

  static bool _matchesIndex(dom.Element element, int? childIndex) {
    if (childIndex == null) {
      return true;
    }
    final parent = element.parent;
    if (parent == null) {
      return false;
    }
    final index = parent.children.indexOf(element);
    return index >= 0 && index + 1 == childIndex;
  }

  static List<dom.Element> _dedupe(List<dom.Element> elements) {
    final seen = <dom.Element>{};
    final result = <dom.Element>[];
    for (final element in elements) {
      if (seen.add(element)) {
        result.add(element);
      }
    }
    return result;
  }
}

/// One step of a parsed selector.
class TsdmSelectorStep {
  /// Create a selector step.
  const TsdmSelectorStep({
    required this.combinator,
    required this.selector,
    required this.childIndex,
  });

  /// Combinator before this step: `>` or a space.
  final String combinator;

  /// Simple selector without the `:nth-child(n)` pseudo class.
  final String selector;

  /// One based child index when the step carried `:nth-child(n)`.
  final int? childIndex;
}

/// `q` / `qAll` helpers that keep the original `:nth-child(n)` semantics.
extension TsdmSelectorCompat on dom.Element {
  /// First descendant matching [selector], honouring `:nth-child(n)`.
  dom.Element? q(String selector) {
    final matches = TsdmSelector.resolve(this, selector);
    return matches.isEmpty ? null : matches.first;
  }

  /// All descendants matching [selector], honouring `:nth-child(n)`.
  List<dom.Element> qAll(String selector) =>
      TsdmSelector.resolve(this, selector);
}

/// Document level variants of [TsdmSelectorCompat].
extension TsdmDocumentSelectorCompat on dom.Document {
  /// First element matching [selector], honouring `:nth-child(n)`.
  dom.Element? q(String selector) => documentElement?.q(selector);

  /// All elements matching [selector], honouring `:nth-child(n)`.
  List<dom.Element> qAll(String selector) =>
      documentElement?.qAll(selector) ?? const [];
}
