import 'package:dashboard/features/reading/zhihu_demo/zhihu_question_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_remote_image.dart';
import 'package:flutter/material.dart';

class ZhihuReplyPage extends StatelessWidget {
  const ZhihuReplyPage({super.key});

  @override
  Widget build(BuildContext context) {
    void openQuestion() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            Theme(data: Theme.of(context), child: const ZhihuQuestionPage()),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('回答')),
      body: ListView(
        children: [
          ListTile(title: const Text('你认为《三体》中最牛的文明是？'), onTap: openQuestion),
          ListTile(
            leading: const Icon(Icons.brush),
            title: const Text('查看全部10000个回答 >'),
            onTap: openQuestion,
          ),
          const ListTile(
            leading: ClipOval(
              child: ZhihuRemoteImage(
                url:
                    'https://pic3.zhimg.com/v2-cd467bb9bb31d0384f065cf0bd677930_xl.jpg',
                width: 40,
                height: 40,
              ),
            ),
            title: Text('Flutter'),
            subtitle: Text('人生如逆旅，我亦是行人'),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '回归运动\n\n三体定义的黑暗森林的宇宙格局，就是文明相互攻击和毁灭，越高级的，越明白藏好自己做好清理，绝不做探测对方文明的愚蠢行为。\n\n然而归还运动跳出了这个黑暗森林法则，不玩黑暗森林打击，不但探测别的宇宙文明，而且还深入了解对方文明，而且是全宇宙的所有文明。\n\n这是一种多么自信的科技实力呀，才能跳出黑暗森林的生存法则呀',
              style: TextStyle(height: 1.4, fontSize: 16),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('赞同 10 K    感谢    收藏    345 评论'),
        ),
      ),
    );
  }
}
