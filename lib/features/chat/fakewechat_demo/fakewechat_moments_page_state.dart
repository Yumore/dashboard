import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_comment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moment_card.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moments_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';

class FakeWechatMomentsPageState extends State<FakeWechatMomentsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  late final List<FakeWechatMoment> _moments;

  FakeWechatMoment? _commentingMoment;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _moments = FakeWechatSeedData.moments
        .map((FakeWechatMoment moment) => moment.copy())
        .toList(growable: false);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final bool next = _scrollController.offset > 250;
    if (next != _showTitle) {
      setState(() {
        _showTitle = next;
      });
    }
  }

  void _toggleLike(FakeWechatMoment moment) {
    setState(() {
      // Source `MomentItem` appends USER unconditionally on every like tap.
      moment.likes.add(FakeWechatSeedData.user);
    });
  }

  void _startComment(FakeWechatMoment moment) {
    setState(() {
      _commentingMoment = moment;
      _commentController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _commentFocusNode.requestFocus();
      }
    });
  }

  void _sendComment() {
    final FakeWechatMoment? moment = _commentingMoment;
    final String text = _commentController.text;
    if (moment == null || text.isEmpty) {
      return;
    }
    setState(() {
      moment.comments.add(FakeWechatComment(text, FakeWechatSeedData.user));
      _commentController.clear();
      _commentingMoment = null;
    });
    _commentFocusNode.unfocus();
  }

  void _showAudioUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(FakeWechatDemoConfig.audioUnavailableMessage),
      ),
    );
  }

  void _showPublishUnavailable(String source) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$source 未迁入静态演示')));
  }

  Future<void> _showAddPhotoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showPublishUnavailable('拍摄');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '拍摄',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '照片或视频',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showPublishUnavailable('从相册选择');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        '从相册选择',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildCover()),
              SliverList(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  final FakeWechatMoment moment = _moments[index];
                  return FakeWechatMomentCard(
                    moment: moment,
                    onLike: () => _toggleLike(moment),
                    onComment: () => _startComment(moment),
                    onAudioTap: _showAudioUnavailable,
                  );
                }, childCount: _moments.length),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: _showTitle ? Colors.white : Colors.transparent,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Visibility(
                    visible: _showTitle,
                    child: const Text(
                      FakeWechatDemoConfig.momentsTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: _showAddPhotoDialog,
                  ),
                ],
              ),
            ),
          ),
          if (_commentingMoment != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                elevation: 8,
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            key: const ValueKey<String>(
                              'fakewechat-moment-comment',
                            ),
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            maxLines: 3,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: '评论',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _sendComment,
                          child: const Text('发送'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF5C6BC0), Color(0xFF26A69A)],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '廖布斯',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FakeWechatAvatar(
                    name: FakeWechatSeedData.user.name,
                    size: 50,
                    borderRadius: 6,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                FakeWechatDemoConfig.profileSignature,
                style: TextStyle(fontSize: 12, color: Color(0xFF515151)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
