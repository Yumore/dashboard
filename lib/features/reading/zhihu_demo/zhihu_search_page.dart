import 'package:flutter/material.dart';

class ZhihuSearchPage extends StatelessWidget {
  const ZhihuSearchPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const TextField(
        autofocus: true,
        decoration: InputDecoration.collapsed(hintText: '搜索比乎内容'),
      ),
    ),
    body: ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('比乎热搜', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('汽车关税下调')),
              Chip(label: Text('李彦宏传闻辟谣')),
              Chip(label: Text('小米8')),
              Chip(label: Text('超时空同居')),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('搜索历史', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        for (final value in const ['业余兴趣', '三体', '人类未来'])
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(value),
            trailing: const Icon(Icons.clear),
          ),
      ],
    ),
  );
}
