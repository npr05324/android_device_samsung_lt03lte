#!/vendor/bin/sh
#
# Publish the modem firmware version without asking the modem.
#
# libsec-ril only learns the baseband version from MISC_ME_VERSION, which it
# follows up with factory IPCs that crash an already running modem, so libril
# answers BASEBAND_VERSION from persist.vendor.sec.baseband_version instead.
# Samsung baseband and bootloader versions share their first 8 characters
# (e.g. P605SKSU), followed by a 4 character build id.
#

prefix=$(getprop ro.boot.bootloader | cut -c1-8)
[ ${#prefix} -eq 8 ] || exit 0

version=$(grep -a -h -o -m 1 -E "${prefix}[A-Z0-9]{4}" /firmware-modem/image/modem.b* 2>/dev/null | head -n 1)
[ -n "$version" ] || exit 0

if [ "$(getprop persist.vendor.sec.baseband_version)" != "$version" ]; then
    setprop persist.vendor.sec.baseband_version "$version"
fi
