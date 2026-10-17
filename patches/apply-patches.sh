#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Applies lt03lte specific fixes to LineageOS source repos that cannot be
# expressed through the device tree. Safe to re-run: already applied
# patches are skipped.
#
# Usage: device/samsung/lt03lte/patches/apply-patches.sh [-r]   (-r: revert)

set -e

PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
TOP="$(cd "$PATCH_DIR/../../../.." && pwd)"
REVERT=0
[ "$1" = "-r" ] && REVERT=1

rc=0
while IFS= read -r patch; do
    rel="${patch#$PATCH_DIR/}"
    repo="$(dirname "$rel")"
    name="$(basename "$rel")"
    dir="$TOP/$repo"
    if [ ! -d "$dir" ]; then
        echo "[SKIP] $repo: directory not found"
        continue
    fi
    if [ $REVERT -eq 1 ]; then
        if git -C "$dir" apply --check -R "$patch" 2>/dev/null; then
            git -C "$dir" apply -R "$patch" && echo "[REVERTED] $repo: $name"
        else
            echo "[SKIP] $repo: $name not applied"
        fi
        continue
    fi
    if git -C "$dir" apply --check -R "$patch" 2>/dev/null; then
        echo "[OK] $repo: $name already applied"
    elif git -C "$dir" apply --check "$patch" 2>/dev/null; then
        git -C "$dir" apply "$patch" && echo "[APPLIED] $repo: $name"
    else
        echo "[FAIL] $repo: $name does not apply" >&2
        rc=1
    fi
done < <(find "$PATCH_DIR" -name '*.patch' | sort)

exit $rc
