import 'package:carousel_slider/carousel_slider.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:flutter/material.dart';

/// The home page's carousel.
///
/// Replaces the source's `Swiper` from `flutter_swiper`
/// (`module_home/lib/widget/banner_widget.dart`), which the host does not ship;
/// `carousel_slider` is already a host dependency and is used the same way
/// (infinite autoplay, one item per viewport, 4s interval).
///
/// [autoPlay] is exposed so widget tests can freeze the carousel — an
/// autoplaying `CarouselSlider` never lets `pumpAndSettle` finish.
class EyepetizerBanner extends StatelessWidget {
  const EyepetizerBanner({
    required this.items,
    required this.onTap,
    this.autoPlay = true,
    this.height = 200,
    super.key,
  });

  final List<EyepetizerItem> items;
  final ValueChanged<EyepetizerItem> onTap;
  final bool autoPlay;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: CarouselSlider.builder(
        itemCount: items.length,
        options: CarouselOptions(
          height: height,
          viewportFraction: 1,
          autoPlay: autoPlay,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 600),
          enlargeCenterPage: false,
        ),
        itemBuilder: (context, index, realIndex) =>
            _slide(context, items[index]),
      ),
    );
  }

  Widget _slide(BuildContext context, EyepetizerItem item) {
    final data = item.data;
    if (data == null) return const SizedBox.shrink();
    final cover = data.cover;
    final url = (cover?.feed.isNotEmpty ?? false) ? cover!.feed : cover?.detail;
    return GestureDetector(
      onTap: () => onTap(item),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          EyepetizerThumbnail(url: url, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
