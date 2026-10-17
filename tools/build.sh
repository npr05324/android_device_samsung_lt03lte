#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# LineageOS 18.1 build for lt03lte (SM-P605S).
#
# usage: build.sh [userdebug|user]      (default userdebug)
#   userdebug  m bacon, test-keys flashable zip in $OUT
#   user       signed target files + block OTA signed with $KEYS
#              (default ~/.android-certs; keys are never kept in the tree)
#
# Sources that also carry the Ubuntu Touch build are switched back to their
# LineageOS revisions first (device/samsung/lt03lte_halium).

set -e

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_ROOT="$(cd "$MY_DIR/../../.." && pwd)"
VARIANT="${1:-userdebug}"
KEYS="${KEYS:-$HOME/.android-certs}"

cd "$ANDROID_ROOT"
if [ -x device/samsung/lt03lte_halium/tools/halium-switch.sh ] && [ -d hybris-patches ]; then
    device/samsung/lt03lte_halium/tools/halium-switch.sh off
fi
bash device/samsung/lt03lte/patches/apply-patches.sh

if [ ! -f vendor/samsung/lt03lte/lt03lte-vendor-blobs.mk ]; then
    echo "error: vendor/samsung/lt03lte missing, run device/samsung/lt03lte/extract-files.sh" >&2
    exit 1
fi

set +e
source build/envsetup.sh
lunch "lineage_lt03lte-$VARIANT" || exit 1
set -e

case "$VARIANT" in
userdebug|eng)
    m bacon
    ls -l "$OUT"/lineage-18.1-*-lt03lte.zip
    ;;
user)
    [ -f "$KEYS/releasekey.x509.pem" ] || { echo "error: no release keys in $KEYS" >&2; exit 1; }
    m target-files-package otatools
    TF=$(ls -t "$OUT"/obj/PACKAGING/target_files_intermediates/lineage_lt03lte-target_files-*.zip | head -1)
    STAMP=$(date +%Y%m%d)
    SIGNED_TF="$OUT/lineage_lt03lte-signed-target_files-$STAMP.zip"
    OTA="$OUT/lineage-18.1-$STAMP-RELEASE-lt03lte-signed.zip"
    sign_target_files_apks -o -d "$KEYS" "$TF" "$SIGNED_TF"
    ota_from_target_files -k "$KEYS/releasekey" --block --backup=true "$SIGNED_TF" "$OTA"
    sha256sum "$OTA" | tee "$OTA.sha256"
    ;;
*)
    echo "usage: $0 [userdebug|user]"
    exit 1
    ;;
esac
