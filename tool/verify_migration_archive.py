#!/usr/bin/env python3
"""Verify every original file (including Git and ignored files) against a tar snapshot."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import tarfile


def digest(stream):
    result = hashlib.sha256()
    for block in iter(lambda: stream.read(1024 * 1024), b''):
        result.update(block)
    return result.hexdigest()


def tree_entries(source):
    entries = {}
    for root, directories, files in os.walk(source, followlinks=False):
        for name in directories + files:
            path = Path(root) / name
            relative = str(path.relative_to(source))
            if path.is_symlink():
                entries[relative] = ('symlink', os.readlink(path))
            elif path.is_file():
                with path.open('rb') as stream:
                    entries[relative] = ('file', digest(stream))
            elif path.is_dir():
                entries[relative] = ('directory', '')
            else:
                raise ValueError(f'Unsupported source entry: {relative}')
        directories[:] = [name for name in directories if not (Path(root) / name).is_symlink()]
    return entries


def archive_entries(archive, root_name):
    entries = {}
    with tarfile.open(archive, 'r:*') as snapshot:
        for member in snapshot:
            path = Path(member.name)
            if path.is_absolute() or '..' in path.parts or not path.parts or path.parts[0] != root_name:
                raise ValueError(f'Unexpected archive path: {member.name}')
            relative = str(Path(*path.parts[1:]))
            if relative == '.':
                continue
            if member.issym():
                entries[relative] = ('symlink', member.linkname)
            elif member.isfile():
                with snapshot.extractfile(member) as stream:
                    entries[relative] = ('file', digest(stream))
            elif member.isdir():
                entries[relative] = ('directory', '')
            else:
                raise ValueError(f'Unsupported archive entry: {member.name}')
    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('archive', type=Path)
    args = parser.parse_args()
    if args.source.is_symlink() or not args.source.is_dir():
        raise ValueError('Source must be an existing real directory')
    source = tree_entries(args.source)
    archived = archive_entries(args.archive, args.source.name)
    if source != archived:
        differences = [name for name in sorted(source.keys() | archived.keys())
                       if source.get(name) != archived.get(name)]
        raise ValueError(f'Archive mismatch: {differences[:20]}')
    with args.archive.open('rb') as stream:
        archive_hash = digest(stream)
    print(json.dumps({'source': str(args.source.resolve()), 'archive': str(args.archive.resolve()),
                      'entries': len(source), 'full_tree_verified': True,
                      'archive_sha256': archive_hash}, ensure_ascii=False))


if __name__ == '__main__':
    main()
