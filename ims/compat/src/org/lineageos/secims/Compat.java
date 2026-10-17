/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.secims;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.LinkProperties;
import android.net.RouteInfo;
import android.os.INetworkManagementService;
import android.os.Process;
import android.os.RemoteException;
import android.os.UserHandle;
import android.provider.Settings;
import android.telephony.ServiceState;
import android.telephony.SmsMessage;
import android.telephony.TelephonyManager;
import android.telecom.VideoProfile;
import android.util.Log;

import com.android.internal.telephony.CallManager;
import com.android.internal.telephony.CallStateException;
import com.android.internal.telephony.ITelephony;
import com.android.internal.telephony.Phone;
import com.android.internal.telephony.SmsHeader;

import java.net.InetAddress;
import java.util.Collection;

/**
 * Replacements for KitKat (Samsung) framework methods the IMS stack calls but
 * Android 11 no longer has. Each takes the original receiver as its first argument
 * so build_ims.sh can rewrite call sites mechanically.
 */
public final class Compat {
    private static final String TAG = "SecImsCompat";

    private Compat() {}

    // LinkProperties.getAddresses() returned Collection<InetAddress> on KitKat
    public static Collection<InetAddress> getAddresses(LinkProperties lp) {
        return lp.getAddresses();
    }

    // The data framework sets up the IMS network's routes itself on Android 11
    public static void addRoute(INetworkManagementService nms, String iface, RouteInfo route) {
        Log.d(TAG, "addRoute(" + iface + ", " + route + ") left to the data framework");
    }

    public static boolean replaceSrcRoute(INetworkManagementService nms, String iface,
            byte[] ip, byte[] gateway, int routeId) {
        Log.d(TAG, "replaceSrcRoute(" + iface + ") left to the data framework");
        return true;
    }

    public static SmsHeader getUserDataHeader(SmsMessage sms) {
        return sms.mWrappedSmsMessage != null ? sms.mWrappedSmsMessage.getUserDataHeader() : null;
    }

    // Samsung TelephonyManager returned the ServiceState state constants directly
    public static int getServiceState(TelephonyManager tm) {
        ServiceState ss = tm.getServiceState();
        return ss != null ? ss.getVoiceRegState() : ServiceState.STATE_OUT_OF_SERVICE;
    }

    public static int getDataServiceState(TelephonyManager tm) {
        ServiceState ss = tm.getServiceState();
        return ss != null ? ss.getDataRegState() : ServiceState.STATE_OUT_OF_SERVICE;
    }

    // Samsung's CallManager kept a separate IMS phone; the ImsService bridge replaces it
    public static Phone getImsPhone(CallManager cm) {
        return null;
    }

    public static void invokeOemRilRequestRaw(ITelephony telephony, byte[] request)
            throws RemoteException {
        OemRil.invoke(telephony, request);
    }

    public static void acceptCall(Phone phone) throws CallStateException {
        phone.acceptCall(VideoProfile.STATE_AUDIO_ONLY);
    }

    // GSMPhone was folded into GsmCdmaPhone; the MMI error message hook is gone
    public static void setMmiErrorMsg(Phone phone, String msg) {
        Log.d(TAG, "setMmiErrorMsg: " + msg);
    }

    public static ServiceState getServiceState(Phone phone) {
        return phone.getServiceState();
    }

    /*
     * The Samsung IMS apps log subscriber identities (MSISDN, IMPU, ICCID) at
     * verbose/debug/info level without any gating. Drop those levels on user
     * builds; warnings and errors still go through.
     */
    private static final boolean QUIET = "user".equals(android.os.Build.TYPE);

    // Samsung's Log.secI() only logged on engineering builds
    public static int secI(String tag, String msg) {
        return QUIET ? 0 : Log.i(tag, msg);
    }

    public static int v(String tag, String msg) {
        return QUIET ? 0 : Log.v(tag, msg);
    }

    public static int v(String tag, String msg, Throwable tr) {
        return QUIET ? 0 : Log.v(tag, msg, tr);
    }

    public static int d(String tag, String msg) {
        return QUIET ? 0 : Log.d(tag, msg);
    }

    public static int d(String tag, String msg, Throwable tr) {
        return QUIET ? 0 : Log.d(tag, msg, tr);
    }

    public static int i(String tag, String msg) {
        return QUIET ? 0 : Log.i(tag, msg);
    }

    public static int i(String tag, String msg, Throwable tr) {
        return QUIET ? 0 : Log.i(tag, msg, tr);
    }

    /**
     * The IMS apps target API 17, so Android 11 flags their newly granted runtime
     * permissions as needing a user review and refuses to start their services
     * until that happens. They run as the system uid and only use permissions that
     * are already granted, so mark the review as done before any service starts.
     */
    private static final String[] IMS_PACKAGES = {
        "com.sec.ims.android", "com.samsung.commonimsservice", "com.sec.ims",
        "com.sec.android.voltesettings",
    };

    /** Called right after Application.onCreate() of the IMS apps that have one. */
    public static void onApplicationCreate(Context context) {
        clearLegacyPermissionReview(context);
        if (IMS_PACKAGES[0].equals(context.getPackageName())) {
            startImsTelephonyService(context);
        }
    }

    /**
     * Samsung's telephony framework enabled VoLTE calls by default (voicecall_type 0)
     * and started the IMS telephony service, which hands VoLTE calls between the RIL
     * ("imsd" socket) and the IMS stack, in the phone process. Do both here.
     */
    private static final String VOICECALL_TYPE = "voicecall_type";

    private static void startImsTelephonyService(Context context) {
        try {
            Settings.System.getInt(context.getContentResolver(), VOICECALL_TYPE);
        } catch (Settings.SettingNotFoundException e) {
            Settings.System.putInt(context.getContentResolver(), VOICECALL_TYPE, 0);
        }
        Intent intent = new Intent().setComponent(
                new ComponentName("com.sec.ims", "com.sec.ims.ImsTelephonyService"));
        if (context.startService(intent) == null) {
            Log.e(TAG, "Unable to start the IMS telephony service");
        }
    }

    private static void clearLegacyPermissionReview(Context context) {
        for (String pkg : IMS_PACKAGES) {
            clearLegacyPermissionReview(context.getPackageManager(), pkg);
        }
    }

    private static void clearLegacyPermissionReview(PackageManager pm, String pkg) {
        final int reviewFlags = PackageManager.FLAG_PERMISSION_REVIEW_REQUIRED
                | PackageManager.FLAG_PERMISSION_REVOKED_COMPAT;
        UserHandle user = Process.myUserHandle();
        try {
            String[] requested = pm.getPackageInfo(pkg, PackageManager.GET_PERMISSIONS)
                    .requestedPermissions;
            if (requested == null) {
                return;
            }
            for (String perm : requested) {
                try {
                    if ((pm.getPermissionFlags(perm, pkg, user) & reviewFlags) != 0) {
                        pm.updatePermissionFlags(perm, pkg, reviewFlags, 0, user);
                        Log.i(TAG, "Cleared legacy permission review for " + pkg + " " + perm);
                    }
                } catch (IllegalArgumentException | SecurityException e) {
                    // Not a runtime permission
                }
            }
        } catch (PackageManager.NameNotFoundException e) {
            // That part of the IMS stack is not installed
        }
    }

}
