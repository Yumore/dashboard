import 'package:dashboard/features/reading/alexandria/alexandria_filters.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_filters_sheet.dart';
import 'package:flutter/material.dart';

class AlexandriaFiltersSheetState extends State<AlexandriaFiltersSheet> {
  late final TextEditingController _zlibYearFrom;
  late final TextEditingController _zlibYearTo;
  late final TextEditingController _libGenYearFrom;
  late final TextEditingController _libGenYearTo;

  late String _zlibLanguage;
  late String _zlibExtension;
  late String _libGenLanguage;
  late String _libGenExtension;

  @override
  void initState() {
    super.initState();
    final filters = widget.filters;
    _zlibLanguage = _option(
      AlexandriaFilters.zlibLanguages,
      filters.zlibLanguage,
    );
    _zlibExtension = _option(
      AlexandriaFilters.zlibExtensions,
      filters.zlibExtension,
    );
    _libGenLanguage = _option(
      AlexandriaFilters.libGenLanguages,
      filters.libGenLanguage,
    );
    _libGenExtension = _option(
      AlexandriaFilters.libGenExtensions,
      filters.libGenExtension,
    );
    _zlibYearFrom = _yearController(filters.zlibYearFrom);
    _zlibYearTo = _yearController(filters.zlibYearTo);
    _libGenYearFrom = _yearController(filters.libGenYearFrom);
    _libGenYearTo = _yearController(filters.libGenYearTo);
  }

  @override
  void dispose() {
    _zlibYearFrom.dispose();
    _zlibYearTo.dispose();
    _libGenYearFrom.dispose();
    _libGenYearTo.dispose();
    super.dispose();
  }

  static TextEditingController _yearController(String value) =>
      TextEditingController(
        text: value == AlexandriaFilters.yearUnset ? '' : value,
      );

  static String _option(List<String> options, String? value) =>
      value != null && options.contains(value)
      ? value
      : AlexandriaFilters.allOption;

  static String? _nullable(String value) =>
      value == AlexandriaFilters.allOption ? null : value;

  static String _year(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? AlexandriaFilters.yearUnset : trimmed;
  }

  void _apply() {
    final filters = widget.filters;
    filters.zlibLanguage = _nullable(_zlibLanguage);
    filters.zlibExtension = _nullable(_zlibExtension);
    filters.zlibYearFrom = _year(_zlibYearFrom.text);
    filters.zlibYearTo = _year(_zlibYearTo.text);
    filters.libGenLanguage = _nullable(_libGenLanguage);
    filters.libGenExtension = _nullable(_libGenExtension);
    filters.libGenYearFrom = _year(_libGenYearFrom.text);
    filters.libGenYearTo = _year(_libGenYearTo.text);
    Navigator.of(context).pop(true);
  }

  void _reset() {
    setState(() {
      _zlibLanguage = AlexandriaFilters.allOption;
      _zlibExtension = AlexandriaFilters.allOption;
      _libGenLanguage = AlexandriaFilters.allOption;
      _libGenExtension = AlexandriaFilters.allOption;
      _zlibYearFrom.text = '';
      _zlibYearTo.text = '';
      _libGenYearFrom.text = '';
      _libGenYearTo.text = '';
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('筛选', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('重置')),
              ],
            ),
            _section(context, 'Z-Library'),
            _dropdown(
              label: '语言',
              options: AlexandriaFilters.zlibLanguages,
              value: _zlibLanguage,
              onChanged: (value) => setState(() => _zlibLanguage = value),
            ),
            _dropdown(
              label: '格式',
              options: AlexandriaFilters.zlibExtensions,
              value: _zlibExtension,
              onChanged: (value) => setState(() => _zlibExtension = value),
            ),
            _yearRow(label: '起始年份', controller: _zlibYearFrom),
            _yearRow(label: '结束年份', controller: _zlibYearTo),
            _section(context, 'Library Genesis'),
            _dropdown(
              label: '语言',
              options: AlexandriaFilters.libGenLanguages,
              value: _libGenLanguage,
              onChanged: (value) => setState(() => _libGenLanguage = value),
            ),
            _dropdown(
              label: '格式',
              options: AlexandriaFilters.libGenExtensions,
              value: _libGenExtension,
              onChanged: (value) => setState(() => _libGenExtension = value),
            ),
            _yearRow(label: '起始年份', controller: _libGenYearFrom),
            _yearRow(label: '结束年份', controller: _libGenYearTo),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _apply, child: const Text('应用筛选')),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _dropdown({
    required String label,
    required List<String> options,
    required String value,
    required ValueChanged<String> onChanged,
  }) => Row(
    children: [
      SizedBox(width: 96, child: Text(label)),
      Expanded(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: [
            for (final option in options)
              DropdownMenuItem<String>(value: option, child: Text(option)),
          ],
          onChanged: (selected) =>
              onChanged(selected ?? AlexandriaFilters.allOption),
        ),
      ),
    ],
  );

  Widget _yearRow({
    required String label,
    required TextEditingController controller,
  }) => Row(
    children: [
      SizedBox(width: 96, child: Text(label)),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'year',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}
