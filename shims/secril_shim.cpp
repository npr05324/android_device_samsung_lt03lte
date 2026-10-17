/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "SECRIL_SHIM"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <utils/Log.h>

extern "C" {

/**
 * strlen8to16: UTF-8 string to UTF-16 character count
 */
size_t strlen8to16(const char* utf8Str) {
    if (!utf8Str) return 0;
    size_t len = 0;
    const uint8_t* p = reinterpret_cast<const uint8_t*>(utf8Str);
    while (*p) {
        uint8_t c = *p++;
        if ((c & 0x80) == 0) {
            len++;
        } else if ((c & 0xE0) == 0xC0) {
            len++;
            if (*p) p++;
        } else if ((c & 0xF0) == 0xE0) {
            len++;
            if (*p) p++;
            if (*p) p++;
        } else if ((c & 0xF8) == 0xF0) {
            len += 2; // UTF-16 surrogate pair
            if (*p) p++;
            if (*p) p++;
            if (*p) p++;
        }
    }
    return len;
}

/**
 * strcpy8to16: converts UTF-8 string to UTF-16 and null-terminates
 */
char16_t* strcpy8to16(char16_t* dst, const char* src, size_t* out_len) {
    if (!dst || !src) return dst;
    char16_t* p_dst = dst;
    const uint8_t* p_src = reinterpret_cast<const uint8_t*>(src);
    size_t len = 0;

    while (*p_src) {
        uint8_t c = *p_src++;
        if ((c & 0x80) == 0) {
            *p_dst++ = static_cast<char16_t>(c);
            len++;
        } else if ((c & 0xE0) == 0xC0) {
            uint16_t val = (c & 0x1F) << 6;
            if (*p_src) val |= (*p_src++ & 0x3F);
            *p_dst++ = static_cast<char16_t>(val);
            len++;
        } else if ((c & 0xF0) == 0xE0) {
            uint16_t val = (c & 0x0F) << 12;
            if (*p_src) val |= (*p_src++ & 0x3F) << 6;
            if (*p_src) val |= (*p_src++ & 0x3F);
            *p_dst++ = static_cast<char16_t>(val);
            len++;
        } else if ((c & 0xF8) == 0xF0) {
            uint32_t cp = (c & 0x07) << 18;
            if (*p_src) cp |= (*p_src++ & 0x3F) << 12;
            if (*p_src) cp |= (*p_src++ & 0x3F) << 6;
            if (*p_src) cp |= (*p_src++ & 0x3F);
            cp -= 0x10000;
            *p_dst++ = static_cast<char16_t>(0xD800 | ((cp >> 10) & 0x3FF));
            *p_dst++ = static_cast<char16_t>(0xDC00 | (cp & 0x3FF));
            len += 2;
        }
    }
    *p_dst = 0;

    if (out_len != nullptr) {
        *out_len = len;
    }
    return dst;
}

/**
 * strcpylen8to16: alias of strcpy8to16 for Samsung RIL
 */
char16_t* strcpylen8to16(char16_t* dst, const char* src, size_t* out_len) {
    return strcpy8to16(dst, src, out_len);
}

/**
 * strdup8to16: UTF-8 to UTF-16 dynamically allocated duplicate
 * Required by Samsung libsec-ril.gsm.so / libsec-ril.so
 */
char16_t* strdup8to16(const char* s, size_t* out_len) {
    if (s == nullptr) {
        return nullptr;
    }

    size_t len = strlen8to16(s);
    char16_t* result = static_cast<char16_t*>(malloc((len + 1) * sizeof(char16_t)));
    if (result == nullptr) {
        return nullptr;
    }

    return strcpy8to16(result, s, out_len);
}

} // extern "C"
