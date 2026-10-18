import 'package:flutter/material.dart';

/// 签名过期说明（宿主 `dytt_signing_notice.dart` 同款结构）。
class DouyinSigningNotice extends StatelessWidget {
  const DouyinSigningNotice({super.key});

  static const String title = '源站签名已过期';

  static const String body =
      '源工程 flutter_app/lib/config/api.dart 把 '
      '_signature=pKb.ogAgEB9ImoSQahoqJKSm.rAAPox 写死在 /share/item/list 请求里；'
      '该值早已过期，按源工程设计发起 live 请求会收到 HTTP 403。'
      '本移植没有伪造新的签名算法，注入可用的 DouyinSignatureProvider 后才能恢复该接口。';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline, size: 18, color: colors.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
          ),
        ],
      ),
    );
  }
}
