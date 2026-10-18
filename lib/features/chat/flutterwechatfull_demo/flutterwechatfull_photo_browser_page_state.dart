import 'package:flutter/material.dart';

import 'flutterwechatfull_photo_browser_page.dart';

class FlutterWechatFullPhotoBrowserPageState
    extends State<FlutterWechatFullPhotoBrowserPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (BuildContext context, int index) {
              final String path = widget.photos[index];
              return Center(
                child: InteractiveViewer(
                  child: path.startsWith('http')
                      ? Image.network(path, fit: BoxFit.contain)
                      : Image.asset(path, fit: BoxFit.contain),
                ),
              );
            },
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${_index + 1}/${widget.photos.length}',
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
