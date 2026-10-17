#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Samsung IMS stack from the SKT stock firmware, rebuilt for Android 11 by
# device/samsung/lt03lte/ims/build_ims.sh.

LOCAL_PATH := $(call my-dir)

# Installed only through PRODUCT_PACKAGES (device/samsung/lt03lte/ims/ims.mk)
ifneq ($(wildcard $(LOCAL_PATH)/app/secimsfw.apk),)

define secims-app
include $$(CLEAR_VARS)
LOCAL_MODULE := $(1)
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := .apk
LOCAL_SRC_FILES := app/$(1).apk
LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_TAGS := optional
include $$(BUILD_PREBUILT)
endef

define secims-lib
include $$(CLEAR_VARS)
LOCAL_MODULE := $(1)
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_SRC_FILES := lib/$(1).so
LOCAL_MULTILIB := 32
LOCAL_CHECK_ELF_FILES := false
# Stripping again breaks the patchelf-edited section layout
LOCAL_STRIP_MODULE := false
LOCAL_MODULE_TAGS := optional
include $$(BUILD_PREBUILT)
endef

$(foreach app,secimsfw commonimsservice ImsTelephonyService VolteSettings,$(eval $(call secims-app,$(app))))
$(foreach lib,libSECIMSJni libcpve-client libssl_kk libcrypto_kk,$(eval $(call secims-lib,$(lib))))

endif
