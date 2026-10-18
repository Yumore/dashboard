import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_text_image_widget.dart';
import 'package:flutter/material.dart';

/// `lib/pages/detail/widgets/picture_info.dart` → `PictureInfo`.
///
/// The caption block under the photo gallery: author row, description, the
/// hard-coded `'手机摄影'` category line, then the interaction counts.
class EyepetizerFlutterPictureInfoWidget extends StatelessWidget {
  const EyepetizerFlutterPictureInfoWidget({super.key, this.data});

  final EyepetizerFlutterDetail? data;

  @override
  Widget build(BuildContext context) {
    final detail = data;
    if (detail == null) return Container();
    final owner = detail.owner;
    final consumption = detail.consumption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  EyepetizerFlutterCoverImageWidget(
                    imageUrl: owner?.avatar,
                    width: 45,
                    height: 45,
                    borderRadius: 100,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        owner?.nickname ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        owner?.city ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                detail.description ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                '手机摄影',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
        const Divider(height: 0.1, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          child: Row(
            children: <Widget>[
              EyepetizerFlutterTextImageWidget(
                icon: Icons.star_outline,
                text: (consumption?.collectionCount ?? 0).toString(),
              ),
              const SizedBox(width: 15),
              EyepetizerFlutterTextImageWidget(
                icon: Icons.comment,
                text: (consumption?.replyCount ?? 0).toString(),
              ),
              const SizedBox(width: 15),
              const EyepetizerFlutterTextImageWidget(
                icon: Icons.store,
                text: '收藏',
              ),
              const Spacer(),
              const Icon(Icons.share_rounded, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
