import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_comment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moment.dart';
import 'package:flutter/material.dart';

/// Port of the source `MomentItem` card (`moments_page.dart`), kept as a
/// stateless card so likes/comments stay owned by the page state.
class FakeWechatMomentCard extends StatelessWidget {
  const FakeWechatMomentCard({
    super.key,
    required this.moment,
    required this.onLike,
    required this.onComment,
    required this.onAudioTap,
  });

  final FakeWechatMoment moment;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onAudioTap;

  static const Color _nameColor = Color(0xFF5D6B8F);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FakeWechatAvatar(
                name: moment.friend.name,
                size: 40,
                borderRadius: 0,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      moment.friend.name,
                      style: const TextStyle(
                        color: _nameColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (moment.text.isNotEmpty) Text(moment.text),
                    const SizedBox(height: 4),
                    _buildContent(),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            FakeWechatDemoConfig.momentsTimeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: FakeWechatDemoConfig.secondaryText,
                            ),
                          ),
                        ),
                        _buildCommentActions(),
                      ],
                    ),
                    _buildCommentSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildContent() {
    switch (moment.type) {
      case FakeWechatMoment.imageType:
        return _buildImageGrid();
      case FakeWechatMoment.webPageType:
        return _buildWebPageItem();
      case FakeWechatMoment.audioType:
        return _buildAudioItem();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: moment.images
            .map(
              (String url) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFE4E7EA),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image,
                  size: 26,
                  color: Color(0xFF9AA1A9),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildWebPageItem() {
    return Container(
      padding: const EdgeInsets.all(2),
      color: const Color(0xFFEEEEEE),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            color: const Color(0xFFD9DEE3),
            alignment: Alignment.center,
            child: const Icon(
              Icons.language,
              size: 22,
              color: Color(0xFF8A939C),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              moment.webPageLink?.title ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioItem() {
    return GestureDetector(
      onTap: onAudioTap,
      child: Container(
        color: const Color(0xFFEEEEEE),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              color: const Color(0xFFDDE3E8),
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_arrow,
                size: 26,
                color: Color(0xFF4B5B6B),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    moment.audioLink?.name ?? '',
                    style: const TextStyle(
                      color: Color(0xFF3F51B5),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    moment.audioLink?.artist ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentActions() {
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: const Color(0xFF000000),
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: onComment,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 8, 6),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.comment, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '评论',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 18, color: const Color(0xFF414141)),
            InkWell(
              onTap: onLike,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 6, 10, 6),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.comment, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '赞',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    if (moment.likes.isEmpty && moment.comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (moment.likes.isNotEmpty)
            Row(
              children: <Widget>[
                const Icon(Icons.favorite, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    moment.likes.map((friend) => friend.name).join(','),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _nameColor,
                    ),
                  ),
                ),
              ],
            ),
          if (moment.likes.isNotEmpty && moment.comments.isNotEmpty)
            const Divider(height: 1),
          ...moment.comments.map(_buildComment),
        ],
      ),
    );
  }

  Widget _buildComment(FakeWechatComment comment) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: comment.replyer == null
                ? '${comment.poster.name}: '
                : comment.poster.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: _nameColor,
            ),
          ),
          if (comment.replyer != null)
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(
                  text: '回复',
                  style: TextStyle(color: Color(0xFF6A6A6A)),
                ),
                TextSpan(
                  text: '${comment.replyer!.name}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: _nameColor,
                  ),
                ),
              ],
            ),
          TextSpan(
            text: comment.text,
            style: const TextStyle(color: Color(0xFF616161)),
          ),
        ],
      ),
    );
  }
}
