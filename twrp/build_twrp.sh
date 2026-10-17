#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Repacks the lt03lte TWRP image with:
#  - the current lt03lte kernel + dt.img (F2FS support, same as the ROM)
#  - static f2fs-tools (mkfs.f2fs / fsck.f2fs) built from external/f2fs-tools
#  - recovery.fstab with /data on F2FS
#
# Usage: build_twrp.sh <twrp_ramdisk_dir> <out_dir>
#   Run after: m bootimage lt03lte_twrp_mkfs.f2fs lt03lte_twrp_fsck.f2fs

set -e

RAMDISK_SRC="$1"
OUT_DIR="$2"
[ -d "$RAMDISK_SRC" ] && [ -n "$OUT_DIR" ] || { echo "usage: $0 <twrp_ramdisk_dir> <out_dir>"; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
TOP="$(cd "$HERE/../../../.." && pwd)"
PRODUCT_OUT="$TOP/out/target/product/lt03lte"
HOST_BIN="$TOP/out/host/linux-x86/bin"
F2FS_OUT="$TOP/out/soong/.intermediates/device/samsung/lt03lte/twrp/f2fs"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp -a "$RAMDISK_SRC" "$WORK/ramdisk"
install -m 0755 "$F2FS_OUT/lt03lte_twrp_mkfs.f2fs/android_arm_armv7-a-neon/lt03lte_twrp_mkfs.f2fs" "$WORK/ramdisk/sbin/mkfs.f2fs"
install -m 0755 "$F2FS_OUT/lt03lte_twrp_fsck.f2fs/android_arm_armv7-a-neon/lt03lte_twrp_fsck.f2fs" "$WORK/ramdisk/sbin/fsck.f2fs"
install -m 0644 "$HERE/recovery.fstab" "$WORK/ramdisk/etc/recovery.fstab"

(cd "$WORK/ramdisk" && find . | LC_ALL=C sort | cpio -o -H newc -R root:root --quiet) | gzip -9 > "$WORK/ramdisk.cpio.gz"

mkdir -p "$OUT_DIR"
"$HOST_BIN/mkbootimg" \
    --kernel "$PRODUCT_OUT/kernel" \
    --ramdisk "$WORK/ramdisk.cpio.gz" \
    --dt "$PRODUCT_OUT/dt.img" \
    --cmdline "console=null androidboot.hardware=qcom msm_rtb.filter=0x37 ehci-hcd.park=3" \
    --base 0x00000000 --pagesize 2048 \
    --ramdisk_offset 0x02000000 --tags_offset 0x01e00000 \
    --output "$OUT_DIR/recovery.img"

# Odin flashable package
(cd "$OUT_DIR" && tar -H ustar -cf twrp-lt03lte.tar recovery.img && md5sum -t twrp-lt03lte.tar >> twrp-lt03lte.tar && mv twrp-lt03lte.tar twrp-lt03lte.tar.md5)

ls -l "$OUT_DIR/recovery.img" "$OUT_DIR/twrp-lt03lte.tar.md5"
