import 'package:dashboard/features/reading/zhihu_demo/zhihu_article.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_remote_image.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_reply_page.dart';
import 'package:flutter/material.dart';

class ZhihuArticleListPage extends StatelessWidget {
  const ZhihuArticleListPage({required this.follow, super.key});

  final bool follow;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: follow ? 5 : 2,
    itemBuilder: (context, index) {
      if (follow && index == 3) {
        return const Card(
          child: Column(
            children: [
              ListTile(
                leading: ClipOval(
                  child: ZhihuRemoteImage(
                    url:
                        'https://pic1.zhimg.com/50/v2-0c9de2012cc4c5e8b01657d96da35534_s.jpg',
                    width: 24,
                    height: 24,
                  ),
                ),
                title: Text('对啊网 · 考过CPA，非名牌大学也能进名企'),
                subtitle: Text('还在羡慕别人的好工作？免费领取价值1980元的注册会计师课程，为自己充电！'),
              ),
              ZhihuRemoteImage(
                url:
                    'https://pic2.zhimg.com/50/v2-6416ef6d3181117a0177275286fac8f3_hd.jpg',
                width: 300,
                height: 100,
              ),
              Padding(padding: EdgeInsets.all(8), child: Text('广告 · 查看详情')),
            ],
          ),
        );
      }
      final article = articleList[follow && index > 3 ? index - 1 : index];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  Theme(data: Theme.of(context), child: const ZhihuReplyPage()),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (follow)
                  Row(
                    children: [
                      ClipOval(
                        child: ZhihuRemoteImage(
                          url: article.headUrl,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${article.user} ${article.action} · ${article.time}',
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        follow
                            ? article.mark
                            : '${article.user} : ${article.mark}',
                        maxLines: 3,
                      ),
                    ),
                    if (article.imgUrl case final imageUrl?)
                      ZhihuRemoteImage(url: imageUrl, width: 95, height: 65),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${article.agreeNum} 赞同 · ${article.commentNum} 评论'),
                    if (follow) ...[
                      const Spacer(),
                      PopupMenuButton<String>(
                        tooltip: '更多',
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: '屏蔽', child: Text('屏蔽这个问题')),
                          PopupMenuItem(
                            value: '取消关注',
                            child: Text('取消关注 learner'),
                          ),
                          PopupMenuItem(value: '举报', child: Text('举报')),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
