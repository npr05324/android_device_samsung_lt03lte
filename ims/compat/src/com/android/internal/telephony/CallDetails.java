/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.android.internal.telephony;

import java.util.HashMap;
import java.util.Map;

/** Subset of Samsung's CallDetails used by the IMS stack: "key=value" extras parsing. */
public class CallDetails {
    public static Map<String, String> getMapFromExtras(String[] extras, boolean lowerCaseKeys) {
        Map<String, String> map = new HashMap<>();
        if (extras == null) {
            return map;
        }
        for (String extra : extras) {
            if (extra == null) {
                continue;
            }
            int sep = extra.indexOf('=');
            if (sep <= 0) {
                continue;
            }
            String key = extra.substring(0, sep);
            map.put(lowerCaseKeys ? key.toLowerCase() : key, extra.substring(sep + 1));
        }
        return map;
    }
}
