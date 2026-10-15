import 'dart:convert';

import 'package:dashboard/app/api.dart';
import 'package:dashboard/app/user_helper.dart';
import 'package:dashboard/app/utils.dart';
import 'package:dashboard/models/comic/comic_specia_datail_model.dart';
import 'package:dashboard/views/other/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ComicSpecialDetailPage extends StatefulWidget {
  final int id;

  const ComicSpecialDetailPage(this.id, {Key? key}) : super(key: key);

  @override
  _ComicSpecialDetailPageState createState() => _ComicSpecialDetailPageState();
}

class _ComicSpecialDetailPageState extends State<ComicSpecialDetailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  ComicSpecia? _detail;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _detail != null
        ? DefaultTabController(
            length: 3, // This is the number of tabs.
            child: Scaffold(
              appBar: AppBar(
                title: Text(_detail!.title),
                actions: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => Share.share(
                          "${_detail!.title}\r\nhttp://m.dmzj.com/zhuanti/${_detail!.page_url}"))
                ],
                bottom: const TabBar(
                    tabs: [Tab(text: "介绍"), Tab(text: "漫画"), Tab(text: "评论")]),
              ),
              body: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Utils.createCacheImage(
                            _detail!.mobile_header_pic, 710, 350),
                        const SizedBox(height: 12),
                        Text(
                          _detail!.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(_detail!.description)
                      ],
                    ),
                  ),
                  ListView(
                    children: _detail!.comics
                        .map<Widget>((f) => createItem(f))
                        .toList(),
                  ),
                  CommentWidget(2, widget.id),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(),
            body: Center(
              child: _loading ? const CircularProgressIndicator() : Container(),
            ),
          );
  }

  Widget createItem(ComicSpeciaItem item) {
    return InkWell(
      onTap: () {
        Utils.openPage(context, item.id, 1);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Utils.createCacheImage(item.cover, 270, 360),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(item.recommend_brief,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    item.recommend_reason,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 3,
                  )
                ],
              ),
            ),
            Center(
              child: IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    UserHelper.comicSubscribe(item.id);
                  }),
            )
          ],
        ),
      ),
    );
  }

  bool _loading = false;

  Future loadData() async {
    try {
      if (_loading) {
        return;
      }
      setState(() {
        _loading = true;
      });
      var response =
          await http.get(Uri.parse(Api.comicSpeciaDetail(widget.id)));

      var jsonMap = jsonDecode(response.body)["data"];

      ComicSpecia detail = ComicSpecia.fromJson(jsonMap);
      if (detail.title == "") {
        setState(() {
          _loading = false;
        });
        return;
      }
      setState(() {
        _detail = detail;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
