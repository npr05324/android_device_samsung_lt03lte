/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.sec.android.app;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Minimal replacement for the Samsung framework class of the same name: reads the
 * carrier feature flags from the CSC feature.xml shipped with the IMS blobs.
 */
public final class CscFeature {
    private static final String TAG = "CscFeature";
    private static final String FEATURE_XML = "/vendor/etc/ims/csc_feature.xml";
    private static final Pattern ENTRY = Pattern.compile("<(CscFeature_[A-Za-z0-9_]+)>([^<]*)</\\1>");

    private static CscFeature sInstance;

    private final Map<String, String> mFeatures = new HashMap<>();

    private CscFeature() {
        try (InputStream in = new FileInputStream(FEATURE_XML)) {
            ByteArrayOutputStream buf = new ByteArrayOutputStream();
            byte[] chunk = new byte[4096];
            int n;
            while ((n = in.read(chunk)) > 0) {
                buf.write(chunk, 0, n);
            }
            String xml = buf.toString("UTF-8");
            Matcher m = ENTRY.matcher(xml);
            while (m.find()) {
                mFeatures.put(m.group(1), m.group(2).trim());
            }
        } catch (IOException e) {
            Log.e(TAG, "Unable to read " + FEATURE_XML, e);
        }
    }

    public static synchronized CscFeature getInstance() {
        if (sInstance == null) {
            sInstance = new CscFeature();
        }
        return sInstance;
    }

    public boolean getEnableStatus(String tag) {
        return "true".equalsIgnoreCase(mFeatures.get(tag));
    }

    public boolean getEnableStatus(String tag, boolean defValue) {
        String value = mFeatures.get(tag);
        return value == null ? defValue : "true".equalsIgnoreCase(value);
    }

    public String getString(String tag) {
        String value = mFeatures.get(tag);
        return value == null ? "" : value;
    }

    public int getInteger(String tag) {
        try {
            return Integer.parseInt(mFeatures.get(tag));
        } catch (NumberFormatException | NullPointerException e) {
            return -1;
        }
    }
}
