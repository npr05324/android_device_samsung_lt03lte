#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Extracts the proprietary files listed in proprietary-files.txt into
# vendor/samsung/lt03lte and generates its makefiles (setup-makefiles.sh).
#
# usage: extract-files.sh [--no-verify] [SOURCE]
#   SOURCE omitted   pull from a device running this LineageOS build over adb
#                    (adb root, or a TWRP recovery with /system mounted)
#   SOURCE=<dir>     a directory holding the device's system/ tree, e.g. a
#                    mounted system image
#   SOURCE=<zip>     a LineageOS 18.1 OTA zip for lt03lte (block based,
#                    system.new.dat.br); unpacked with brotli + debugfs
#
# Every pinned file is checked against its sha1. The Samsung IMS stack comes
# from the stock firmware instead: ims/build_ims.sh (see README.vendor.md).

set -e

DEVICE=lt03lte
VENDOR=samsung

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_ROOT="$(cd "$MY_DIR/../../.." && pwd)"
VENDOR_DIR="$ANDROID_ROOT/vendor/$VENDOR/$DEVICE"
PROP_DIR="$VENDOR_DIR/proprietary"

VERIFY=1
if [ "$1" = "--no-verify" ]; then
    VERIFY=0
    shift
fi
SRC="${1:-adb}"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

host_tool() {
    command -v "$1" 2>/dev/null || \
        ls "$ANDROID_ROOT/out/host/linux-x86/bin/$1" 2>/dev/null || \
        { echo "error: $1 not found (build it with 'm $1' or install it)" >&2; exit 1; }
}

# OTA zip -> system image -> SRC directory
if [ -f "$SRC" ]; then
    echo "==> Unpacking $SRC"
    unzip -q -o "$SRC" system.new.dat.br system.transfer.list -d "$WORK"
    "$(host_tool brotli)" -d -o "$WORK/system.new.dat" "$WORK/system.new.dat.br"
    rm "$WORK/system.new.dat.br"
    python3 "$MY_DIR/tools/sdat2img.py" "$WORK/system.transfer.list" \
        "$WORK/system.new.dat" "$WORK/system.img"
    rm "$WORK/system.new.dat"
    mkdir -p "$WORK/root"
    debugfs -R "rdump / $WORK/root" "$WORK/system.img" >/dev/null 2>&1
    rm "$WORK/system.img"
    # system-as-root images keep the system tree under /system
    if [ -d "$WORK/root/system/vendor" ]; then
        SRC="$WORK/root"
    else
        mkdir -p "$WORK/sysroot"
        mv "$WORK/root" "$WORK/sysroot/system"
        SRC="$WORK/sysroot"
    fi
fi

if [ "$SRC" != "adb" ] && [ ! -d "$SRC/system" ]; then
    echo "error: $SRC has no system/ directory" >&2
    exit 1
fi
if [ "$SRC" = "adb" ]; then
    adb wait-for-device
fi

# Keep the IMS stack (built separately) and replace everything else
find "$PROP_DIR" -mindepth 1 -maxdepth 1 ! -name ims -exec rm -rf {} + 2>/dev/null || true
mkdir -p "$PROP_DIR"

fail=0
count=0
while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    module=0
    if [ "${line:0:1}" = "-" ]; then
        module=1
        line="${line:1}"
    fi
    entry="${line%%|*}"
    sha1=""
    [ "$entry" != "$line" ] && sha1="${line#*|}"
    dest="${entry%%:*}"
    src="${entry#*:}"
    device_path="/${dest/\$(TARGET_COPY_OUT_VENDOR)/system/vendor}"
    target="$PROP_DIR/$src"

    # Files installed twice (system/etc and vendor/etc) are extracted once
    if [ -f "$target" ]; then
        continue
    fi
    mkdir -p "$(dirname "$target")"
    if [ "$SRC" = "adb" ]; then
        adb pull "$device_path" "$target" >/dev/null 2>&1 || true
    else
        cp "$SRC$device_path" "$target" 2>/dev/null || true
    fi
    if [ ! -f "$target" ]; then
        echo "MISSING  $device_path"
        fail=1
        continue
    fi
    count=$((count + 1))
    if [ $VERIFY -eq 1 ] && [ $module -eq 0 ] && [ -n "$sha1" ]; then
        have=$(sha1sum "$target" | cut -d' ' -f1)
        if [ "$have" != "$sha1" ]; then
            echo "MISMATCH $device_path ($have != $sha1)"
            fail=1
        fi
    fi
done < "$MY_DIR/proprietary-files.txt"

echo "Extracted $count files to vendor/$VENDOR/$DEVICE/proprietary"
"$MY_DIR/setup-makefiles.sh"

if [ $fail -ne 0 ]; then
    echo "Some files are missing or differ from the pinned versions (see above)." >&2
    echo "Use --no-verify to accept different versions." >&2
    exit 1
fi
