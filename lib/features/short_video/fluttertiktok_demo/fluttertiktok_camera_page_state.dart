import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_camera_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

class FlutterTiktokCameraPageState extends State<FlutterTiktokCameraPage> {
  static const List<String> sideLabels = <String>[
    FlutterTiktokDemoConfig.cameraFlip,
    FlutterTiktokDemoConfig.cameraSpeed,
    FlutterTiktokDemoConfig.cameraFilter,
    FlutterTiktokDemoConfig.cameraBeauty,
    FlutterTiktokDemoConfig.cameraTimer,
  ];

  static const List<IconData> sideIcons = <IconData>[
    Icons.repeat,
    Icons.tonality,
    Icons.texture,
    Icons.sentiment_satisfied,
    Icons.timer,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterTiktokPalette.back1,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _sideButton(
                        FlutterTiktokDemoConfig.cameraProps,
                        const Key('fluttertiktok_camera_prop'),
                      ),
                      GestureDetector(
                        key: const Key('fluttertiktok_camera_capture'),
                        onTap: () {},
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: FlutterTiktokPalette.white.withValues(
                              alpha: 0.2,
                            ),
                            border: Border.all(
                              color: FlutterTiktokPalette.white.withValues(
                                alpha: 0.4,
                              ),
                              width: 6,
                            ),
                          ),
                        ),
                      ),
                      _sideButton(
                        FlutterTiktokDemoConfig.cameraUpload,
                        const Key('fluttertiktok_camera_upload'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: GestureDetector(
                  key: const Key('fluttertiktok_camera_close'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.clear,
                    size: FlutterTiktokPalette.iconNormal,
                    color: FlutterTiktokPalette.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: DefaultTextStyle(
                  style: FlutterTiktokPalette.normal.copyWith(
                    shadows: <Shadow>[
                      const Shadow(
                        color: Color(0x26000000),
                        offset: Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.music_note,
                        size: 14,
                        color: FlutterTiktokPalette.white,
                      ),
                      const SizedBox(width: 6),
                      Text(FlutterTiktokDemoConfig.cameraMusic),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: Opacity(
                  opacity: 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < sideLabels.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _sideTool(
                            sideIcons[i],
                            sideLabels[i],
                            Key('fluttertiktok_camera_tool_$i'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideButton(String label, Key key) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: FlutterTiktokPalette.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: FlutterTiktokPalette.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: FlutterTiktokPalette.smallWithOpacity),
        ],
      ),
    );
  }

  Widget _sideTool(IconData icon, String label, Key key) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: FlutterTiktokPalette.iconNormal,
            color: FlutterTiktokPalette.white,
          ),
          const SizedBox(height: 4),
          Text(label, style: FlutterTiktokPalette.small),
        ],
      ),
    );
  }
}
