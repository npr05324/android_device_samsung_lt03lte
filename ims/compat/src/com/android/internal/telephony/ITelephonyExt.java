/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package com.android.internal.telephony;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Message;
import android.os.RemoteException;

import org.lineageos.secims.OemRil;

/**
 * Replacement for Samsung's "phoneext" service interface. Raw RIL requests are sent
 * through the standard OEM hook (ITelephony.invokeOemRilRequestRaw).
 */
public interface ITelephonyExt extends IInterface {
    int sendRequestRawToRIL(byte[] request, Message response) throws RemoteException;

    boolean isSimFDNEnabled() throws RemoteException;

    abstract class Stub extends Binder implements ITelephonyExt {
        private static final ITelephonyExt INSTANCE = new ITelephonyExt() {
            @Override
            public int sendRequestRawToRIL(byte[] request, Message response) {
                byte[] resp = OemRil.send(request);
                if (response != null) {
                    response.obj = resp;
                    response.arg1 = resp != null ? 0 : -1;
                    response.sendToTarget();
                }
                return resp != null ? 0 : -1;
            }

            @Override
            public boolean isSimFDNEnabled() {
                return false;
            }

            @Override
            public IBinder asBinder() {
                return null;
            }
        };

        public static ITelephonyExt asInterface(IBinder binder) {
            return INSTANCE;
        }
    }
}
