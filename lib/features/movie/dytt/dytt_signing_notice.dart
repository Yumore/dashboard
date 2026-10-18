import 'package:flutter/material.dart';

/// 签名缺口的统一提示。
///
/// 只在 `DyttApi.signingSupported == false` 时展示；同一时间所有页面都
/// 停发请求，因此这个提示不是「加载失败」的兜底，而是迁移事实的说明。
class DyttSigningNotice extends StatelessWidget {
  const DyttSigningNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onErrorContainer;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: foreground),
              const SizedBox(width: 8),
              Text(
                '签名不可用',
                style: theme.textTheme.titleSmall?.copyWith(color: foreground),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '电影天堂要求每个请求携带 x-header-request-key，该值由原生库 '
            'com.bzh.dytt/key_utils.getHeaderKey() 生成。宿主没有内置 '
            'libkey-lib.so，Dart 侧无法推导，因此没有发出任何请求。'
            '为 DyttApi 注入自定义 DyttSignature 后可恢复。',
            style: theme.textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
