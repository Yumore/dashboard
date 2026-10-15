#!/usr/bin/env python3
"""Record an already moved source after verifying its full recovery archive."""

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path

from content_migration_audit import source_manifest
from verify_migration_archive import archive_entries, digest, tree_entries


ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / 'document/loggers/content-migration-inventory.json'
RETIREMENTS = ROOT / 'document/loggers/content-migration-retirements.json'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('name')
    parser.add_argument('archive', type=Path)
    parser.add_argument('trash', type=Path)
    parser.add_argument('--scope', required=True)
    parser.add_argument('--validation', action='append', default=[])
    args = parser.parse_args()

    if Path(args.name).name != args.name or args.name in {'.', '..', ROOT.name}:
        raise ValueError('Expected one sibling directory name')
    source = ROOT.parent / args.name
    if source.exists() or source.is_symlink():
        raise ValueError('Source still exists; move it only after migration validation')
    if args.trash.name != args.name or args.trash.is_symlink() or not args.trash.is_dir():
        raise ValueError('Expected the exact moved source directory')
    archive = args.archive.resolve(strict=True)
    if not archive.is_relative_to(ROOT / 'document/migration_backups'):
        raise ValueError('Archive must live under document/migration_backups')
    moved_tree = tree_entries(args.trash)
    if moved_tree != archive_entries(archive, args.name):
        raise ValueError('Moved source differs from full recovery archive')

    inventory = json.loads(INVENTORY.read_text())
    matches = [entry for entry in inventory['projects'] if entry['directory'] == args.name]
    if len(matches) != 1 or matches[0]['selection'] != 'selected':
        raise ValueError('Source is missing or ambiguous in the selected-project inventory')
    if matches[0]['files'] != source_manifest(args.trash):
        raise ValueError('Inventory fingerprint differs from the moved source')
    receipts = json.loads(RETIREMENTS.read_text())
    if any(entry['directory'] == args.name for entry in receipts):
        raise ValueError('Retirement is already recorded')
    with archive.open('rb') as stream:
        archive_hash = digest(stream)
    receipts.append({
        'directory': args.name,
        'status': 'retired',
        'retired_at': datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC'),
        'source_path': str(source),
        'trash_path': str(args.trash.resolve()),
        'archive': str(archive.relative_to(ROOT)),
        'archive_sha256': archive_hash,
        'verified_archive_entries': len(moved_tree),
        'scope': args.scope,
        'mapping_document': 'document/bugfixes/2026-10-13-content-module-migration.md',
        'validation': args.validation,
        'source_inventory': matches[0],
    })
    RETIREMENTS.write_text(json.dumps(receipts, ensure_ascii=False, indent=2) + '\n')
    print(f'Recorded {args.name}: {len(moved_tree)} verified entries, SHA-256 {archive_hash}')


if __name__ == '__main__':
    main()
