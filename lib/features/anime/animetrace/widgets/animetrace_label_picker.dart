import 'package:dashboard/features/anime/animetrace/animetrace_label.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_label_dao.dart';
import 'package:flutter/material.dart';

/// Checkbox picker for the labels of one anime, with inline label creation.
///
/// Returns the chosen label ids, or `null` when dismissed. Newly typed labels
/// are inserted immediately (so they get a real id) and selected.
class AnimeTraceLabelPicker extends StatefulWidget {
  const AnimeTraceLabelPicker({
    required this.labelDao,
    required this.labels,
    required this.selectedIds,
    super.key,
  });

  final AnimeTraceLabelDao labelDao;
  final List<AnimeTraceLabel> labels;
  final List<int> selectedIds;

  /// Opens the picker and returns the new selection, or `null` when cancelled.
  static Future<List<int>?> show(
    BuildContext context, {
    required AnimeTraceLabelDao labelDao,
    required int animeId,
  }) async {
    final labels = await labelDao.getAll();
    final selected = await labelDao.getLabelIdsByAnimeId(animeId);
    if (!context.mounted) return null;
    return showDialog<List<int>>(
      context: context,
      builder: (_) => AnimeTraceLabelPicker(
        labelDao: labelDao,
        labels: labels,
        selectedIds: selected,
      ),
    );
  }

  @override
  State<AnimeTraceLabelPicker> createState() => _AnimeTraceLabelPickerState();
}

class _AnimeTraceLabelPickerState extends State<AnimeTraceLabelPicker> {
  late List<AnimeTraceLabel> _labels = List<AnimeTraceLabel>.of(widget.labels);
  late final Set<int> _selected = <int>{...widget.selectedIds};
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createLabel() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_labels.any((label) => label.name == name)) {
      _nameController.clear();
      return;
    }
    final id = await widget.labelDao.insert(name);
    if (!mounted) return;
    setState(() {
      _labels = <AnimeTraceLabel>[..._labels, AnimeTraceLabel(id, name)];
      _selected.add(id);
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择标签'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_labels.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('还没有标签，先创建一个。'),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final label in _labels)
                        CheckboxListTile(
                          dense: true,
                          value: _selected.contains(label.id),
                          title: Text(label.name),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selected.add(label.id);
                              } else {
                                _selected.remove(label.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            const Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '新标签',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _createLabel(),
                  ),
                ),
                IconButton(
                  tooltip: '添加',
                  icon: const Icon(Icons.add),
                  onPressed: _createLabel,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected.toList()),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
