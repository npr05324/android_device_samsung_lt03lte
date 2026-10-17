/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.lt03lteparts;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/** Kernel (sec_battery / max17050) battery care nodes. */
public final class BatteryCare {
    private static final String TAG = "BatteryCare";

    static final String KEY_LIMIT_ENABLE = "charge_limit_enable";
    static final String KEY_LIMIT_LEVEL = "charge_limit_level";
    static final int DEFAULT_LIMIT = 80;
    /** Kernel resumes charging this many percent below the limit. */
    static final int HYSTERESIS = 5;

    private static final String LIMIT_NODE =
            "/sys/class/power_supply/battery/batt_charge_limit";
    private static final String FG = "/sys/class/power_supply/sec-fuelgauge/";
    static final String CYCLE_NODE = FG + "fg_cycle";
    static final String SOH_NODE = FG + "fg_soh";
    static final String FULLCAP_NODE = FG + "fg_fullcap_nom";
    static final String DESIGNCAP_NODE = FG + "fg_designcap";

    private BatteryCare() {}

    static SharedPreferences prefs(Context context) {
        // Device protected so the limit can be restored before unlock.
        return context.createDeviceProtectedStorageContext()
                .getSharedPreferences(context.getPackageName() + "_preferences",
                        Context.MODE_PRIVATE);
    }

    static int getLimit(Context context) {
        SharedPreferences sp = prefs(context);
        if (!sp.getBoolean(KEY_LIMIT_ENABLE, false)) {
            return 100;
        }
        try {
            return Integer.parseInt(sp.getString(KEY_LIMIT_LEVEL,
                    String.valueOf(DEFAULT_LIMIT)));
        } catch (NumberFormatException e) {
            return DEFAULT_LIMIT;
        }
    }

    static void apply(Context context) {
        int limit = getLimit(context);
        if (!writeNode(LIMIT_NODE, String.valueOf(limit))) {
            Log.e(TAG, "Failed to set charge limit " + limit);
        }
    }

    static int readInt(String path) {
        String value = readNode(path);
        if (value == null) {
            return -1;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private static String readNode(String path) {
        try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
            return reader.readLine();
        } catch (IOException e) {
            Log.w(TAG, "Failed to read " + path, e);
            return null;
        }
    }

    private static boolean writeNode(String path, String value) {
        try (FileWriter writer = new FileWriter(path)) {
            writer.write(value);
            return true;
        } catch (IOException e) {
            Log.w(TAG, "Failed to write " + path, e);
            return false;
        }
    }
}
