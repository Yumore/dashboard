import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_basics_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_catalog_card.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_material_page.dart';
import 'package:flutter/material.dart';

/// Port of the source "Flutter UI" catalogue (source `lib/widgets/FlutterUI.dart`).
///
/// In the source this screen was the `flutterUI` named route, reached from
/// 我 → 钱包. The source printed for the twelve cards without a `routeName`;
/// only the first two opened a page, exactly as here.
class FlutterWechatCatalogPage extends StatelessWidget {
  const FlutterWechatCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: FlutterWechatPalette.appBar,
        foregroundColor: Colors.white,
        title: const Text('Flutter UI'),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        crossAxisCount: 2,
        children: <Widget>[
          FlutterWechatCatalogCard(
            title: '基础组件',
            describe: '在构建您的第一个Flutter应用程序之前，您绝对需要了解这些widget。',
            target: (_) => const FlutterWechatBasicsPage(),
          ),
          FlutterWechatCatalogCard(
            title: 'Material Components',
            describe: '实现了Material Design 指南的视觉、效果、motion-rich的widget。',
            target: (_) => const FlutterWechatMaterialPage(),
          ),
          const FlutterWechatCatalogCard(
            title: 'Cupertino(iOS风格的widget)',
            describe: '用于当前iOS设计语言的美丽和高保真widget。',
          ),
          const FlutterWechatCatalogCard(
            title: 'Layout',
            describe: '排列其它widget的columns、rows、grids和其它的layouts。',
          ),
          const FlutterWechatCatalogCard(title: 'Text', describe: '文本显示和样式'),
          const FlutterWechatCatalogCard(
            title: 'Assets、图片、Icons',
            describe: '管理assets, 显示图片和Icon。',
          ),
          const FlutterWechatCatalogCard(
            title: ' Input',
            describe: 'Material Components 和 Cupertino中获取用户输入的widget。',
          ),
          const FlutterWechatCatalogCard(
            title: '动画和Motion',
            describe: '在您的应用中使用动画。查看Flutter中的动画总览',
          ),
          const FlutterWechatCatalogCard(
            title: '交互模型',
            describe: '响应触摸事件并将用户路由到不同的页面视图（View）。',
          ),
          const FlutterWechatCatalogCard(
            title: '样式',
            describe: '管理应用的主题，使应用能够响应式的适应屏幕尺寸或添加填充。',
          ),
          const FlutterWechatCatalogCard(
            title: '绘制和效果',
            describe: 'Widget将视觉效果应用到其子组件，而不改变它们的布局、大小和位置。',
          ),
          const FlutterWechatCatalogCard(
            title: 'Async',
            describe: 'Flutter应用的异步模型',
          ),
          const FlutterWechatCatalogCard(
            title: '滚动',
            describe: '滚动一个拥有多个子组件的父组件',
          ),
          const FlutterWechatCatalogCard(
            title: '辅助功能',
            describe: '给你的App添加辅助功能(这是一个正在进行的工作)',
          ),
        ],
      ),
    );
  }
}
