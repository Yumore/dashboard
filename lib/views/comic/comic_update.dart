import 'package:common_utils/common_utils.dart';
import 'package:dashboard/app/api/comic.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/app/user_helper.dart';
import 'package:dashboard/app/utils.dart';
import 'package:dashboard/protobuf/comic/update_list_response.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class ComicUpdatePage extends StatefulWidget {
  const ComicUpdatePage({Key? key}) : super(key: key);

  @override
  _ComicUpdatePageState createState() => _ComicUpdatePageState();
}

class _ComicUpdatePageState extends State<ComicUpdatePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final Map _types = {
    "全部漫画": "100",
    "原创漫画": "1",
    "译制漫画": "0",
  };

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

  String _mode = "100";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            children: _types.keys
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ButtonTheme(
                      minWidth: 20,
                      height: 32,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: _types[f] == _mode
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent),
                            ),
                          ),
                          foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondary),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                              color: _types[f] == _mode
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .color),
                        ),
                        onPressed: () async {
                          _page = 1;
                          setState(() {
                            _mode = _types[f];
                          });
                          await loadData();
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: EasyRefresh(
            onRefresh: () async {
              _page = 1;
              await loadData();
            },
            onLoad: loadData,
            header: MaterialHeader(),
            footer: MaterialFooter(),
            child: ListView.builder(
                itemCount: _list.length,
                itemBuilder: (ctx, i) {
                  return createItem(_list[i]);
                }),
          ),
        )
      ],
    );
  }

  Widget createItem(ComicUpdateListItemResponse item) {
    return InkWell(
      onTap: () {
        Utils.openPage(context, item.comicId, 1);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 80,
                    child: Utils.createCacheImage(item.cover, 270, 360),
                  )),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        const WidgetSpan(
                            child: Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 18,
                        )),
                        const TextSpan(
                          text: " ",
                        ),
                        TextSpan(
                            text: item.authors,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14))
                      ]),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(item.types,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(item.lastUpdateChapterName,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                        "更新于" +
                            TimelineUtil.format(
                              int.parse(item.lastUpdatetime.toString()) * 1000,
                              locale: 'zh',
                            ),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              Center(
                child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      UserHelper.comicSubscribe(item.comicId);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<ComicUpdateListItemResponse> _list = [];
  bool _loading = false;
  int _page = 1;

  Future loadData() async {
    try {
      if (_loading) {
        return;
      }
      setState(() {
        _loading = true;
      });
      var detail = await ComicApi.instance.getUpdateList(_mode, page: _page);
      //var response =
      //    await http.get(Uri.parse(Api.comicUpdate(_mode, page: _page)));
      // List jsonMap = jsonDecode(response.body);
      // List<ComicUpdateItem> detail =
      //     jsonMap.map((i) => ComicUpdateItem.fromJson(i)).toList();
      setState(() {
        if (_page == 1) {
          _list = detail;
        } else {
          _list.addAll(detail);
        }
      });
      if (detail.isNotEmpty) {
        _page++;
      } else {
        AppToast.show(msg: "加载完毕");
      }
    } catch (e) {
      print(e);
      AppToast.show(msg: e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
