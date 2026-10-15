import 'package:dashboard/features/short_video/short_video_like_page.dart';
import 'package:flutter/material.dart';

class ShortVideoLikePageState extends State<ShortVideoLikePage> {
  Offset? _heart;
  int _animation = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('双击点赞动画')),
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTapDown: (details) => setState(() {
        _heart = details.localPosition;
        _animation++;
      }),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/short_video/images/love.jpeg', width: 100),
                const Text('双击屏幕点赞'),
              ],
            ),
          ),
          if (_heart != null)
            Positioned(
              left: _heart!.dx - 25,
              top: _heart!.dy - 25,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_animation),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                onEnd: () {
                  if (mounted) setState(() => _heart = null);
                },
                builder: (context, value, child) => Opacity(
                  opacity: 1 - value,
                  child: Transform.translate(
                    offset: Offset(0, -40 * value),
                    child: Transform.scale(
                      scale: 1.5 - 0.5 * value,
                      child: child,
                    ),
                  ),
                ),
                child: Image.asset(
                  'assets/short_video/images/love.jpeg',
                  width: 50,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
