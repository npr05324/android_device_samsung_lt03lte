#!/usr/bin/env python3
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Applies lt03lte (SM-P605S) specific SKT APN tweaks on top of the
# generated vendor/apn apns-conf.xml without touching vendor/apn.

import re
import sys

# (mcc, mnc, carrier) -> {attr: value or None to drop}
OVERRIDES = {
    ("450", "05", "SKT 3G INTERNET"): {"network_type_bitmask": "3|8|9|10|15"},
    ("450", "05", "SKT 3G Roaming"): {"network_type_bitmask": "3|8|9|10|15"},
    ("450", "05", "SKT LTE INTERNET"): {"network_type_bitmask": "13|19"},
    ("450", "05", "SKT LTE Roaming"): {"network_type_bitmask": "13|19"},
    # Samsung IMS stack (SKT APCS) registers over IPv4 "ims"
    ("450", "05", "SKT IMS"): {
        "apn": "ims",
        "protocol": "IP",
        "roaming_protocol": "IP",
        "modem_cognitive": "true",
    },
}

ATTR_RE = re.compile(r'(\w+)="([^"]*)"')


def patch(match):
    tag = match.group(0)
    attrs = dict(ATTR_RE.findall(tag))
    key = (attrs.get("mcc"), attrs.get("mnc"), attrs.get("carrier"))
    changes = OVERRIDES.get(key)
    if not changes:
        return tag
    for name, value in changes.items():
        if re.search(r'\b%s="' % name, tag):
            tag = re.sub(r'\b%s="[^"]*"' % name, '%s="%s"' % (name, value), tag)
        else:
            # keep "type" last like upstream entries
            tag = re.sub(r'(\s+type=")', ' %s="%s"\\1' % (name, value), tag, count=1)
    return tag


def main():
    src, dst = sys.argv[1], sys.argv[2]
    with open(src, encoding="utf-8") as f:
        data = f.read()
    data = re.sub(r"<apn\b[^>]*?/>", patch, data, flags=re.S)
    with open(dst, "w", encoding="utf-8") as f:
        f.write(data)


if __name__ == "__main__":
    main()
