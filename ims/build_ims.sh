#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Rebuilds the SKT stock (SM-P605S P605SKSUCQA2, Android 4.4.2) Samsung IMS stack
# for Android 11 and writes it to vendor/samsung/lt03lte/proprietary/ims:
#   - deodexes the IMS apps and commonimsinterface (baksmali 2.1.3: newer
#     releases miscompute field offsets of dalvik odex files)
#   - merges commonimsinterface and the compat classes (compat/src) into each app
#     and rewrites calls to framework methods Android 11 lacks (patch_smali.py)
#   - repoints libSECIMSJni.so at the stock OpenSSL (renamed *_kk) and at
#     libsecims_shim for the video call/media libraries
#
# APKs are left unsigned; the build signs them with the platform key.
#
# usage: build_ims.sh <stock firmware zip> <baksmali-2.1.3.jar> <smali-2.5.2.jar>
#
# Needs a built tree (out/) for the framework classes the compat code compiles
# against, plus simg2img, debugfs, patchelf and zip on the host.

set -e

STOCK_ZIP=$1
BAKSMALI=$2
SMALI=$3
[ -f "$STOCK_ZIP" ] && [ -f "$BAKSMALI" ] && [ -f "$SMALI" ] || {
    echo "usage: $0 <stock firmware zip> <baksmali-2.1.3.jar> <smali-2.5.2.jar>"
    exit 1
}

HERE=$(cd "$(dirname "$0")" && pwd)
TOP=$(cd "$HERE/../../../.." && pwd)
OUT_DIR=$TOP/vendor/samsung/lt03lte/proprietary/ims
JDK=$TOP/prebuilts/jdk/jdk11/linux-x86/bin
R8=$TOP/prebuilts/r8/r8.jar
SIMG2IMG=$TOP/out/host/linux-x86/bin/simg2img
JLIBS=$TOP/out/target/common/obj/JAVA_LIBRARIES
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

APPS="secimsfw commonimsservice ImsTelephonyService VolteSettings"
NATIVE="libSECIMSJni.so libcpve-client.so libssl.so libcrypto.so"
# Libraries libSECIMSJni.so only needs for video calls and AP-side media
STUBBED="libskia.so libcamera_client.so libstagefright.so libstagefright_omx.so libmedia.so libarcplatform.so"

echo "==> Extracting the stock system image"
unzip -p "$STOCK_ZIP" 'AP_*.tar.md5' | tar -xf - -C "$WORK" system.img.ext4
"$SIMG2IMG" "$WORK/system.img.ext4" "$WORK/system.raw"
rm "$WORK/system.img.ext4"
mkdir -p "$WORK/framework" "$WORK/app" "$WORK/lib" "$WORK/ftmp"
debugfs -R "rdump /framework $WORK/ftmp" "$WORK/system.raw" >/dev/null 2>&1
mv "$WORK"/ftmp/framework/* "$WORK/framework/"
for app in $APPS; do
    for ext in apk odex; do
        debugfs -R "dump /app/$app.$ext $WORK/app/$app.$ext" "$WORK/system.raw" >/dev/null 2>&1
    done
done
for lib in $NATIVE; do
    debugfs -R "dump /lib/$lib $WORK/lib/$lib" "$WORK/system.raw" >/dev/null 2>&1
done

echo "==> Extracting the SKT CSC feature list"
unzip -p "$STOCK_ZIP" 'CSC_*.tar.md5' | tar -xf - -C "$WORK" cache.img.ext4
"$SIMG2IMG" "$WORK/cache.img.ext4" "$WORK/cache.raw"
debugfs -R "dump /recovery/sec_csc.zip $WORK/sec_csc.zip" "$WORK/cache.raw" >/dev/null 2>&1
unzip -p "$WORK/sec_csc.zip" system/csc/feature.xml > "$WORK/csc_feature.xml"

echo "==> Deodexing"
for odex in framework/commonimsinterface.odex $(for app in $APPS; do echo app/$app.odex; done); do
    name=$(basename "$odex" .odex)
    "$JDK/java" -jar "$BAKSMALI" -a 19 -d "$WORK/framework" -x "$WORK/$odex" -o "$WORK/smali/$name"
done

echo "==> Building the compat classes"
mkdir -p "$WORK/compat/classes"
CORE=$TOP/out/soong/.intermediates/libcore/core-oj/android_common/javac/core-oj.jar
LIBART=$TOP/out/soong/.intermediates/libcore/core-libart/android_common/javac/core-libart.jar
"$JDK/javac" -nowarn -source 8 -target 8 -bootclasspath "$CORE:$LIBART" \
    -cp "$JLIBS/framework-minus-apex_intermediates/classes.jar:$JLIBS/telephony-common_intermediates/classes.jar" \
    -d "$WORK/compat/classes" $(find "$HERE/compat/src" -name '*.java')
"$JDK/java" -cp "$R8" com.android.tools.r8.D8 --min-api 19 --output "$WORK/compat" \
    $(find "$WORK/compat/classes" -name '*.class') 2>/dev/null
"$JDK/java" -jar "$BAKSMALI" -o "$WORK/smali/compat" "$WORK/compat/classes.dex"

echo "==> Patching and reassembling the apps"
mkdir -p "$OUT_DIR/app" "$OUT_DIR/lib" "$OUT_DIR/etc"
for app in $APPS; do
    src=$WORK/smali/$app
    cp -rn "$WORK/smali/commonimsinterface/." "$src/"
    cp -rn "$WORK/smali/compat/." "$src/"
    python3 "$HERE/patch_smali.py" "$src"
    "$JDK/java" -jar "$SMALI" assemble --api 19 "$src" -o "$WORK/$app.dex"
    cp "$WORK/app/$app.apk" "$WORK/$app.apk"
    zip -qd "$WORK/$app.apk" 'META-INF/*' 2>/dev/null || true
    (cd "$WORK" && cp "$app.dex" classes.dex && zip -q "$app.apk" classes.dex && rm classes.dex)
    cp "$WORK/$app.apk" "$OUT_DIR/app/$app.apk"
done

echo "==> Preparing the native libraries"
cp "$WORK/lib/libcpve-client.so" "$OUT_DIR/lib/"
cp "$WORK/lib/libcrypto.so" "$OUT_DIR/lib/libcrypto_kk.so"
cp "$WORK/lib/libssl.so" "$OUT_DIR/lib/libssl_kk.so"
cp "$WORK/lib/libSECIMSJni.so" "$OUT_DIR/lib/"
patchelf --set-soname libcrypto_kk.so "$OUT_DIR/lib/libcrypto_kk.so"
patchelf --set-soname libssl_kk.so --replace-needed libcrypto.so libcrypto_kk.so "$OUT_DIR/lib/libssl_kk.so"
patchelf --replace-needed libssl.so libssl_kk.so --replace-needed libcrypto.so libcrypto_kk.so \
    --replace-needed libgui.so libsecims_shim.so "$OUT_DIR/lib/libSECIMSJni.so"
for lib in $STUBBED; do
    patchelf --remove-needed "$lib" "$OUT_DIR/lib/libSECIMSJni.so"
done

cp "$WORK/csc_feature.xml" "$OUT_DIR/etc/csc_feature.xml"

echo "==> Done: $OUT_DIR"
ls -l "$OUT_DIR"/*
