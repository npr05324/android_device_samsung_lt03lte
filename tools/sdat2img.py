#!/usr/bin/env python3
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Rebuilds a raw ext4 image from a block based OTA (system.transfer.list +
# system.new.dat). Only the "new" and "erase"/"zero" commands are used by full
# OTAs.
#
# usage: sdat2img.py <transfer.list> <new.dat> <output.img>

import sys

BLOCK_SIZE = 4096


def ranges(spec):
    values = [int(v) for v in spec.split(',')]
    count, values = values[0], values[1:]
    assert count == len(values)
    return list(zip(values[0::2], values[1::2]))


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__ or 'usage: sdat2img.py <transfer.list> <new.dat> <output.img>')
    transfer_list, new_dat, output = sys.argv[1:]

    with open(transfer_list) as f:
        lines = f.read().splitlines()
    version = int(lines[0])
    commands = lines[2:] if version == 1 else lines[4:]

    new_blocks = []
    max_block = 0
    for line in commands:
        cmd, _, args = line.partition(' ')
        if cmd not in ('new', 'erase', 'zero'):
            continue
        for start, end in ranges(args):
            max_block = max(max_block, end)
            if cmd == 'new':
                new_blocks.append((start, end))

    with open(new_dat, 'rb') as src, open(output, 'wb') as dst:
        dst.truncate(max_block * BLOCK_SIZE)
        for start, end in new_blocks:
            dst.seek(start * BLOCK_SIZE)
            remaining = (end - start) * BLOCK_SIZE
            while remaining:
                chunk = src.read(min(remaining, 1 << 20))
                if not chunk:
                    sys.exit('error: new.dat ended early')
                dst.write(chunk)
                remaining -= len(chunk)


if __name__ == '__main__':
    main()
