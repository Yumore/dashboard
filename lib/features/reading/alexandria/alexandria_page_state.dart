import 'package:dashboard/features/reading/alexandria/alexandria_filters.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_filters_sheet.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_message_view.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_page.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_source.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_status.dart';
import 'package:dashboard/features/reading/alexandria/libgen_book.dart';
import 'package:dashboard/features/reading/alexandria/libgen_book_card.dart';
import 'package:dashboard/features/reading/alexandria/sci_hub_result.dart';
import 'package:dashboard/features/reading/alexandria/sci_hub_result_card.dart';
import 'package:dashboard/features/reading/alexandria/zlib_book.dart';
import 'package:dashboard/features/reading/alexandria/zlib_book_card.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AlexandriaPageState extends State<AlexandriaPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = <String>[
    'Z-Library',
    'Library Genesis',
    'Sci-Hub',
  ];
  static const List<String> _hints = <String>[
    '书名、作者或 ISBN',
    '书名、作者或 ISBN',
    'DOI、PMID 或文章链接',
  ];

  /// The source only offered "load more" once a full result page was loaded.
  static const int _zlibPageThreshold = 50;
  static const int _libGenPageThreshold = 100;

  late final TabController _tabController;
  late final TextEditingController _searchController;
  final AlexandriaSource _source = AlexandriaSource();
  final AlexandriaFilters _filters = AlexandriaFilters();
  final ScrollController _zlibScroll = ScrollController();
  final ScrollController _libGenScroll = ScrollController();
  final List<String> _lastQueries = <String>['', '', ''];

  int _tabIndex = 0;

  List<ZlibBook> _zlibBooks = const <ZlibBook>[];
  String _zlibQuery = '';
  String _zlibBaseUrl = '';
  int _zlibPage = 1;
  bool _zlibLoadingMore = false;
  AlexandriaStatus _zlibStatus = AlexandriaStatus.idle;
  String _zlibError = '';

  List<LibGenBook> _libGenBooks = const <LibGenBook>[];
  String _libGenQuery = '';
  int _libGenPage = 1;
  bool _libGenLoadingMore = false;
  AlexandriaStatus _libGenStatus = AlexandriaStatus.idle;
  String _libGenError = '';

  SciHubResult? _sciHubResult;
  AlexandriaStatus _sciHubStatus = AlexandriaStatus.idle;
  String _sciHubError = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController = TextEditingController();
    _tabController.addListener(_handleTabChanged);
    _zlibScroll.addListener(_handleZlibScroll);
    _libGenScroll.addListener(_handleLibGenScroll);
    _loadFilters();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _zlibScroll.dispose();
    _libGenScroll.dispose();
    _source.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // State plumbing
  // ---------------------------------------------------------------------------

  Future<void> _loadFilters() async {
    await _filters.load();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTabChanged() {
    if (_tabController.index == _tabIndex) {
      return;
    }
    setState(() {
      _tabIndex = _tabController.index;
      _searchController.text = _lastQueries[_tabIndex];
    });
  }

  void _handleZlibScroll() {
    if (!_zlibScroll.hasClients || _zlibStatus == AlexandriaStatus.loading) {
      return;
    }
    if (_zlibLoadingMore ||
        _zlibBooks.length < _zlibPageThreshold ||
        _zlibScroll.position.pixels <
            _zlibScroll.position.maxScrollExtent - 240) {
      return;
    }
    _searchZlib(nextPage: true);
  }

  void _handleLibGenScroll() {
    if (!_libGenScroll.hasClients ||
        _libGenStatus == AlexandriaStatus.loading) {
      return;
    }
    if (_libGenLoadingMore ||
        _libGenBooks.length < _libGenPageThreshold ||
        _libGenScroll.position.pixels <
            _libGenScroll.position.maxScrollExtent - 240) {
      return;
    }
    _searchLibGen(nextPage: true);
  }

  void _toast(String message) {
    AppToast.show(msg: message);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!mounted) {
        return;
      }
      _showError('无法打开链接：$url');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _share(String url) async {
    await SharePlus.instance.share(ShareParams(text: url));
  }

  void _submit() {
    if (_tabIndex == 0) {
      _searchZlib();
      return;
    }
    if (_tabIndex == 1) {
      _searchLibGen();
      return;
    }
    _searchSciHub();
  }

  Future<void> _openFilters() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AlexandriaFiltersSheet(filters: _filters),
    );
    if (changed != true || !mounted) {
      return;
    }
    await _filters.save();
    if (!mounted) {
      return;
    }
    setState(() {});
    if (_tabIndex == 0 && _zlibQuery.isNotEmpty) {
      await _searchZlib();
    }
    if (_tabIndex == 1 && _libGenQuery.isNotEmpty) {
      await _searchLibGen();
    }
  }

  // ---------------------------------------------------------------------------
  // Searches — never started from `build`
  // ---------------------------------------------------------------------------

  Future<void> _searchZlib({bool nextPage = false}) async {
    if (_zlibStatus == AlexandriaStatus.loading || _zlibLoadingMore) {
      return;
    }
    final query = nextPage ? _zlibQuery : _searchController.text.trim();
    if (query.isEmpty) {
      _toast('请输入搜索内容');
      return;
    }
    FocusScope.of(context).unfocus();
    if (nextPage) {
      setState(() {
        _zlibPage += 1;
        _zlibLoadingMore = true;
      });
    } else {
      _lastQueries[0] = query;
      setState(() {
        _zlibQuery = query;
        _zlibBaseUrl = _source.buildZlibSearchUrl(query, filters: _filters);
        _zlibPage = 1;
        _zlibBooks = const <ZlibBook>[];
        _zlibStatus = AlexandriaStatus.loading;
        _zlibError = '';
      });
    }
    try {
      final books = nextPage
          ? await _source.loadZlibPage(_zlibBaseUrl, _zlibPage)
          : await _source.searchZlib(query, filters: _filters);
      if (!mounted) {
        return;
      }
      setState(() {
        _zlibBooks = nextPage ? <ZlibBook>[..._zlibBooks, ...books] : books;
        _zlibStatus = _zlibBooks.isEmpty
            ? AlexandriaStatus.empty
            : AlexandriaStatus.ready;
        _zlibLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _zlibLoadingMore = false;
        if (!nextPage) {
          _zlibStatus = AlexandriaStatus.error;
          _zlibError = '$error';
        }
      });
      if (nextPage) {
        _showError('加载更多失败：$error');
      }
    }
  }

  Future<void> _searchLibGen({bool nextPage = false}) async {
    if (_libGenStatus == AlexandriaStatus.loading || _libGenLoadingMore) {
      return;
    }
    final query = nextPage ? _libGenQuery : _searchController.text.trim();
    if (query.isEmpty) {
      _toast('请输入搜索内容');
      return;
    }
    FocusScope.of(context).unfocus();
    if (nextPage) {
      setState(() {
        _libGenPage += 1;
        _libGenLoadingMore = true;
      });
    } else {
      _lastQueries[1] = query;
      setState(() {
        _libGenQuery = query;
        _libGenPage = 1;
        _libGenBooks = const <LibGenBook>[];
        _libGenStatus = AlexandriaStatus.loading;
        _libGenError = '';
      });
    }
    try {
      final books = await _source.searchLibGen(
        query,
        filters: _filters,
        page: _libGenPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _libGenBooks = nextPage
            ? <LibGenBook>[..._libGenBooks, ...books]
            : books;
        _libGenStatus = _libGenBooks.isEmpty
            ? AlexandriaStatus.empty
            : AlexandriaStatus.ready;
        _libGenLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _libGenLoadingMore = false;
        if (!nextPage) {
          _libGenStatus = AlexandriaStatus.error;
          _libGenError = '$error';
        }
      });
      if (nextPage) {
        _showError('加载更多失败：$error');
      }
    }
  }

  Future<void> _searchSciHub() async {
    if (_sciHubStatus == AlexandriaStatus.loading) {
      return;
    }
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _toast('请输入 DOI、PMID 或文章链接');
      return;
    }
    FocusScope.of(context).unfocus();
    _lastQueries[2] = query;
    setState(() {
      _sciHubStatus = AlexandriaStatus.loading;
      _sciHubResult = null;
      _sciHubError = '';
    });
    try {
      final result = await _source.searchSciHub(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _sciHubResult = result;
        _sciHubStatus = result == null
            ? AlexandriaStatus.empty
            : AlexandriaStatus.ready;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sciHubStatus = AlexandriaStatus.error;
        _sciHubError = '$error';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Alexandria'),
      actions: [
        IconButton(
          tooltip: '筛选',
          icon: const Icon(Icons.tune),
          onPressed: _openFilters,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [for (final tab in _tabs) Tab(text: tab)],
      ),
    ),
    body: Column(
      children: [
        _searchBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_zlibTab(), _libGenTab(), _sciHubTab()],
          ),
        ),
      ],
    ),
  );

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: _hints[_tabIndex],
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('搜索')),
      ],
    ),
  );

  Widget _resultView({
    required AlexandriaStatus status,
    required String error,
    required String idleText,
    required String emptyText,
    required VoidCallback onRetry,
    required Widget Function() builder,
  }) => switch (status) {
    AlexandriaStatus.loading => const Center(
      child: CircularProgressIndicator(),
    ),
    AlexandriaStatus.error => AlexandriaMessageView(
      icon: Icons.error_outline,
      message: error.isEmpty ? '请求失败' : error,
      onRetry: onRetry,
    ),
    AlexandriaStatus.empty => AlexandriaMessageView(
      icon: Icons.search_off,
      message: emptyText,
    ),
    AlexandriaStatus.idle => AlexandriaMessageView(
      icon: Icons.travel_explore,
      message: idleText,
    ),
    AlexandriaStatus.ready => builder(),
  };

  Widget _zlibTab() => _resultView(
    status: _zlibStatus,
    error: _zlibError,
    idleText: '输入关键词搜索 Z-Library 图书',
    emptyText: '没有找到相关图书',
    onRetry: () => _searchZlib(),
    builder: _zlibList,
  );

  Widget _zlibList() => ListView.builder(
    controller: _zlibScroll,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    itemCount: _zlibBooks.length + (_zlibLoadingMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index >= _zlibBooks.length) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final book = _zlibBooks[index];
      final url = AlexandriaSource.zlibBookUrl(book.bookId);
      return ZlibBookCard(
        book: book,
        onOpen: () => _openUrl(url),
        onShare: () => _share(url),
      );
    },
  );

  Widget _libGenTab() => _resultView(
    status: _libGenStatus,
    error: _libGenError,
    idleText: '输入关键词搜索 Library Genesis 图书',
    emptyText: '没有找到相关图书',
    onRetry: () => _searchLibGen(),
    builder: _libGenList,
  );

  Widget _libGenList() => ListView.builder(
    controller: _libGenScroll,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    itemCount: _libGenBooks.length + (_libGenLoadingMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index >= _libGenBooks.length) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final book = _libGenBooks[index];
      return LibGenBookCard(
        book: book,
        onOpen: () => _openUrl(book.bookUrl),
        onShare: () => _share(book.bookUrl),
      );
    },
  );

  Widget _sciHubTab() => _resultView(
    status: _sciHubStatus,
    error: _sciHubError,
    idleText: '输入 DOI、PMID 或文章链接',
    emptyText: '没有找到对应的 DOI',
    onRetry: () => _searchSciHub(),
    builder: () => ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      children: [
        if (_sciHubResult != null)
          SciHubResultCard(
            result: _sciHubResult!,
            onDownload: () => _openUrl(_sciHubResult!.absoluteDownloadUrl),
            onShare: () => _share(_sciHubResult!.shareUrl),
            onOpenSource: () => _openUrl(AlexandriaSource.sciHubRoot),
          ),
      ],
    ),
  );
}
