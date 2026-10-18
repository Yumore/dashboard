import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';

/// Offline presentation of the source `MessagePage`'s background layer.
///
/// Source `lib/page/wechat/message_page.dart` reveals a 小程序 panel when the
/// yellow chat sheet is dragged down: a title, a "搜索小程序" search field,
/// "最近使用" and "我的小程序" sections with the five seeded programs.
class FakeWechatMiniProgramPanel extends StatelessWidget {
  const FakeWechatMiniProgramPanel({super.key});

  IconData _iconFor(String name) {
    switch (name) {
      case '抖音':
        return Icons.play_circle_fill;
      case 'QQ音乐':
        return Icons.music_note;
      case '豆瓣':
        return Icons.movie;
      case '今日头条':
        return Icons.article;
      case '微信阅读':
        return Icons.menu_book;
      default:
        return Icons.apps;
    }
  }

  Color _colorFor(String name) {
    switch (name) {
      case '抖音':
        return const Color(0xFF161823);
      case 'QQ音乐':
        return const Color(0xFF31C27C);
      case '豆瓣':
        return const Color(0xFF2E963B);
      case '今日头条':
        return const Color(0xFFE53935);
      case '微信阅读':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF6D6D6D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FakeWechatDemoConfig.miniProgramBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                FakeWechatDemoConfig.miniProgramTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 34,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.search, color: Color(0xCCFFFFFF), size: 16),
                    SizedBox(width: 6),
                    Text(
                      FakeWechatDemoConfig.miniProgramSearchHint,
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                FakeWechatDemoConfig.recentUsedLabel,
                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 14,
                children: FakeWechatSeedData.minPrograms
                    .map(
                      (program) => SizedBox(
                        width: 58,
                        child: InkWell(
                          onTap: () {
                            final note = program.unavailableNote;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  note ??
                                      '${program.name} ${FakeWechatDemoConfig.externalPageUnavailableMessage}',
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _colorFor(program.name),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _iconFor(program.name),
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                program.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 18),
              const Text(
                FakeWechatDemoConfig.myMiniProgramsLabel,
                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
