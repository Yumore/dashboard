import 'package:dashboard/features/live/live_hub_body.dart';
import 'package:dashboard/features/live/live_hub_controller.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:dashboard/features/live/live_module_page.dart';
import 'package:flutter/material.dart';

class LiveModulePageState extends State<LiveModulePage> {
  final _controller = LiveHubController();
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreSubscription();
  }

  Future<void> _restoreSubscription() async {
    final url = await _controller.restore();
    if (!mounted || url == null) return;
    _input.text = url;
    await _controller.load(url);
  }

  @override
  void dispose() {
    _input.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '直播订阅',
      body: LiveHubBody(controller: _controller, input: _input),
    );
  }
}
