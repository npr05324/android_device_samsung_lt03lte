#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from common msm8974
include device/samsung/msm8974-common/BoardConfigCommon.mk

# Android 11 Legacy Compatibility
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_OUTSIDE_INCLUDE_DIRS := true
BUILD_BROKEN_VINTF_PRODUCT_COPY_FILES := true

# Display / Lights
TARGET_PROVIDES_LIBLIGHT := true

LOCAL_PATH := device/samsung/lt03lte

TARGET_SPECIFIC_HEADER_PATH := $(LOCAL_PATH)/include

# Assert
TARGET_OTA_ASSERT_DEVICE := lt03lte,lt03lteskt,lt03ltesks,lt03ltexx,SM-P605S,SM-P605,

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8974

# Kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom user_debug=23 msm_rtb.filter=0x37 ehci-hcd.park=3 androidboot.selinux=permissive
BOARD_KERNEL_IMAGE_NAME := zImage
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_SEPARATED_DT := true
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x02000000 --tags_offset 0x01e00000
BOARD_RAMDISK_USE_XZ := true
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := hardware/samsung/mkbootimg.mk
TARGET_KERNEL_CONFIG := lineage_lt03lte_skt_defconfig
TARGET_KERNEL_SOURCE := kernel/samsung/msm8974

# Audio
AUDIO_FEATURE_LOW_LATENCY_PRIMARY := true
AUDIO_FEATURE_ENABLED_HWDEP_CAL := true
AUDIO_FEATURE_ENABLED_LOW_LATENCY_CAPTURE := true
USE_CUSTOM_AUDIO_POLICY := 1

# Bluetooth
BOARD_CUSTOM_BT_CONFIG := $(LOCAL_PATH)/bluetooth/libbt_vndcfg.txt
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(LOCAL_PATH)/bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true

# Partitions - Exact Match with Target Device Profile (MSM8974.pit)
# BOOT: LBA 245,760 ~ 268,287 (22,528 sectors @ 512B = 11,534,336 bytes = 11 MB)
BOARD_BOOTIMAGE_PARTITION_SIZE := 11534336
# RECOVERY: LBA 268,288 ~ 294,911 (26,624 sectors @ 512B = 13,631,488 bytes = 13 MB Hard Limit)
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 13631488
# SYSTEM: LBA 376,832 ~ 5,390,335 (5,013,504 sectors @ 512B = 2,566,914,048 bytes = 2,448 MB / 2.39 GB)
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2566914048
# CACHE: LBA 5,390,336 ~ 5,799,935 (409,600 sectors @ 512B = 209,715,200 bytes = 200 MB)
BOARD_CACHEIMAGE_PARTITION_SIZE := 209715200
# USERDATA: LBA 5,799,936 ~ 61,071,326 (55,271,391 sectors @ 512B = 28,298,952,192 bytes = ~26.35 GB)
BOARD_USERDATAIMAGE_PARTITION_SIZE := 28298952192
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_ROOT_EXTRA_FOLDERS := efs firmware firmware-modem persist
BOARD_ROOT_EXTRA_SYMLINKS := \
    /data/tombstones:/tombstones
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Init
TARGET_INIT_VENDOR_LIB := libinit_lt03lte

# Legacy BLOB Support
TARGET_LD_SHIM_LIBS += \
    /system/vendor/lib/hw/camera.vendor.msm8974.so|libshim_camera.so \
    /system/vendor/lib/libperipheral_client.so|libshim_binder.so

TARGET_PROCESS_SDK_VERSION_OVERRIDE += \
    /system/bin/mediaserver=22 \
    /system/vendor/bin/hw/android.hardware.sensors@1.0-service.samsung8974=22 \
    /system/vendor/bin/mm-qcamera-daemon=22 \
    /system/vendor/bin/hw/rild=27

# Properties
TARGET_SYSTEM_PROP += device/samsung/lt03lte/system.prop

# Radio
BOARD_PROVIDES_LIBRIL := true

# Recovery
TARGET_RECOVERY_DENSITY := xhdpi
TARGET_RECOVERY_FSTAB := $(LOCAL_PATH)/rootdir/etc/fstab.qcom

# WiFi
BOARD_HAVE_SAMSUNG_WIFI := true
BOARD_WLAN_DEVICE := bcmdhd
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WPA_SUPPLICANT_VERSION := VER_0_8_X
WIFI_BAND := 802_11_ABG
WIFI_DRIVER_FW_PATH_PARAM := "/sys/module/dhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA := "/vendor/etc/wifi/bcmdhd_sta.bin"
WIFI_DRIVER_FW_PATH_AP := "/vendor/etc/wifi/bcmdhd_apsta.bin"
WIFI_DRIVER_NVRAM_PATH_PARAM := "/sys/module/dhd/parameters/nvram_path"
WIFI_DRIVER_NVRAM_PATH := "/vendor/etc/wifi/nvram_net.txt"
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

# Inherit from the proprietary version
-include vendor/samsung/lt03lte/BoardConfigVendor.mk

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += device/samsung/lt03lte/sepolicy/vendor
# The msm8974 qcom legacy policy (device/qcom/sepolicy-legacy) predates the
# Android 11 neverallow set (dir/file ioctl whitelists etc.) and only builds with
# the neverallow check skipped; it already does so for userdebug. The runtime
# policy is identical and enforcing. Needs patches/system/sepolicy.
ifeq ($(TARGET_BUILD_VARIANT),user)
SELINUX_IGNORE_NEVERALLOWS := true
SELINUX_IGNORE_NEVERALLOWS_ON_USER := true
endif
