/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.lt03lteparts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Bundle;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceFragment;

public class BatteryCareFragment extends PreferenceFragment
        implements Preference.OnPreferenceChangeListener {

    private ListPreference mLevel;

    private final BroadcastReceiver mBatteryReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            updateBatteryInfo(intent);
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getPreferenceManager().setStorageDeviceProtected();
        addPreferencesFromResource(R.xml.battery_care);

        findPreference(BatteryCare.KEY_LIMIT_ENABLE).setOnPreferenceChangeListener(this);
        mLevel = (ListPreference) findPreference(BatteryCare.KEY_LIMIT_LEVEL);
        mLevel.setOnPreferenceChangeListener(this);
        updateLevelSummary(mLevel.getValue());
    }

    @Override
    public void onResume() {
        super.onResume();
        Intent sticky = getActivity().registerReceiver(mBatteryReceiver,
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        if (sticky != null) {
            updateBatteryInfo(sticky);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        getActivity().unregisterReceiver(mBatteryReceiver);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (preference == mLevel) {
            updateLevelSummary((String) newValue);
        }
        // Apply after the new value has been persisted.
        getView().post(() -> BatteryCare.apply(getActivity()));
        return true;
    }

    private void updateLevelSummary(String value) {
        int level;
        try {
            level = Integer.parseInt(value);
        } catch (NumberFormatException | NullPointerException e) {
            level = BatteryCare.DEFAULT_LIMIT;
        }
        // ListPreference passes its summary through String.format()
        mLevel.setSummary(getString(R.string.charge_limit_level_summary,
                level, level - BatteryCare.HYSTERESIS).replace("%", "%%"));
    }

    private void updateBatteryInfo(Intent intent) {
        int soh = BatteryCare.readInt(BatteryCare.SOH_NODE);
        setSummary("battery_health", soh >= 0 ? soh + "%" : null);

        int cycles = BatteryCare.readInt(BatteryCare.CYCLE_NODE);
        setSummary("battery_cycles", cycles >= 0 ? String.valueOf(cycles) : null);

        int full = BatteryCare.readInt(BatteryCare.FULLCAP_NODE);
        int design = BatteryCare.readInt(BatteryCare.DESIGNCAP_NODE);
        setSummary("battery_capacity", full > 0 && design > 0
                ? getString(R.string.battery_capacity_summary, full, design) : null);

        int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, 100);
        setSummary("battery_level", level >= 0 ? (level * 100 / scale) + "%" : null);

        setSummary("battery_status", getString(statusString(
                intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1))));

        int temp = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Integer.MIN_VALUE);
        setSummary("battery_temp", temp != Integer.MIN_VALUE
                ? String.format("%.1f °C", temp / 10f) : null);

        int mv = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1);
        setSummary("battery_voltage", mv > 0 ? String.format("%.2f V", mv / 1000f) : null);
    }

    private static int statusString(int status) {
        switch (status) {
            case BatteryManager.BATTERY_STATUS_CHARGING:
                return R.string.status_charging;
            case BatteryManager.BATTERY_STATUS_DISCHARGING:
                return R.string.status_discharging;
            case BatteryManager.BATTERY_STATUS_NOT_CHARGING:
                return R.string.status_not_charging;
            case BatteryManager.BATTERY_STATUS_FULL:
                return R.string.status_full;
            default:
                return R.string.status_unknown;
        }
    }

    private void setSummary(String key, String summary) {
        Preference pref = findPreference(key);
        if (pref != null) {
            pref.setSummary(summary != null ? summary : getString(R.string.unavailable));
        }
    }
}
