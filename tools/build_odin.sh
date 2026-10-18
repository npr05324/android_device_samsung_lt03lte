#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Builds an Odin (BL/AP/CP/CSC/HOME_CSC) package for SM-P605S from a signed
# target-files zip.
#
#  AP       boot.img (ROM kernel), recovery.img (TWRP), system.img.ext4
#  BL       stock bootloader tar (aboot/sbl1/rpm/tz/sdi/NON-HLOS), unmodified
#  CP       stock modem tar (modem.bin), unmodified
#  CSC      clean cache.img.ext4 + /cache/recovery/command "--wipe_data"
#           (the recovery factory-resets /data on its next start)
#  HOME_CSC clean cache.img.ext4 only (keeps /data)
#
# The stock CSC is not used: its cache image makes the recovery install
# sec_csc.zip (Samsung CSC files) on top of /system.
#
# Usage: build_odin.sh <signed target_files zip> <TWRP recovery.img> \
#                      <stock firmware dir with BL_*.tar.md5 and CP_*.tar.md5> <out dir>
#   Run from the top of the tree after a build (needs out/host tools).

set -e

TARGET_FILES="$1"
TWRP_IMG="$2"
STOCK_DIR="$3"
OUT_DIR="$4"
[ -f "$TARGET_FILES" ] && [ -f "$TWRP_IMG" ] && [ -d "$STOCK_DIR" ] && [ -n "$OUT_DIR" ] || {
    echo "usage: $0 <target_files.zip> <twrp recovery.img> <stock firmware dir> <out dir>"
    exit 1
}

HERE="$(cd "$(dirname "$0")" && pwd)"
TOP="$(cd "$HERE/../../../.." && pwd)"
HOST="$TOP/out/host/linux-x86"
export PATH="$HOST/bin:$PATH" LD_LIBRARY_PATH="$HOST/lib64"

CACHE_SIZE=209715200
SYSTEM_SIZE=2566914048

STOCK_BL="$(ls "$STOCK_DIR"/BL_*.tar.md5 | head -1)"
STOCK_CP="$(ls "$STOCK_DIR"/CP_*.tar.md5 | head -1)"
[ -f "$STOCK_BL" ] && [ -f "$STOCK_CP" ] || { echo "BL_*.tar.md5 / CP_*.tar.md5 not found in $STOCK_DIR"; exit 1; }

WORK="$(mktemp -d -p "$(dirname "$(readlink -f "$OUT_DIR")")")"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$OUT_DIR"
OUT_DIR="$(readlink -f "$OUT_DIR")"

# Odin package: ustar tar with its md5 appended
make_tar_md5() {
    local name="$1"; shift
    (cd "$WORK/pkg" && tar -H ustar --owner=0 --group=0 --numeric-owner -cf "$OUT_DIR/$name.tar" "$@")
    (cd "$OUT_DIR" && md5sum -t "$name.tar" >> "$name.tar" && mv "$name.tar" "$name.tar.md5")
}

check_sparse() {
    local img="$1" size="$2"
    python3 - "$img" "$size" <<'EOF'
import struct, sys
h = open(sys.argv[1], 'rb').read(28)
magic, _, _, _, _, blk, total = struct.unpack_from('<IHHHHII', h)
assert magic == 0xed26ff3a, "not an Android sparse image"
assert blk * total == int(sys.argv[2]), "image size %d != partition size %s" % (blk * total, sys.argv[2])
EOF
}

echo "Extracting target files"
unzip -q -o "$TARGET_FILES" IMAGES/boot.img IMAGES/system.img META/file_contexts.bin -d "$WORK/tf"
check_sparse "$WORK/tf/IMAGES/system.img" $SYSTEM_SIZE

# Same date as the signed OTA (lineage_lt03lte-signed-target_files-YYYYMMDD.zip),
# otherwise the build date
DATE="$(basename "$TARGET_FILES" | grep -o -E '[0-9]{8}' | tail -1)"
if [ -z "$DATE" ]; then
    DATE="$(unzip -p "$TARGET_FILES" SYSTEM/build.prop | sed -n 's/^ro.build.date.utc=//p')"
    DATE="$(date -d "@$DATE" +%Y%m%d)"
fi
TAG="P605S_LineageOS-18.1-KNPA-GOV_$DATE"

echo "Building cache images"
mkdir -p "$WORK/cache_csc/recovery" "$WORK/cache_home"
printf -- '--wipe_data\n' > "$WORK/cache_csc/recovery/command"
chown -R 1000:2001 "$WORK/cache_csc/recovery"
chmod 0770 "$WORK/cache_csc/recovery"
for v in csc home; do
    mkuserimg_mke2fs -s "$WORK/cache_$v" "$WORK/cache_$v.img" ext4 /cache $CACHE_SIZE \
        "$WORK/tf/META/file_contexts.bin" -T 1230768000 -L cache >/dev/null
    check_sparse "$WORK/cache_$v.img" $CACHE_SIZE
done

rm -f "$OUT_DIR"/*.tar.md5
mkdir -p "$WORK/pkg"

echo "Packing AP"
ln "$WORK/tf/IMAGES/boot.img" "$WORK/pkg/boot.img"
cp "$TWRP_IMG" "$WORK/pkg/recovery.img"
ln "$WORK/tf/IMAGES/system.img" "$WORK/pkg/system.img.ext4"
make_tar_md5 "AP_$TAG" boot.img recovery.img system.img.ext4

echo "Packing CSC / HOME_CSC"
mv "$WORK/cache_csc.img" "$WORK/pkg/cache.img.ext4"
make_tar_md5 "CSC_$TAG" cache.img.ext4
mv "$WORK/cache_home.img" "$WORK/pkg/cache.img.ext4"
make_tar_md5 "HOME_CSC_$TAG" cache.img.ext4

echo "Copying stock BL / CP"
cp "$STOCK_BL" "$STOCK_CP" "$OUT_DIR/"

(cd "$OUT_DIR" && sha256sum *.tar.md5 > SHA256SUMS)
ls -l "$OUT_DIR"
