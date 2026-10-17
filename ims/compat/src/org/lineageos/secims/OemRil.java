/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.secims;

import android.os.RemoteException;
import android.os.ServiceManager;
import android.util.Log;

import com.android.internal.telephony.ITelephony;

import java.util.Arrays;

/** Raw OEM RIL requests for the KitKat IMS stack, over Android 11's OEM hook. */
public final class OemRil {
    private static final String TAG = "SecImsOemRil";
    private static final int MAX_RESPONSE = 2048;

    private OemRil() {}

    /** Returns the response payload, or null on failure. */
    public static byte[] send(byte[] request) {
        ITelephony telephony = ITelephony.Stub.asInterface(ServiceManager.getService("phone"));
        if (telephony == null) {
            Log.e(TAG, "phone service unavailable");
            return null;
        }
        try {
            return invoke(telephony, request);
        } catch (RemoteException e) {
            Log.e(TAG, "OEM request failed", e);
            return null;
        }
    }

    /** Replacement for the KitKat ITelephony.invokeOemRilRequestRaw(byte[]). */
    public static byte[] invoke(ITelephony telephony, byte[] request) throws RemoteException {
        byte[] resp = new byte[MAX_RESPONSE];
        int len = telephony.invokeOemRilRequestRaw(request, resp);
        if (len < 0) {
            Log.w(TAG, "OEM request returned " + len);
            return null;
        }
        return Arrays.copyOf(resp, len);
    }

    /** Matches the KitKat void signature so call sites only change their target. */
    public static void invokeVoid(ITelephony telephony, byte[] request) throws RemoteException {
        invoke(telephony, request);
    }
}
