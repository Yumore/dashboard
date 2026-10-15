import 'package:dashboard/features/reading/zhihu_demo/zhihu_reply_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_remote_image.dart';
import 'package:flutter/material.dart';

class ZhihuQuestionPage extends StatelessWidget {
  const ZhihuQuestionPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('问题')),
    body: ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('物理学')),
              Chip(label: Text('三体(书籍)')),
              Chip(label: Text('脑洞(网络用语)')),
            ],
          ),
        ),
        const ListTile(
          title: Text('《三体》里的水滴有可能被制造出来吗?'),
          subtitle: Text(
            '如果，仅考虑其延长强相互作用力的特性，而不考虑其直角转弯的特性，那么水滴能被制造出来吗？换句话说，强相互作用力能够以影响微观物理量的方式延长吗？',
          ),
        ),
        const ListTile(title: Text('邀请回答     写回答')),
        const ListTile(title: Text('173个回答'), trailing: Text('按质量排序')),
        ListTile(
          leading: const ClipOval(
            child: ZhihuRemoteImage(
              url:
                  'https://pic3.zhimg.com/fc4c1cb34c2901a1a8c05488bbd76fa2_xs.jpg',
              width: 24,
              height: 24,
            ),
          ),
          title: const Text('游牧由'),
          subtitle: const Text(
            '第一，几年前我跟一个985211级别大学的物理类学科教授聊过这个问题。他很严肃的表示，使用强互作用力为工具在原子角度加工出这种水平的材料，对人类目前的物理...\n1K 赞同 · 262 评论 · 10 天前',
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  Theme(data: Theme.of(context), child: const ZhihuReplyPage()),
            ),
          ),
        ),
      ],
    ),
  );
}
