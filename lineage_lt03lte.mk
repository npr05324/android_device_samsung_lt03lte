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

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/samsung/lt03lte/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := lt03lte
PRODUCT_NAME := lineage_lt03lte
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-P605S
PRODUCT_MANUFACTURER := samsung

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=lt03ltesks \
    TARGET_DEVICE=lt03lte \
    BUILD_FINGERPRINT=samsung/lt03ltesks/lt03lte:5.1.1/LMY47X/P605SKSU1CQB1:user/release-keys \
    PRIVATE_BUILD_DESC="lt03ltesks-user 5.1.1 LMY47X P605SKSU1CQB1 release-keys"
