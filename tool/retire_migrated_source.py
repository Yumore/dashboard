#!/usr/bin/env python3
"""Run the documented retirement pipeline for one already-migrated sibling source.

Steps, all of which must succeed before the next one starts:

1. Refresh the selected-project fingerprint in the migration inventory.
2. Snapshot the complete source tree (including `.git` and ignored files).
3. Verify the snapshot against the live source entry by entry.
4. Move the live source into the dated migration folder inside the system trash.
5. Verify the moved tree against the same snapshot.
6. Append a retirement receipt tied to the archiev hash and the inventory entry.

The move is a move to the trash, never a permanent delete, so a mistake is
recoverable from both the trash folder and the archive.
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PARENT = ROOT.parent
TOOL = Path(__file__).resolve().parent
INVENTORY = ROOT / 'document/loggers/content-migration-inventory.json'
RETIREMENTS = ROOT / 'document/loggers/content-migration-retirements.json'
BACKUPS = ROOT / 'document/migration_backups'


def run(*arguments, capture=True, env=None):
    result = subprocess.run([str(a) for a in arguments], capture_output=capture, text=True, env=env)
    if result.returncode != 0:
        raise SystemExit(f'command failed ({result.returncode}): {" ".join(map(str, arguments))}\n'
                         f'{result.stdout}\n{result.stderr}')
    return result.stdout.strip()


def validate_name(name):
    if not name or Path(name).name != name or name in {'.', '..', ROOT.name}:
        raise SystemExit(f'refusing: {name!r} is not a single sibling project directory name')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('name')
    parser.add_argument('--scope', required=True, help='what the host now implements from this source')
    parser.add_argument('--validation', action='append', default=[],
                        help='one verified statement; repeat for each')
    parser.add_argument('--acknowledge-dirty', action='store_true',
                        help='required when the source has uncommitted changes')
    args = parser.parse_args()

    validate_name(args.name)
    source = PARENT / args.name
    if source.is_symlink() or not source.is_dir():
        raise SystemExit(f'refusing: {source} is not a real directory')

    if not INVENTORY.exists():
        raise SystemExit('refusing: run tool/content_migration_audit.py first')
    inventory = json.loads(INVENTORY.read_text())
    matches = [e for e in inventory['projects'] if e['directory'] == args.name]
    if len(matches) != 1 or matches[0]['selection'] != 'selected':
        raise SystemExit(f'refusing: {args.name} is not exactly one selected project in the inventory')

    receipts = json.loads(RETIREMENTS.read_text()) if RETIREMENTS.exists() else []
    if any(e['directory'] == args.name for e in receipts):
        raise SystemExit(f'refusing: {args.name} already has a retirement receipt')

    dirty = run('git', '-C', source, 'status', '--porcelain', '--untracked-files=all')
    if dirty:
        print(f'note: {args.name} has uncommitted or untracked files:')
        for line in dirty.splitlines()[:20]:
            print(f'  {line}')
        if not args.acknowledge_dirty:
            raise SystemExit('refusing: pass --acknowledge-dirty after confirming those changes are in the snapshot')

    print(f'[1/6] refreshing inventory fingerprint for {args.name}')
    run(sys.executable, TOOL / 'content_migration_audit.py', '--refresh', args.name)

    try:
        head = run('git', '-C', source, 'rev-parse', 'HEAD')
    except SystemExit:
        head = 'nogit'
    revision = head[:12] if head else 'nogit'

    BACKUPS.mkdir(parents=True, exist_ok=True)
    archive = BACKUPS / f'{args.name}-{revision}.tar.gz'
    if archive.exists():
        raise SystemExit(f'refusing: archive already exists: {archive}')

    print(f'[2/6] snapshotting {source} -> {archive.relative_to(ROOT)}')
    # COPYFILE_DISABLE stops bsdtar from writing AppleDouble ._* members for
    # extended attributes; those members have no on-disk counterpart and would
    # make the archive differ from the live tree.
    environment = {**os.environ, 'COPYFILE_DISABLE': '1'}
    run('tar', '-czf', archive, '-C', PARENT, args.name, env=environment)

    print('[3/6] verifying snapshot against the live source')
    verified = run(sys.executable, TOOL / 'verify_migration_archive.py', source, archive)
    entries = json.loads(verified)['entries']

    trash_root = Path.home() / '.Trash' / f'dashboard-migration-{datetime.now().strftime("%Y%m%d")}'
    trash_root.mkdir(parents=True, exist_ok=True)
    destination = trash_root / args.name
    if destination.exists() or destination.is_symlink():
        raise SystemExit(f'refusing: trash destination already exists: {destination}')

    print(f'[4/6] moving {source} -> {destination}')
    run('mv', source, destination)

    print('[5/6] verifying the moved tree against the snapshot')
    run(sys.executable, TOOL / 'verify_migration_archive.py', destination, archive)

    print('[6/6] recording the retirement receipt')
    command = [sys.executable, TOOL / 'record_migration_retirement.py', args.name, archive, destination,
               '--scope', args.scope]
    for item in args.validation:
        command += ['--validation', item]
    print(run(*command))

    print(f'retired {args.name}: {entries} entries, archived at {archive.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
