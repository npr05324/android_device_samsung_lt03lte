/*
   Copyright (c) 2013, The Linux Foundation. All rights reserved.
   Copyright (c) 2017-2021, The LineageOS Project. All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <android-base/logging.h>
#include <android-base/properties.h>

#include "init_msm8974.h"

using android::base::GetProperty;

void vendor_load_properties()
{
    std::string bootloader = GetProperty("ro.bootloader", "");

    if (bootloader.find("P605S") == 0) {
        /* lt03ltesks - SK Telecom (Korea) */
        property_override("ro.build.description", "lt03ltesks-user 5.1.1 LMY47X P605SKSU1CQB1 release-keys");
        set_ro_product_prop("device", "lt03lte");
        set_ro_product_prop("fingerprint", "samsung/lt03ltesks/lt03lte:5.1.1/LMY47X/P605SKSU1CQB1:user/release-keys");
        set_ro_product_prop("model", "SM-P605S");
        set_ro_product_prop("name", "lt03lteskt");
        gsm_properties("9", "gsm");
    } else if (bootloader.find("P605K") == 0) {
        /* lt03ltektt - KT Corp (Korea) */
        property_override("ro.build.description", "lt03ltektt-user 5.1.1 LMY47X P605KKKU1CQB1 release-keys");
        set_ro_product_prop("device", "lt03lte");
        set_ro_product_prop("fingerprint", "samsung/lt03ltektt/lt03lte:5.1.1/LMY47X/P605KKKU1CQB1:user/release-keys");
        set_ro_product_prop("model", "SM-P605K");
        set_ro_product_prop("name", "lt03ltektt");
        gsm_properties("9", "gsm");
    } else if (bootloader.find("P605L") == 0) {
        /* lt03ltelgt - LG Uplus (Korea) */
        property_override("ro.build.description", "lt03ltelgt-user 5.1.1 LMY47X P605LKLU1CQB1 release-keys");
        set_ro_product_prop("device", "lt03lte");
        set_ro_product_prop("fingerprint", "samsung/lt03ltelgt/lt03lte:5.1.1/LMY47X/P605LKLU1CQB1:user/release-keys");
        set_ro_product_prop("model", "SM-P605L");
        set_ro_product_prop("name", "lt03ltelgt");
        gsm_properties("9", "gsm");
    } else if (bootloader.find("P605M") == 0) {
        /* lt03ltecmo - Vodafone / Latin America */
        property_override("ro.build.description", "lt03ltecmo-user 4.4.2 KOT49H P605MUBUCNH1 release-keys");
        set_ro_product_prop("device", "lt03lte");
        set_ro_product_prop("fingerprint", "samsung/lt03ltecmo/lt03lte:4.4.2/KOT49H/P605MUBUCNH1:user/release-keys");
        set_ro_product_prop("model", "SM-P605M");
        set_ro_product_prop("name", "lt03ltecmo");
        gsm_properties("9", "gsm");
    } else {
        /* Default: lt03ltexx - International Snapdragon LTE */
        property_override("ro.build.description", "lt03ltexx-user 5.1.1 LMY47X P605XXU1EQG1 release-keys");
        set_ro_product_prop("device", "lt03lte");
        set_ro_product_prop("fingerprint", "samsung/lt03ltexx/lt03lte:5.1.1/LMY47X/P605XXU1EQG1:user/release-keys");
        set_ro_product_prop("model", "SM-P605");
        set_ro_product_prop("name", "lt03ltexx");
        gsm_properties("9", "gsm");
    }

    std::string device = GetProperty("ro.product.device", "");
    LOG(INFO) << "Found bootloader id " << bootloader << " setting build properties for "
              << device << " (SM-P605S / lt03lte)" << std::endl;
}
