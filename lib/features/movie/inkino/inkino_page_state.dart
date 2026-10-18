import 'package:dashboard/features/movie/inkino/inkino_api.dart';
import 'package:dashboard/features/movie/inkino/inkino_clock.dart';
import 'package:dashboard/features/movie/inkino/inkino_dates.dart';
import 'package:dashboard/features/movie/inkino/inkino_page.dart';
import 'package:dashboard/features/movie/inkino/inkino_schedule.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';
import 'package:dashboard/features/movie/inkino/inkino_show_details_page.dart';
import 'package:dashboard/features/movie/inkino/inkino_show_grouper.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_areas_catalog.dart';
import 'package:flutter/material.dart';

class InKinoPageState extends State<InKinoPage> {
  late final InKinoApi _api;
  late final DateTime Function() _clock;

  /// Owns the injected client only when it created one.
  bool _ownsApi = false;

  /// One entry per `(area, date)` — the source's `DateTheaterPair` cache.
  final Map<String, InKinoSchedule> _cache = {};

  List<InKinoTheaterArea> _areas = const [];
  String? _areaId;
  late DateTime _today;
  late List<DateTime> _dates;
  late DateTime _selectedDate;

  InKinoSchedule? _schedule;
  bool _loading = false;
  String? _error;

  String get _areaName => _areas
      .firstWhere(
        (area) => area.id == _areaId,
        orElse: () => const InKinoTheaterArea(id: '', name: 'All theaters'),
      )
      .name;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? InKinoApi();
    _ownsApi = widget.api == null;
    _clock = widget.clock ?? InKinoClock.currentTime;
    _today = InKinoDates.dateOnly(_clock());
    _dates = InKinoDates.upcomingDays(_today);
    _selectedDate = _dates.first;
    _loadAreas();
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  /// Loads the theatre areas, then the default day's schedule. Never called
  /// from `build`.
  Future<void> _loadAreas() async {
    List<InKinoTheaterArea> areas;
    try {
      areas = await (widget.onFetchAreas ?? _api.theaterAreas)();
      if (areas.isEmpty) areas = InKinoTheaterAreasCatalog.all();
    } catch (_) {
      // The source pre-bundled this response, so a failed live fetch degrades
      // to the same snapshot instead of blocking the whole page.
      areas = InKinoTheaterAreasCatalog.all();
    }
    if (!mounted) return;

    final preferred = widget.defaultAreaId;
    String areaId;
    if (preferred != null && areas.any((area) => area.id == preferred)) {
      areaId = preferred;
    } else if (areas.any(
      (area) => area.id == InKinoTheaterArea.defaultAreaId,
    )) {
      areaId = InKinoTheaterArea.defaultAreaId;
    } else if (areas.isNotEmpty) {
      areaId = areas.first.id;
    } else {
      areaId = InKinoTheaterArea.defaultAreaId;
    }

    setState(() {
      _areas = areas;
      _areaId = areaId;
    });
    await _loadSchedule(_selectedDate, areaId: areaId);
  }

  Future<void> _loadSchedule(DateTime date, {String? areaId}) async {
    final area = areaId ?? _areaId;
    if (area == null) return;
    final day = InKinoDates.dateOnly(date);

    // Already-fetched `(area, date)` pairs are re-displayed, not re-requested.
    final cached = _cache['$area@${InKinoDates.dateKey(day)}'];
    if (cached != null) {
      setState(() {
        _selectedDate = day;
        _schedule = cached;
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _selectedDate = day;
      _schedule = null;
      _loading = true;
      _error = null;
    });

    try {
      final shows = await _api.schedule(areaId: area, date: day);
      if (!mounted) return;
      final schedule = InKinoSchedule(areaId: area, date: day, shows: shows);
      setState(() {
        _cache[schedule.key] = schedule;
        _schedule = schedule;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _openShowDetails(InKinoShow show) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InKinoShowDetailsPage(show: show),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Finnkino 排片 · $_areaName'),
      actions: [
        IconButton(
          tooltip: '刷新',
          onPressed: _loading ? null : () => _loadSchedule(_selectedDate),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        _areaSelector(),
        _dateSelector(),
        if (_loading) const LinearProgressIndicator(),
        Expanded(child: _body()),
      ],
    ),
  );

  Widget _areaSelector() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    child: DropdownButtonFormField<String>(
      initialValue: _areaId,
      decoration: const InputDecoration(labelText: '影院区域', isDense: true),
      items: _areas
          .map(
            (area) => DropdownMenuItem<String>(
              value: area.id,
              child: Text(area.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null || value == _areaId) return;
        setState(() => _areaId = value);
        _loadSchedule(_selectedDate, areaId: value);
      },
    ),
  );

  Widget _dateSelector() => SizedBox(
    height: 72,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: _dates.length,
      itemBuilder: (context, index) {
        final date = _dates[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            selected: InKinoDates.isSameDay(date, _selectedDate),
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  InKinoDates.dayLabel(date, _today),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(InKinoDates.chipLabel(date)),
              ],
            ),
            onSelected: (_) => _loadSchedule(date),
          ),
        );
      },
    ),
  );

  Widget _body() {
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _loadSchedule(_selectedDate),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final schedule = _schedule;
    if (_loading && schedule == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (schedule == null) {
      return const Center(child: Text('请选择影院区域与日期'));
    }

    final grouped = InKinoShowGrouper.byTheater(
      schedule,
      _selectedDate,
      clock: _clock,
    );
    if (grouped.isEmpty) {
      return Center(
        child: Text(
          InKinoDates.isSameDay(_selectedDate, _today)
              ? '今天已无未开场的排片'
              : '该日期暂无排片',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              entry.key,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          for (final show in entry.value) _showTile(show),
        ],
      ],
    );
  }

  Widget _showTile(InKinoShow show) => ListTile(
    title: Text(show.title),
    subtitle: Text(
      '${show.startsAtLabel}–${show.endsAtLabel} · ${show.auditorium}'
      '${show.presentationMethod == null ? '' : ' · ${show.presentationMethod}'}',
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (show.hasAgeRating)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(show.ageRating!, style: const TextStyle(fontSize: 12)),
          ),
        const Icon(Icons.chevron_right),
      ],
    ),
    onTap: () => _openShowDetails(show),
  );
}
