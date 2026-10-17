#!/usr/bin/env python3
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Rewrites calls to KitKat (Samsung) framework methods that Android 11 no longer
# has into static calls to org.lineageos.secims.Compat, which takes the original
# receiver as its first argument.
#
# usage: patch_smali.py <smali dir>...

import os
import re
import sys

COMPAT = 'Lorg/lineageos/secims/Compat;'

# (class, method + signature) -> Compat static signature
RULES = {
    ('Landroid/net/LinkProperties;', 'getAddresses()Ljava/util/Collection;'):
        'getAddresses(Landroid/net/LinkProperties;)Ljava/util/Collection;',
    ('Landroid/os/INetworkManagementService;', 'addRoute(Ljava/lang/String;Landroid/net/RouteInfo;)V'):
        'addRoute(Landroid/os/INetworkManagementService;Ljava/lang/String;Landroid/net/RouteInfo;)V',
    ('Landroid/os/INetworkManagementService;', 'replaceSrcRoute(Ljava/lang/String;[B[BI)Z'):
        'replaceSrcRoute(Landroid/os/INetworkManagementService;Ljava/lang/String;[B[BI)Z',
    ('Landroid/telephony/SmsMessage;', 'getUserDataHeader()Lcom/android/internal/telephony/SmsHeader;'):
        'getUserDataHeader(Landroid/telephony/SmsMessage;)Lcom/android/internal/telephony/SmsHeader;',
    ('Landroid/telephony/TelephonyManager;', 'getServiceState()I'):
        'getServiceState(Landroid/telephony/TelephonyManager;)I',
    ('Landroid/telephony/TelephonyManager;', 'getDataServiceState()I'):
        'getDataServiceState(Landroid/telephony/TelephonyManager;)I',
    ('Lcom/android/internal/telephony/CallManager;', 'getImsPhone()Lcom/android/internal/telephony/Phone;'):
        'getImsPhone(Lcom/android/internal/telephony/CallManager;)Lcom/android/internal/telephony/Phone;',
    ('Lcom/android/internal/telephony/ITelephony;', 'invokeOemRilRequestRaw([B)V'):
        'invokeOemRilRequestRaw(Lcom/android/internal/telephony/ITelephony;[B)V',
    ('Lcom/android/internal/telephony/Phone;', 'acceptCall()V'):
        'acceptCall(Lcom/android/internal/telephony/Phone;)V',
    ('Lcom/android/internal/telephony/gsm/GSMPhone;', 'setMmiErrorMsg(Ljava/lang/String;)V'):
        'setMmiErrorMsg(Lcom/android/internal/telephony/Phone;Ljava/lang/String;)V',
    ('Lcom/android/internal/telephony/gsm/GSMPhone;', 'getServiceState()Landroid/telephony/ServiceState;'):
        'getServiceState(Lcom/android/internal/telephony/Phone;)Landroid/telephony/ServiceState;',
}

# Samsung additions to static framework methods -> Compat method of the same signature
STATIC_RULES = {
    ('Landroid/util/Log;', 'secI(Ljava/lang/String;Ljava/lang/String;)I'),
    # Verbose/debug/info logging, silenced on user builds (see Compat.QUIET)
    ('Landroid/util/Log;', 'v(Ljava/lang/String;Ljava/lang/String;)I'),
    ('Landroid/util/Log;', 'v(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I'),
    ('Landroid/util/Log;', 'd(Ljava/lang/String;Ljava/lang/String;)I'),
    ('Landroid/util/Log;', 'd(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I'),
    ('Landroid/util/Log;', 'i(Ljava/lang/String;Ljava/lang/String;)I'),
    ('Landroid/util/Log;', 'i(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I'),
}

# KitKat classes that only changed name or package on Android 11
RENAMES = {
    'Lcom/android/internal/telephony/gsm/GSMPhone;': 'Lcom/android/internal/telephony/Phone;',
}

# Hidden framework methods looked up by name through reflection
REFLECTED_RENAMES = [
    # ContextImpl.getSharedPrefsFile() became Context.getSharedPreferencesPath() in N
    ('const-string', '"getSharedPrefsFile"', '"getSharedPreferencesPath"'),
    # LinkProperties.getDnses() became getDnsServers() (a List, still a Collection)
    ('const-string', '"getDnses"', '"getDnsServers"'),
]

# Line edits inside one method: smali file -> [(method, old line, new lines)]
METHOD_EDITS = {
    # START_NOT_STICKY services of a persistent process that dies stay queued for
    # a restart Android 11 never performs, and later start requests wait behind it.
    # Sticky restarts bring the translation services (hidden menu config, SMS) back.
    'com/sec/ims/android/translation/TranslationService.smali': [
        ('.method public final onStartCommand(Landroid/content/Intent;II)I',
         'const/4 v0, 0x2', '    const/4 v0, 0x1\n'),
    ],
    # The native stack can report a bearer registration before the spec has seen
    # the network connect (airplane mode toggles); log it like OffState instead of
    # crashing the IMS process.
    'com/sec/ims/android/sisostackadapter/spec/impl/SisoSpec$BaseSpecState.smali': [
        ('.method public notifyStackBearerRegisterAn(JLcom/samsung/rcs/enablers/RcsRatController$XANSvcType;)V',
         'throw v0',
         '    const-string v2, "SisoSpec"\n'
         '    invoke-static {v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I\n'
         '    return-void\n'),
    ],
}

# Called right after Application.onCreate() of the apps that have one
APP_ONCREATE_SUPER = 'invoke-super {p0}, Landroid/app/Application;->onCreate()V'
APP_ONCREATE_HOOK = f'    invoke-static {{p0}}, {COMPAT}->onApplicationCreate(Landroid/content/Context;)V\n'

INVOKE = re.compile(r'^(\s*)invoke-(virtual|interface|super|direct|static)(/range)? (\{[^}]*\}), (L[^;]+;)->(.+)$')


def patch_file(path, rel, counts):
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()
    changed = False
    if any(l.startswith('.super Landroid/app/Application;') for l in lines):
        for i, line in enumerate(lines):
            if line.strip() == APP_ONCREATE_SUPER:
                lines.insert(i + 1, APP_ONCREATE_HOOK)
                counts[('Application', 'onCreate hook')] = counts.get(('Application', 'onCreate hook'), 0) + 1
                changed = True
                break
    for method, old, new in METHOD_EDITS.get(rel, []):
        start = next(i for i, l in enumerate(lines) if l.strip() == method)
        end = next(i for i in range(start, len(lines)) if lines[i].strip() == '.end method')
        for i in range(start, end):
            if lines[i].strip() == old:
                lines[i] = new
                counts[('edit', rel)] = counts.get(('edit', rel), 0) + 1
                changed = True
    for i, line in enumerate(lines):
        m = INVOKE.match(line.rstrip('\n'))
        if m:
            indent, kind, rng, regs, cls, method = m.groups()
            if kind == 'static':
                target = method if (cls, method) in STATIC_RULES else None
            else:
                target = RULES.get((cls, method))
            if target:
                lines[i] = f'{indent}invoke-static{rng or ""} {regs}, {COMPAT}->{target}\n'
                counts[(cls, method)] = counts.get((cls, method), 0) + 1
                changed = True
                continue
        for op, old, new in REFLECTED_RENAMES:
            if line.lstrip().startswith(op + ' ') and line.rstrip().endswith(', ' + old):
                lines[i] = line.replace(old, new)
                counts[('reflection', old)] = counts.get(('reflection', old), 0) + 1
                changed = True
        for old, new in RENAMES.items():
            if old in lines[i]:
                lines[i] = lines[i].replace(old, new)
                changed = True
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(lines)


def main():
    counts = {}
    for root in sys.argv[1:]:
        for dirpath, _, files in os.walk(root):
            # The compat classes call the real framework methods
            if os.path.relpath(dirpath, root).startswith(os.path.join('org', 'lineageos', 'secims')):
                continue
            for name in files:
                if name.endswith('.smali'):
                    patch_file(os.path.join(dirpath, name),
                               os.path.relpath(os.path.join(dirpath, name), root), counts)
    for (cls, method), n in sorted(counts.items()):
        print(f'{n:3d} {cls}->{method}')
    missing = (set(RULES) | STATIC_RULES) - set(counts)
    for cls, method in sorted(missing):
        print(f'  0 {cls}->{method} (not referenced here)')


if __name__ == '__main__':
    main()
