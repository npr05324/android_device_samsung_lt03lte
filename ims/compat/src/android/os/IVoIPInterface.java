/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package android.os;

/** Samsung "voip" service stub: no third-party VoIP call tracking on LineageOS. */
public interface IVoIPInterface extends IInterface {
    boolean isVoIPActivated() throws RemoteException;

    abstract class Stub extends Binder implements IVoIPInterface {
        private static final IVoIPInterface NONE = new IVoIPInterface() {
            @Override
            public boolean isVoIPActivated() {
                return false;
            }

            @Override
            public IBinder asBinder() {
                return null;
            }
        };

        public static IVoIPInterface asInterface(IBinder binder) {
            return NONE;
        }
    }
}
