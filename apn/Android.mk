#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

# Patched apns-conf.xml (see patch_apns.py), replaces vendor/apn's one.
include $(CLEAR_VARS)
LOCAL_MODULE := apns-conf.xml_lt03lte
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_STEM := apns-conf.xml
LOCAL_PRODUCT_MODULE := true
LOCAL_PREBUILT_MODULE_FILE := $(SOONG_OUT_DIR)/.intermediates/$(LOCAL_PATH)/apns-conf_lt03lte/gen/apns-conf.xml
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PREBUILT_MODULE_FILE)
LOCAL_OVERRIDES_MODULES := apns-conf.xml
include $(BUILD_PREBUILT)
