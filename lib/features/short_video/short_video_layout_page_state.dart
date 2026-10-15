import 'package:dashboard/features/short_video/short_video_layout_page.dart';
import 'package:dashboard/features/short_video/short_video_music_title.dart';
import 'package:flutter/material.dart';

class ShortVideoLayoutPageState extends State<ShortVideoLayoutPage> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: const Text('短视频布局演示')),
    body: Stack(
      children: [
        PageView(
          controller: _pages,
          reverse: true,
          onPageChanged: (value) => setState(() => _index = value),
          children: [
            for (final poster in ['vides.png', 'vides2.png'])
              Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/short_video/images/$poster',
                    fit: BoxFit.contain,
                  ),
                  const Positioned(
                    bottom: 84,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@MarcoChen',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '外星人来了，你们走不走',
                          style: TextStyle(color: Colors.white),
                        ),
                        ShortVideoMusicTitle(title: '三根皮带歌曲,哗啦啦啦啦啦啦啦啦啦'),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 120,
                    child: Column(
                      children: [
                        for (final icon in [
                          'video_icon_praise.png',
                          'video_msg_icon.png',
                          'video_share_icon.png',
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.asset(
                              'assets/short_video/images/$icon',
                              width: 40,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 1; index >= 0; index--)
                TextButton(
                  onPressed: () => _pages.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                  ),
                  child: Text(
                    index == 1 ? '关注' : '推荐',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: _index == index
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 60,
            child: ColoredBox(color: Color(0x33FFFFFF)),
          ),
        ),
      ],
    ),
  );
}
