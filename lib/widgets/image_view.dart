import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  const ImageView({Key? key}) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("2333")),
      bottomNavigationBar: TextButton(
        onPressed: () => print("object"),
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: const Text("下载"),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: const AssetImage("assets/large-image.jpg"),
        ),
      ),
    );
  }
}
