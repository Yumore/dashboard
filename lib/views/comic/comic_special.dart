import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dmzj/app/api.dart';
import 'package:flutter_dmzj/app/utils.dart';
import 'package:flutter_dmzj/models/comic/comic_special_item.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ComicSpecialPage extends StatefulWidget {
  ComicSpecialPage({Key? key}) : super(key: key);

  @override
  _ComicSpecialPageState createState() => _ComicSpecialPageState();
}

class _ComicSpecialPageState extends State<ComicSpecialPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  double getWidth() {
    var count = MediaQuery.of(context).size.width ~/ 400;
    if (count < 1) count = 1;
    return (MediaQuery.of(context).size.width - count * 8) / count - 8;
  }

  List<ComicSpecialItem> _list = [];
  bool _loading = false;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EasyRefresh(
      onRefresh: () async {
        _page = 0;
        await loadData();
      },
      header: MaterialHeader(),
      footer: MaterialFooter(),
      onLoad: loadData,
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 400 < 1 ? 1 : MediaQuery.of(context).size.width ~/ 400,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: getWidth() / ((getWidth() * (280 / 710)) + 44)),
          itemCount: _list.length,
          itemBuilder: (cxt, i) {
            var f = _list[i];
            return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Card(
                  child: RawMaterialButton(
                    onPressed: () {
                      Utils.openPage(context, f.id!, 5);
                    },
                    child: Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Utils.createCacheImage(f.small_cover!, 710, 280),
                            SizedBox(height: 4),
                            Flexible(
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text(f.title!)),
                                  Text(
                                    DateUtil.formatDate(DateTime.fromMillisecondsSinceEpoch(f.create_time! * 1000), format: "yyyy-MM-dd"),
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ));
          }),
    );
  }

  Future loadData() async {
    try {
      if (_loading) {
        return;
      }
      setState(() {
        _loading = true;
      });
      var response = await http.get(Uri.parse(Api.comicSpecial(page: _page)));
      List jsonMap = jsonDecode(response.body)["data"];
      List<ComicSpecialItem> detail = jsonMap.map((i) => ComicSpecialItem.fromJson(i)).toList();
      if (detail != null) {
        setState(() {
          if (_page == 0) {
            _list = detail;
          } else {
            _list.addAll(detail);
          }
        });
        if (detail.length != 0) {
          _page++;
        } else {
          Fluttertoast.showToast(msg: "加载完毕");
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
