import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/widgets/horizontal_scroll_collection_card.dart` →
/// `HorizontalScrollCollectionCard`.
///
/// A titled strip of collection cards. The source used `flutter_swiper` with
/// `viewportFraction: 0.95, loop: false`; the host has no swiper package, so
/// the port uses a [PageView] with the same `viewportFraction` and no looping —
/// same geometry, one dependency less.
class EyepetizerFlutterHorizontalScrollCollectionCard extends StatelessWidget {
  const EyepetizerFlutterHorizontalScrollCollectionCard({
    super.key,
    required this.data,
  });

  final EyepetizerFlutterItem data;

  @override
  Widget build(BuildContext context) {
    final content = data.data;
    final banners = content?.itemList ?? const <EyepetizerFlutterItemBanner>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          height: 50,
          alignment: Alignment.centerLeft,
          child: Text(
            content?.header?.title ?? '',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 260,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.95),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index].data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 200,
                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: EyepetizerFlutterCoverImageWidget(
                      imageUrl: banner?.image,
                      width: double.infinity,
                      borderRadius: 3,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 5, 0),
                    child: Row(
                      children: <Widget>[
                        EyepetizerFlutterCoverImageWidget(
                          imageUrl: banner?.icon,
                          width: 50,
                          height: 50,
                          borderRadius: 100,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                banner?.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                banner?.description ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.share_rounded),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
