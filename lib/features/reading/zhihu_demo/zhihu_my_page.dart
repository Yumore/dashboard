import 'package:dashboard/features/reading/zhihu_demo/zhihu_search_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_remote_image.dart';
import 'package:flutter/material.dart';

class ZhihuMyPage extends StatelessWidget {
  const ZhihuMyPage({
    required this.dark,
    required this.onToggleTheme,
    super.key,
  });

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: TextButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                Theme(data: Theme.of(context), child: const ZhihuSearchPage()),
          ),
        ),
        icon: const Icon(Icons.search),
        label: const Text('搜索知乎内容'),
      ),
    ),
    body: ListView(
      children: [
        ListTile(
          leading: const ClipOval(
            child: ZhihuRemoteImage(
              url:
                  'https://pic1.zhimg.com/v2-ec7ed574da66e1b495fcad2cc3d71cb9_xl.jpg',
              width: 40,
              height: 40,
            ),
          ),
          title: Text('learner'),
          subtitle: Text('查看或编辑个人主页'),
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [Text('57'), Text('我的创作')]),
                Column(children: [Text('210'), Text('关注')]),
                Column(children: [Text('18'), Text('我的收藏')]),
                Column(children: [Text('33'), Text('最近浏览')]),
              ],
            ),
          ),
        ),
        for (final label in const [
          '我的书架',
          '我的 Live',
          '私家课',
          '付费咨询',
          '已购',
          '余额礼卷',
          '服务',
          '社区建设',
          '反馈',
        ])
          ListTile(
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
          ),
        ListTile(
          title: Text(dark ? '日间模式' : '夜间模式'),
          trailing: const Icon(Icons.brightness_6_outlined),
          onTap: onToggleTheme,
        ),
        const ListTile(title: Text('设置'), trailing: Icon(Icons.chevron_right)),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('视频创作', style: TextStyle(fontSize: 18)),
        ),
        const ListTile(title: Text('拍一个')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ZhihuRemoteImage(
                url:
                    'https://pic2.zhimg.com/50/v2-5942a51e6b834f10074f8d50be5bbd4d_400x224.jpg',
                width: 140,
                height: 80,
              ),
              ZhihuRemoteImage(
                url:
                    'https://pic3.zhimg.com/50/v2-7fc9a1572c6fc72a3dea0b73a9be36e7_400x224.jpg',
                width: 140,
                height: 80,
              ),
              ZhihuRemoteImage(
                url:
                    'https://pic4.zhimg.com/50/v2-898f43a488b606061c877ac2a471e221_400x224.jpg',
                width: 140,
                height: 80,
              ),
              ZhihuRemoteImage(
                url:
                    'https://pic1.zhimg.com/50/v2-0008057d1ad2bd813aea4fc247959e63_400x224.jpg',
                width: 140,
                height: 80,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('想法', style: TextStyle(fontSize: 18)),
        ),
        const ListTile(title: Text('去往想法首页')),
        const ListTile(
          leading: ZhihuRemoteImage(
            url:
                'https://pic2.zhimg.com/50/v2-55039fa535f3fe06365c0fcdaa9e3847_400x224.jpg',
            width: 60,
            height: 50,
          ),
          title: Text('苹果 WWDC 2018 正在举行'),
          subtitle: Text('软件更新意料之中，硬件之谜...'),
        ),
        const ListTile(
          leading: ZhihuRemoteImage(
            url:
                'https://pic3.zhimg.com/v2-b4551f702970ff37709cdd7fd884de5e_294x245|adx4.png',
            width: 60,
            height: 50,
          ),
          title: Text('此刻你的桌子是什么样子？'),
          subtitle: Text('晒一晒你的书桌/办公桌'),
        ),
        const ListTile(
          leading: ZhihuRemoteImage(
            url:
                'https://pic2.zhimg.com/50/v2-ce2e01a047e4aba9bfabf8469cfd3e75_400x224.jpg',
            width: 60,
            height: 50,
          ),
          title: Text('关于高考你印象最深的是...'),
          subtitle: Text('聊聊你的高三生活'),
        ),
        const ListTile(
          leading: ZhihuRemoteImage(
            url:
                'https://pic1.zhimg.com/50/v2-bb3806c2ced60e5b7f38a0aa06b89511_400x224.jpg',
            width: 60,
            height: 50,
          ),
          title: Text('夏天一定要吃的食物有哪些'),
          subtitle: Text('最适合夏天吃的那种'),
        ),
      ],
    ),
  );
}
