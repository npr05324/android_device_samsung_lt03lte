#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Samsung IMS (VoLTE) stack, experimental. Generate the prebuilts first with
# device/samsung/lt03lte/ims/build_ims.sh; TARGET_INCLUDE_SECIMS (device.mk) selects it.

ifeq ($(TARGET_INCLUDE_SECIMS),true)

PRODUCT_PACKAGES += \
    commonimsservice \
    ImsTelephonyService \
    libcpve-client \
    libcrypto_kk \
    libSECIMSJni \
    libsecims_shim \
    libssl_kk \
    secimsfw \
    VolteSettings

# The IMS stack picks its carrier configuration (APCS server, SIP profile) by CSC sales code
PRODUCT_PROPERTY_OVERRIDES += \
    ro.csc.sales_code=SKT

# Ship (release) log level for the Samsung IMS/RIL blobs, as on stock firmware
PRODUCT_PROPERTY_OVERRIDES += \
    ro.debug_level=0x4f4c \
    ro.product_ship=true

PRODUCT_COPY_FILES += \
    vendor/samsung/lt03lte/proprietary/ims/etc/csc_feature.xml:$(TARGET_COPY_OUT_VENDOR)/etc/ims/csc_feature.xml \
    device/samsung/lt03lte/ims/privapp-permissions-secims.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-secims.xml

endif
