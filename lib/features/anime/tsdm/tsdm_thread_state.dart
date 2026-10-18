import 'package:flutter/material.dart';

/// State of a thread entry shown in a forum list.
///
/// Ported from `tsdm_client/lib/shared/models/normal_thread.dart`.
enum TsdmThreadState {
  /// Closed and can not reply.
  closed(Icons.lock_outline),

  /// Up voted by another user.
  upVoted(Icons.thumb_up_outlined),

  /// Has attached pictures.
  pictureAttached(Icons.image_outlined),

  /// Marked as an essential thread.
  digested(Icons.recommend_outlined),

  /// Globally pinned across the forum.
  pinnedGlobally(Icons.looks_3_outlined),

  /// Pinned in the current thread type.
  pinnedInType(Icons.looks_two_outlined),

  /// Pinned in the current subreddit.
  pinnedInSubreddit(Icons.looks_one_outlined),

  /// Has a poll.
  poll(Icons.poll_outlined),

  /// Asks for help and provides a reward.
  rewarded(Icons.live_help_outlined),

  /// Thread in draft state, only used in the my-thread page.
  draft(Icons.drafts_outlined);

  const TsdmThreadState(this.icon);

  /// Icon of the thread state.
  final IconData icon;

  /// Parse the thread states represented by an `<img>` node.
  ///
  /// The source checks the `src` for state keywords and the `alt` attribute for
  /// `agree` / `digest` / `attach_img`. A node may hold more than one state.
  static Set<TsdmThreadState> parseFromImageNode({
    required String tagNameUpper,
    required String? src,
    required String? alt,
  }) {
    final ret = <TsdmThreadState>{};

    if (tagNameUpper != 'IMG') {
      return ret;
    }

    if (src != null) {
      if (src.contains('folder_lock')) {
        ret.add(TsdmThreadState.closed);
      } else if (src.contains('poll')) {
        ret.add(TsdmThreadState.poll);
      } else if (src.contains('reward')) {
        ret.add(TsdmThreadState.rewarded);
      } else if (src.contains('pin_3')) {
        ret.add(TsdmThreadState.pinnedGlobally);
      } else if (src.contains('pin_2')) {
        ret.add(TsdmThreadState.pinnedInType);
      } else if (src.contains('pin_1')) {
        ret.add(TsdmThreadState.pinnedInSubreddit);
      }
    }

    switch (alt) {
      case 'agree':
        ret.add(TsdmThreadState.upVoted);
      case 'digest':
        ret.add(TsdmThreadState.digested);
      case 'attach_img':
        ret.add(TsdmThreadState.pictureAttached);
    }

    return ret;
  }
}
