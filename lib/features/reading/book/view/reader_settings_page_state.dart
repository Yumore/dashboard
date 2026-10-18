import 'package:dashboard/features/reading/book/reader/reader_settings.dart';
import 'package:dashboard/features/reading/book/util/book_local_store.dart';
import 'package:dashboard/features/reading/book/view/reader_settings_page.dart';
import 'package:flutter/material.dart';

class ReaderSettingsPageState extends State<ReaderSettingsPage> {
  double _fontSize = 18;
  double _lineHeight = 1.6;
  double _letterSpace = 0;
  double _paragraph = 0.8;
  int _pageDis = 20;
  int _pageTurnMode = 0;
  PaperTheme _paper = PaperTheme.white;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await SpUtil.getInstance();
    if (!mounted) return;
    setState(() {
      _fontSize = ReaderSettings.getFontSize();
      _lineHeight = ReaderSettings.getLineHeight();
      _letterSpace = ReaderSettings.getLetterSpace();
      _paragraph = ReaderSettings.getParagraph();
      _pageDis = ReaderSettings.getPageDis();
      _pageTurnMode = ReaderSettings.getPageTurnMode();
      _paper = ReaderSettings.getPaperTheme();
      _ready = true;
    });
  }

  void _notify() {
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('阅读设置')),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _slider(
                  label: '字号 ${_fontSize.toStringAsFixed(1)}',
                  value: _fontSize,
                  min: 12,
                  max: 32,
                  onChanged: (v) {
                    setState(() => _fontSize = v);
                    ReaderSettings.setFontSize(v);
                    _notify();
                  },
                ),
                _slider(
                  label: '行距 ${_lineHeight.toStringAsFixed(1)}',
                  value: _lineHeight,
                  min: 1.0,
                  max: 2.6,
                  onChanged: (v) {
                    setState(() => _lineHeight = v);
                    ReaderSettings.setLineHeight(v);
                    _notify();
                  },
                ),
                _slider(
                  label: '字距 ${_letterSpace.toStringAsFixed(1)}',
                  value: _letterSpace,
                  min: 0,
                  max: 4,
                  onChanged: (v) {
                    setState(() => _letterSpace = v);
                    ReaderSettings.setLetterSpace(v);
                    _notify();
                  },
                ),
                _slider(
                  label: '段距 ${_paragraph.toStringAsFixed(1)}',
                  value: _paragraph,
                  min: 0,
                  max: 2,
                  onChanged: (v) {
                    setState(() => _paragraph = v);
                    ReaderSettings.setParagraph(v);
                    _notify();
                  },
                ),
                _slider(
                  label: '页边距 $_pageDis',
                  value: _pageDis.toDouble(),
                  min: 0,
                  max: 60,
                  onChanged: (v) {
                    final value = v.round();
                    setState(() => _pageDis = value);
                    ReaderSettings.setPageDis(value);
                    _notify();
                  },
                ),
                const Divider(height: 32),
                Text('背景', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: PaperTheme.values.map((theme) {
                    final selected = theme == _paper;
                    return InkWell(
                      onTap: () {
                        setState(() => _paper = theme);
                        ReaderSettings.setPaperTheme(theme);
                        _notify();
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ReaderSettings.paperColor(theme),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black26,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ReaderSettings.paperLabel(theme),
                          style: TextStyle(
                            color: ReaderSettings.inkColor(theme),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 32),
                Text('翻页方式', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('覆盖')),
                    ButtonSegment(value: 1, label: Text('滑动')),
                    ButtonSegment(value: 2, label: Text('无动画')),
                  ],
                  selected: {_pageTurnMode},
                  onSelectionChanged: (selection) {
                    final mode = selection.first;
                    setState(() => _pageTurnMode = mode);
                    ReaderSettings.setPageTurnMode(mode);
                    _notify();
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  '阅读偏好通过 shared_preferences 持久化（ReaderSettings）。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
