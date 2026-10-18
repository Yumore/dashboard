import 'package:dashboard/features/crawler/crawler_hub_body.dart';
import 'package:dashboard/features/crawler/crawler_hub_controller.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:dashboard/features/crawler/crawler_module_page.dart';
import 'package:flutter/material.dart';

class CrawlerModulePageState extends State<CrawlerModulePage> {
  final _controller = CrawlerHubController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '网页采集任务',
      body: CrawlerHubBody(controller: _controller),
    );
  }
}
