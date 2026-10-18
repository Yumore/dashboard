import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_person_main_model.dart';
import 'package:flutter/material.dart';

/// `lib/pages/mine/widgets/person_main_header_view.dart` →
/// `PersonMainHeaderView`.
///
/// The collapsing header of a person page: cover, name, brief/description,
/// the 作品/关注/粉丝 counters, the avatar (tap → photo viewer), and — only for
/// one's own page — the `编辑资料` box. The source navigated through global
/// named routes and toasted `'主题徽章'`; the port takes the two navigations as
/// callbacks and keeps the toast inline.
///
/// Deviation: the source's avatar placeholder was the bundled
/// `assets/images/ic_avatar.png`; that asset does not exist in the host app and
/// the port may not add assets, so a plain grey circle is used while loading.
class EyepetizerFlutterPersonMainHeaderView extends StatelessWidget {
  const EyepetizerFlutterPersonMainHeaderView({
    super.key,
    required this.data,
    this.isMySelf = false,
    this.onEditPressed,
    this.onAvatarPressed,
  });

  final EyepetizerFlutterPersonMainModel data;
  final bool isMySelf;
  final VoidCallback? onEditPressed;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    final userInfo = data.userInfo;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 365,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              EyepetizerFlutterCoverImageWidget(
                imageUrl: userInfo?.cover,
                width: screenWidth,
                height: 180,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              userInfo?.name ?? '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: !isMySelf,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      4,
                                      8,
                                      4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      '私信',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      4,
                                      8,
                                      4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      '+关注',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: Visibility(
                            visible: isMySelf,
                            child: InkWell(
                              onTap: onEditPressed,
                              child: Container(
                                width: 45,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black26,
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  '编辑资料',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userInfo?.brief ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userInfo?.description ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                color: Colors.grey[100],
                child: Row(
                  children: <Widget>[
                    _countColumn((userInfo?.videoCount ?? 0).toString(), '作品'),
                    _countColumn(
                      (userInfo?.myFollowCount ?? 0).toString(),
                      '关注',
                    ),
                    _countColumn((userInfo?.followCount ?? 0).toString(), '粉丝'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 15,
            top: 105,
            child: Container(
              width: screenWidth,
              height: 85,
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      InkWell(
                        onTap: onAvatarPressed,
                        child: EyepetizerFlutterCoverImageWidget(
                          imageUrl: userInfo?.icon,
                          width: 80,
                          height: 80,
                          borderRadius: 100,
                        ),
                      ),
                      const Positioned(
                        left: 55,
                        top: 55,
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: Icon(Icons.badge, size: 15),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => AppToast.show(msg: '主题徽章'),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.badge, size: 15),
                        const SizedBox(width: 2),
                        const Text(
                          '主题徽章',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text((userInfo?.medalsNum ?? 0).toString()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countColumn(String count, String label) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            count,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
