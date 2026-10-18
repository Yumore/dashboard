import 'package:flutter/material.dart';

import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// A WeChat-style white row: optional leading icon, title, optional subtitle.
///
/// Mirrors the source `MHListTile` / `CommonItemWidget` metrics: 56 logical
/// pixels minimum height, 16dp horizontal padding, 17sp titles and the small
/// chevron taken from the bundled arrow asset.
class FlutterWechatFullListTile extends StatelessWidget {
  const FlutterWechatFullListTile({
    required this.title,
    this.icon,
    this.iconSize = 24.0,
    this.leading,
    this.subtitle,
    this.subtitleInline = false,
    this.subtitleColor = const Color(0xFF7F7F7F),
    this.titleColor = FlutterWechatFullStyle.textPrimary,
    this.titleFontSize = 17.0,
    this.trailing,
    this.showArrow = true,
    this.onTap,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.backgroundColor = Colors.white,
    this.center = false,
    this.dividerIndent,
    super.key,
  });

  final String title;
  final String? icon;
  final double iconSize;
  final Widget? leading;
  final String? subtitle;
  final bool subtitleInline;
  final Color subtitleColor;
  final Color titleColor;
  final double titleFontSize;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final bool center;
  final double? dividerIndent;

  @override
  Widget build(BuildContext context) {
    final Widget content = center
        ? Center(
            child: Text(
              title,
              style: TextStyle(fontSize: titleFontSize, color: titleColor),
            ),
          )
        : Row(
            children: <Widget>[
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16.0),
              ] else if (icon != null) ...[
                FlutterWechatFullLocalImage(
                  path: icon ?? '',
                  width: iconSize,
                  height: iconSize,
                ),
                const SizedBox(width: 16.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null && !subtitleInline) ...[
                      const SizedBox(height: 3.0),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: subtitleColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (subtitle != null && subtitleInline)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 12.0),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ?trailing,
              if (trailing == null && showArrow)
                FlutterWechatFullLocalImage(
                  path: FlutterWechatFullImages.arrow,
                  width: 8.0,
                  height: 13.0,
                ),
            ],
          );

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        highlightColor: FlutterWechatFullStyle.cellHighlight,
        splashColor: FlutterWechatFullStyle.cellHighlight,
        child: Container(
          constraints: BoxConstraints(minHeight: height ?? 56.0),
          padding: padding,
          child: content,
        ),
      ),
    );
  }
}
