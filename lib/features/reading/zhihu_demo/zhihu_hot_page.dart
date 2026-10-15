import 'package:dashboard/features/reading/zhihu_demo/zhihu_question.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_question_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_remote_image.dart';
import 'package:flutter/material.dart';

class ZhihuHotPage extends StatelessWidget {
  const ZhihuHotPage({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: questionList.length,
    itemBuilder: (context, index) {
      final question = questionList[index];
      return Card(
        child: ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Theme(
                data: Theme.of(context),
                child: const ZhihuQuestionPage(),
              ),
            ),
          ),
          leading: Text(
            question.order,
            style: TextStyle(
              color: index < 3 ? Colors.red : Colors.amber,
              fontSize: 18,
            ),
          ),
          title: Text(question.title, maxLines: 2),
          subtitle: Text(
            [
              question.rise == null ? null : '↑${question.rise}',
              question.mark,
              question.hotNum,
            ].whereType<String>().join(' · '),
          ),
          trailing: ZhihuRemoteImage(
            url: question.imgUrl,
            width: 76,
            height: 52,
          ),
        ),
      );
    },
  );
}
