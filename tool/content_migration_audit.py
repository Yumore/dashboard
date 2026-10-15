#!/usr/bin/env python3
"""Inventory sibling source trees without changing any source project.

The report is evidence for migration, never authorization to delete a tree.
Generated caches are excluded from source fingerprints; retirement snapshots
must still preserve the complete original tree, including Git and local files.
"""

import hashlib
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
from datetime import datetime, timezone


ROOT = Path(__file__).resolve().parents[1]
PARENT = ROOT.parent
REPORT = ROOT / 'document/loggers/content-migration-inventory.json'
RETIREMENTS = ROOT / 'document/loggers/content-migration-retirements.json'
EXCLUDED = {'.git', '.dart_tool', '.gradle', 'build', 'node_modules', 'Pods',
            '.symlinks', '.plugin_symlinks', 'ephemeral', '.idea', '.fvm', 'target'}
DOMAINS = {
    'reading': '''Alexandria book book_app Book-Flutter flutter_books FlutterEbookApp
        YeRead flutter_novel flutter_read flutter_readhub flutter_shuqi LegadoFlutter
        DoDu EasyMyGo eso FlutterTianYue YueY flutter_learn_news flutter_news
        newsbuzz zhihu-flutter'''.split(),
    'anime_comics': '''AnimeTV AnimeOne anime_trace comic_flutter comic_flutter1
        bika_comics_client haka_comic PicaComic flutter_manhuatai dmzj_flutter
        flutter_dmzj pikapi-flutter FEhViewer nhentai-cross daisy jasmine kobi
        pixez-flutter pixiv_func_mobile tsdm_client'''.split(),
    'movies_video': '''FlutterMovies Flutter-Movie MovieApp flutter-movie-app-ui
        dytt_flutter eyepetizer_flutter eyeperizer Flutter_Eyepetizer flutter_bilibili
        yyets_flutter ZY_Player_flutter Tako-Play Ghosten-Player FlutterDouBan
        FlutterCinematic morec inKino Flutter-MediaLibrary flutter_tiktok flutter_tiktok1
        douyin bilivideo_down youtube_downloader_flutter visitor-flutter
        Flutter-Project flutter_portal'''.split(),
    'chat_social': '''wechat_flutter flutterWechat flutter_WeChat flutter-wechat
        wechat-flutter fake_wechat chat_app flutter-chat-app flutter-chat-demo
        flutter_chat1 VideoCall-App-Flutter flutter-im flutter-webrtc-demo
        flutter_campus_social_app Messenger OpenFlutterYim OpenJMU
        flutter-social FlutterSocialAppUIKit Getx-PinkApp flutter-grpc-tutorial
        flutter_chat flutter_hrlweibo'''.split(),
    'live': '''easy_tv_live my_tv billd-live-flutter alltv_flutter dy_flutter
        dart_simple_live vvibe'''.split(),
    'media_plugin': '''flutter_live flutter_rtmppublisher flutter-webrtc
        FlutterTencentImPlugin flutter_tencentplayer flutter_ijkplayer fijkplayer
        chewie flutter_torrent_streamer flutter-p2p-engine
        zego-express-example-screen-capture-flutter'''.split(),
    'crawler': ['flutter_spider_fx', 'MagicMagnet'],
}
PARTIAL = {'book', 'AnimeTV', 'comic_flutter', 'flutter-movie-app-ui',
           'flutter-chat-demo', 'easy_tv_live', 'billd-live-flutter', 'flutter-im',
           'flutter_spider_fx', 'flutter_tiktok1'}
# Explicitly reviewed evidence, not a heuristic that treats every URL as private.
SKIPPED_PRIVATE = {
    'flutter-movie-app-ui': 'lib/common/constant.dart: private backend at a link-local address',
    'flutter-chat-demo': 'lib/main.dart and lib/providers/: Firebase project, authentication and Firestore required',
    'flutter-im': 'README.md: separately deployed webchat server required; no deployment supplied',
    'chat_app': 'lib/controllers/stories_controller.dart: Firebase Auth, Firestore and Storage required',
    'flutter-chat-app': 'lib/ChatScreen.dart: Firebase Auth and Realtime Database required',
    'Flutter-Movie': 'lib/actions/user_info_operate.dart and login/: Firebase Auth required',
    'newsbuzz': 'lib/globalStore.dart: Firebase Auth and Realtime Database required',
    'wechat_flutter': 'lib/im/conversation_handle.dart: Tencent V2TIM cloud service required',
    'FEhViewer': 'lib/common/global.dart: Firebase Firestore client required',
    'dy_flutter': 'lib/base.dart: media API fixed to the source developer LAN host 192.168.97.142:1236',
    'VideoCall-App-Flutter': 'pubspec.yaml and video_call_controller.dart: Agora RTC account and token required',
    'zego-express-example-screen-capture-flutter': 'lib/config/zego_config.dart: ZEGO App ID and sign required',
    'FlutterTencentImPlugin': 'lib/tencent_im_plugin.dart: business methods require Tencent IM cloud login',
    'bika_comics_client': 'lib/GlobalSettings.dart: default route uses developer-operated server',
    'Book-Flutter': 'lib/common/utils/http.dart: startup requests localhost:3002 with device details',
    'Flutter-MediaLibrary': 'lib/constants.dart: movie, book and music APIs use project-specific IP backend',
    'flutter_hrlweibo': 'lib/constant/constant.dart: app uses project-specific Weibo IP backend',
    'flutter_readhub': 'lib/data/article_repository.dart: web target uses developer LAN proxy',
    'FlutterTianYue': 'lib/app/request.dart: HTTP route targets developer LAN address',
    'YeRead': 'lib/app/request.dart: HTTP route targets developer LAN address',
    'vvibe': 'lib/config.dart: development API targets LAN and production API is blank',
    'flutter_portal': 'config/application-dev.yaml: app includes developer localhost API backend',
    'Ghosten-Player': 'lib/pages/account/account_login.dart: user-specific WebDAV server is part of account workflow',
    'Flutter-Project': 'lib/Moments/: publishing, comments and timeline call the source developer api.cleven1.com backend',
    'flutter_news': 'lib/support/di/dependency_injection.dart: notices are loaded from a project-specific IP backend',
    'flutter_WeChat': 'lib/provide/websocket.dart: messaging initializes a hard-coded source-developer WebSocket server at 111.231.225.178:3001',
}
BLOCKED_PRIVATE_DEPENDENCY = {
    'MagicMagnet': 'pubspec.yaml and README.md: private magic_magnet_engine source is not included',
}
REVIEW = {'flutter-app', 'flutterApp', 'flutter-ui-nice', 'CoordinatorLayoutExample',
          'flutter_wechat_camera_picker'}
HINT = re.compile(r'novel|anime|comic|manga|movie|cinema|chat|spider|crawler|scrap|short.?drama|直播|小说|漫画|动漫|影视|番剧|阅读|短剧|爬虫|爬取', re.I)


def run_git(directory, *args):
    result = subprocess.run(
        ['git', '-C', str(directory), *args], capture_output=True,
        env={**os.environ, 'GIT_OPTIONAL_LOCKS': '0'}, timeout=60,
    )
    return result.returncode, result.stdout.decode(errors='replace'), result.stderr.decode(errors='replace')


def git_metadata(directory):
    if not (directory / '.git').exists():
        return {'present': False}
    code, status, error = run_git(directory, 'status', '--porcelain=v1', '-z', '--untracked-files=all')
    _, head, _ = run_git(directory, 'rev-parse', 'HEAD')
    return {'present': True, 'head': head.strip(), 'status_ok': code == 0,
            'status_entries': [entry for entry in status.split('\0') if entry],
            'error': error.strip() if code else None}


def package_summary(path, source):
    text = path.read_text(errors='replace')
    def scalar(name):
        match = re.search(r'^' + name + r':\s*([^\n]*)', text, re.M)
        return match.group(1).strip() if match else None
    return {'path': str(path.relative_to(source)), 'name': scalar('name'),
            'description': scalar('description')}


def packages(directory):
    result = []
    for current, dirs, files in os.walk(directory, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUDED and not (Path(current) / d).is_symlink())
        if 'pubspec.yaml' in files:
            result.append(package_summary(Path(current) / 'pubspec.yaml', directory))
    return result


def digest_file(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def source_manifest(directory):
    result = []
    for current, dirs, files in os.walk(directory, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUDED)
        for name in sorted(files + [d for d in dirs if (Path(current) / d).is_symlink()]):
            path = Path(current) / name
            entry = {'path': str(path.relative_to(directory))}
            if path.is_symlink():
                entry.update(type='symlink', target=os.readlink(path))
            elif path.is_file():
                entry.update(type='file', bytes=path.stat().st_size, sha256=digest_file(path))
            else:
                continue
            result.append(entry)
        dirs[:] = [d for d in dirs if not (Path(current) / d).is_symlink()]
    result.sort(key=lambda entry: entry['path'])
    return result


def inspect_project(directory, domain):
    package_list = packages(directory)
    hinted = directory.name in REVIEW or any(HINT.search(p['description'] or '') for p in package_list)
    result = {'directory': directory.name, 'domain': domain,
              'inspected_at': datetime.now(timezone.utc).isoformat(),
              'selection': 'selected' if domain else ('review' if hinted else 'outside_initial_scope'),
              'packages': package_list}
    if domain:
        result['migration_status'] = 'partial' if directory.name in PARTIAL else 'not_started'
        if directory.name in SKIPPED_PRIVATE:
            result['prior_migration_status'] = result['migration_status']
            result['migration_status'] = 'skipped_private_service'
            result['skip_reason'] = SKIPPED_PRIVATE[directory.name]
        if directory.name in BLOCKED_PRIVATE_DEPENDENCY:
            result['migration_status'] = 'blocked_private_dependency'
            result['skip_reason'] = BLOCKED_PRIVATE_DEPENDENCY[directory.name]
        result['git'] = git_metadata(directory)
        result['files'] = source_manifest(directory)
        result['source_tree_sha256'] = hashlib.sha256(
            json.dumps(result['files'], ensure_ascii=False, sort_keys=True).encode()
        ).hexdigest()
        result['dart_files'] = sum(f['path'].endswith('.dart') for f in result['files'])
        result['bytes'] = sum(f.get('bytes', 0) for f in result['files'])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--refresh', nargs='+', help='Refresh only named sibling entries in an existing report')
    args = parser.parse_args()
    domains = {name: domain for domain, names in DOMAINS.items() for name in names}
    previous = {}
    if REPORT.exists():
        saved = json.loads(REPORT.read_text())
        if saved['host'] != str(ROOT) or saved['parent'] != str(PARENT):
            raise ValueError('Inventory belongs to another workspace')
        previous = {project['directory']: project for project in saved['projects']}
    if args.refresh:
        for name in args.refresh:
            if name in {'.', '..', ROOT.name} or Path(name).name != name or not (PARENT / name).is_dir():
                raise ValueError(f'Invalid sibling directory: {name}')
    projects = []
    for directory in sorted(PARENT.iterdir(), key=lambda path: path.name.lower()):
        if directory == ROOT or not directory.is_dir() or directory.is_symlink() or directory.name.startswith('.'):
            continue
        if args.refresh and directory.name in previous and directory.name not in args.refresh:
            projects.append(previous[directory.name])
        else:
            projects.append(inspect_project(directory, domains.get(directory.name)))
    active_count = len(projects)
    retirements = json.loads(RETIREMENTS.read_text()) if RETIREMENTS.exists() else []
    for receipt in retirements:
        name = receipt['directory']
        if receipt['status'] != 'retired' or Path(name).name != name or name not in domains:
            raise ValueError(f'Invalid retirement receipt: {name}')
        if (PARENT / name).exists():
            raise ValueError(f'Retired source has reappeared; review receipt: {name}')
        # Receipts retain the final inventory so full refreshes never lose history.
        project = dict(receipt['source_inventory'])
        project['migration_status'] = 'retired'
        project['retirement'] = {key: value for key, value in receipt.items() if key != 'source_inventory'}
        projects.append(project)
    selected = [project for project in projects if project['selection'] == 'selected']
    report = {'created_at': datetime.now(timezone.utc).isoformat(),
              'parent': str(PARENT), 'host': str(ROOT),
              'excluded_generated_directories': sorted(EXCLUDED),
              'retirement_allowed': False,
              'summary': {'sibling_directories': active_count, 'selected_projects': len(selected),
                          'retired_projects': len(retirements),
                          'skipped_private_projects': sum(p['migration_status'] == 'skipped_private_service' for p in selected),
                          'dart_files': sum(p['dart_files'] for p in selected),
                          'dirty_or_unreadable_git': sum(bool(p['git'].get('status_entries')) or
                              p['git'].get('status_ok') is False for p in selected)},
              'projects': projects}
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(report['summary'], ensure_ascii=False))
    print(str(REPORT))


if __name__ == '__main__':
    main()
