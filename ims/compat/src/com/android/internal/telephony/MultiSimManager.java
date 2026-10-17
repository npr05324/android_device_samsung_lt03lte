/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.android.internal.telephony;

/** Samsung multi-SIM helpers; this device has a single SIM slot. */
public class MultiSimManager {
    public static int getSimSlotCount() {
        return 1;
    }

    public static String appendSimSlot(String name, int slot) {
        return slot == 0 ? name : name + slot;
    }

    public static String appendPropertySimSlot(String name, int slot) {
        return slot == 0 ? name : name + slot;
    }
}
