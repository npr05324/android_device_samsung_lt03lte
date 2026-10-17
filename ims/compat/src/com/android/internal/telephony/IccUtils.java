/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.android.internal.telephony;

/** KitKat location of IccUtils; forwards to the Android 11 implementation. */
public class IccUtils {
    public static byte[] hexStringToBytes(String s) {
        return com.android.internal.telephony.uicc.IccUtils.hexStringToBytes(s);
    }
}
