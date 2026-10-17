/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 *
 * Symbols libSECIMSJni.so (SKT stock 4.4.2 IMS) imports from KitKat media,
 * camera, gui, skia and ArcSoft libraries. They are only used by the video
 * call and AP-side media paths; VoLTE voice is handled by the modem through
 * libcpve-client, so they are provided as no-op stubs here.
 * Generated from the stock image, do not edit by hand.
 */

#include <new>
#include <stddef.h>
#include <utils/String8.h>

// KitKat used unsigned short for char16_t strings
extern "C" void shim_String8_ctor_u16(android::String8* self, const unsigned short* str, size_t len)
        __asm__("_ZN7android7String8C1EPKtj");
extern "C" void shim_String8_ctor_u16(android::String8* self, const unsigned short* str, size_t len) {
    new (self) android::String8(reinterpret_cast<const char16_t*>(str), len);
}

// MMemAlloc (libarcplatform.so)
extern "C" long shim_stub_0() __asm__("MMemAlloc");
extern "C" long shim_stub_0() { return 0; }
// MMemCmp (libarcplatform.so)
extern "C" long shim_stub_1() __asm__("MMemCmp");
extern "C" long shim_stub_1() { return 0; }
// MMemCpy (libarcplatform.so)
extern "C" long shim_stub_2() __asm__("MMemCpy");
extern "C" long shim_stub_2() { return 0; }
// MMemFree (libarcplatform.so)
extern "C" long shim_stub_3() __asm__("MMemFree");
extern "C" long shim_stub_3() { return 0; }
// MMemMove (libarcplatform.so)
extern "C" long shim_stub_4() __asm__("MMemMove");
extern "C" long shim_stub_4() { return 0; }
// MMemRealloc (libarcplatform.so)
extern "C" long shim_stub_5() __asm__("MMemRealloc");
extern "C" long shim_stub_5() { return 0; }
// MMemSet (libarcplatform.so)
extern "C" long shim_stub_6() __asm__("MMemSet");
extern "C" long shim_stub_6() { return 0; }
// MSCsCat (libarcplatform.so)
extern "C" long shim_stub_7() __asm__("MSCsCat");
extern "C" long shim_stub_7() { return 0; }
// MSCsCpy (libarcplatform.so)
extern "C" long shim_stub_8() __asm__("MSCsCpy");
extern "C" long shim_stub_8() { return 0; }
// MSCsICmp (libarcplatform.so)
extern "C" long shim_stub_9() __asm__("MSCsICmp");
extern "C" long shim_stub_9() { return 0; }
// MSCsLen (libarcplatform.so)
extern "C" long shim_stub_10() __asm__("MSCsLen");
extern "C" long shim_stub_10() { return 0; }
// MSCsNCmp (libarcplatform.so)
extern "C" long shim_stub_11() __asm__("MSCsNCmp");
extern "C" long shim_stub_11() { return 0; }
// MSCsNCpy (libarcplatform.so)
extern "C" long shim_stub_12() __asm__("MSCsNCpy");
extern "C" long shim_stub_12() { return 0; }
// MSSprintf (libarcplatform.so)
extern "C" long shim_stub_13() __asm__("MSSprintf");
extern "C" long shim_stub_13() { return 0; }
// MStreamClose (libarcplatform.so)
extern "C" long shim_stub_14() __asm__("MStreamClose");
extern "C" long shim_stub_14() { return 0; }
// MStreamFileDeleteS (libarcplatform.so)
extern "C" long shim_stub_15() __asm__("MStreamFileDeleteS");
extern "C" long shim_stub_15() { return 0; }
// MStreamFlush (libarcplatform.so)
extern "C" long shim_stub_16() __asm__("MStreamFlush");
extern "C" long shim_stub_16() { return 0; }
// MStreamGetSize (libarcplatform.so)
extern "C" long shim_stub_17() __asm__("MStreamGetSize");
extern "C" long shim_stub_17() { return 0; }
// MStreamOpenFromFileS (libarcplatform.so)
extern "C" long shim_stub_18() __asm__("MStreamOpenFromFileS");
extern "C" long shim_stub_18() { return 0; }
// MStreamOpenFromMemoryBlock (libarcplatform.so)
extern "C" long shim_stub_19() __asm__("MStreamOpenFromMemoryBlock");
extern "C" long shim_stub_19() { return 0; }
// MStreamRead (libarcplatform.so)
extern "C" long shim_stub_20() __asm__("MStreamRead");
extern "C" long shim_stub_20() { return 0; }
// MStreamSeek (libarcplatform.so)
extern "C" long shim_stub_21() __asm__("MStreamSeek");
extern "C" long shim_stub_21() { return 0; }
// MStreamSetSize (libarcplatform.so)
extern "C" long shim_stub_22() __asm__("MStreamSetSize");
extern "C" long shim_stub_22() { return 0; }
// MStreamTell (libarcplatform.so)
extern "C" long shim_stub_23() __asm__("MStreamTell");
extern "C" long shim_stub_23() { return 0; }
// MStreamWrite (libarcplatform.so)
extern "C" long shim_stub_24() __asm__("MStreamWrite");
extern "C" long shim_stub_24() { return 0; }
// SkImageEncoder::EncodeFile(char const*, SkBitmap const&, SkImageEncoder::Type, int) (libskia.so)
extern "C" long shim_stub_25() __asm__("_ZN14SkImageEncoder10EncodeFileEPKcRK8SkBitmapNS_4TypeEi");
extern "C" long shim_stub_25() { return 0; }
// android::AudioTrack::getMinFrameCount(unsigned int*, audio_stream_type_t, unsigned int) (libmedia.so)
extern "C" long shim_stub_26() __asm__("_ZN7android10AudioTrack16getMinFrameCountEPj19audio_stream_type_tj");
extern "C" long shim_stub_26() { return 0; }
// android::AudioTrack::set(audio_stream_type_t, unsigned int, audio_format_t, unsigned int, int, audio_output_flags_t, void (*)(int, void*, void*), void*, int, android::sp<android::IMemory> const&, bool, int, android::AudioTrack::transfer_type, audio_offload_info_t const*, int) (libmedia.so)
extern "C" long shim_stub_27() __asm__("_ZN7android10AudioTrack3setE19audio_stream_type_tj14audio_format_tji20audio_output_flags_tPFviPvS4_ES4_iRKNS_2spINS_7IMemoryEEEbiNS0_13transfer_typeEPK20audio_offload_info_ti");
extern "C" long shim_stub_27() { return 0; }
// android::AudioTrack::stop() (libmedia.so)
extern "C" long shim_stub_28() __asm__("_ZN7android10AudioTrack4stopEv");
extern "C" long shim_stub_28() { return 0; }
// android::AudioTrack::flush() (libmedia.so)
extern "C" long shim_stub_29() __asm__("_ZN7android10AudioTrack5flushEv");
extern "C" long shim_stub_29() { return 0; }
// android::AudioTrack::start() (libmedia.so)
extern "C" long shim_stub_30() __asm__("_ZN7android10AudioTrack5startEv");
extern "C" long shim_stub_30() { return 0; }
// android::AudioTrack::write(void const*, unsigned int) (libmedia.so)
extern "C" long shim_stub_31() __asm__("_ZN7android10AudioTrack5writeEPKvj");
extern "C" long shim_stub_31() { return 0; }
// android::AudioTrack::AudioTrack(audio_stream_type_t, unsigned int, audio_format_t, unsigned int, int, audio_output_flags_t, void (*)(int, void*, void*), void*, int, int, android::AudioTrack::transfer_type, audio_offload_info_t const*, int) (libmedia.so)
extern "C" long shim_stub_32() __asm__("_ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_tji20audio_output_flags_tPFviPvS4_ES4_iiNS0_13transfer_typeEPK20audio_offload_info_ti");
extern "C" long shim_stub_32() { return 0; }
// android::AudioTrack::AudioTrack() (libmedia.so)
extern "C" long shim_stub_33() __asm__("_ZN7android10AudioTrackC1Ev");
extern "C" long shim_stub_33() { return 0; }
// android::FileSource::FileSource(char const*) (libstagefright.so)
extern "C" long shim_stub_34() __asm__("_ZN7android10FileSourceC1EPKc");
extern "C" long shim_stub_34() { return 0; }
// android::AudioRecord::set(audio_source_t, unsigned int, audio_format_t, unsigned int, int, void (*)(int, void*, void*), void*, int, bool, int, android::AudioRecord::transfer_type, audio_input_flags_t) (libmedia.so)
extern "C" long shim_stub_35() __asm__("_ZN7android11AudioRecord3setE14audio_source_tj14audio_format_tjiPFviPvS3_ES3_ibiNS0_13transfer_typeE19audio_input_flags_t");
extern "C" long shim_stub_35() { return 0; }
// android::AudioRecord::read(void*, unsigned int) (libmedia.so)
extern "C" long shim_stub_36() __asm__("_ZN7android11AudioRecord4readEPvj");
extern "C" long shim_stub_36() { return 0; }
// android::AudioRecord::stop() (libmedia.so)
extern "C" long shim_stub_37() __asm__("_ZN7android11AudioRecord4stopEv");
extern "C" long shim_stub_37() { return 0; }
// android::AudioRecord::start(android::AudioSystem::sync_event_t, int) (libmedia.so)
extern "C" long shim_stub_38() __asm__("_ZN7android11AudioRecord5startENS_11AudioSystem12sync_event_tEi");
extern "C" long shim_stub_38() { return 0; }
// android::AudioRecord::AudioRecord(audio_source_t, unsigned int, audio_format_t, unsigned int, int, void (*)(int, void*, void*), void*, int, int, android::AudioRecord::transfer_type, audio_input_flags_t) (libmedia.so)
extern "C" long shim_stub_39() __asm__("_ZN7android11AudioRecordC1E14audio_source_tj14audio_format_tjiPFviPvS3_ES3_iiNS0_13transfer_typeE19audio_input_flags_t");
extern "C" long shim_stub_39() { return 0; }
// android::AudioRecord::AudioRecord() (libmedia.so)
extern "C" long shim_stub_40() __asm__("_ZN7android11AudioRecordC1Ev");
extern "C" long shim_stub_40() { return 0; }
// android::AudioSource::AudioSource(audio_source_t, unsigned int, unsigned int) (libstagefright.so)
extern "C" long shim_stub_41() __asm__("_ZN7android11AudioSourceC1E14audio_source_tjj");
extern "C" long shim_stub_41() { return 0; }
// android::MediaBuffer::setObserver(android::MediaBufferObserver*) (libstagefright.so)
extern "C" long shim_stub_42() __asm__("_ZN7android11MediaBuffer11setObserverEPNS_19MediaBufferObserverE");
extern "C" long shim_stub_42() { return 0; }
// android::MediaBuffer::add_ref() (libstagefright.so)
extern "C" long shim_stub_43() __asm__("_ZN7android11MediaBuffer7add_refEv");
extern "C" long shim_stub_43() { return 0; }
// android::MediaBuffer::release() (libstagefright.so)
extern "C" long shim_stub_44() __asm__("_ZN7android11MediaBuffer7releaseEv");
extern "C" long shim_stub_44() { return 0; }
// android::MediaBuffer::meta_data() (libstagefright.so)
extern "C" long shim_stub_45() __asm__("_ZN7android11MediaBuffer9meta_dataEv");
extern "C" long shim_stub_45() { return 0; }
// android::MediaBuffer::MediaBuffer(void*, unsigned int) (libstagefright.so)
extern "C" long shim_stub_46() __asm__("_ZN7android11MediaBufferC1EPvj");
extern "C" long shim_stub_46() { return 0; }
// android::MediaSource::MediaSource() (libstagefright.so)
extern "C" long shim_stub_47() __asm__("_ZN7android11MediaSourceC2Ev");
extern "C" long shim_stub_47() { return 0; }
// android::MediaSource::~MediaSource() (libstagefright.so)
extern "C" long shim_stub_48() __asm__("_ZN7android11MediaSourceD0Ev");
extern "C" long shim_stub_48() { return 0; }
// android::MediaSource::~MediaSource() (libstagefright.so)
extern "C" long shim_stub_49() __asm__("_ZN7android11MediaSourceD1Ev");
extern "C" long shim_stub_49() { return 0; }
// android::MediaSource::~MediaSource() (libstagefright.so)
extern "C" long shim_stub_50() __asm__("_ZN7android11MediaSourceD2Ev");
extern "C" long shim_stub_50() { return 0; }
// android::MediaExtractor::Create(android::sp<android::DataSource> const&, char const*) (libstagefright.so)
extern "C" long shim_stub_51() __asm__("_ZN7android14MediaExtractor6CreateERKNS_2spINS_10DataSourceEEEPKc");
extern "C" long shim_stub_51() { return 0; }
// android::CameraParameters::setVideoSize(int, int) (libcamera_client.so)
extern "C" long shim_stub_52() __asm__("_ZN7android16CameraParameters12setVideoSizeEii");
extern "C" long shim_stub_52() { return 0; }
// android::CameraParameters::setPreviewSize(int, int) (libcamera_client.so)
extern "C" long shim_stub_53() __asm__("_ZN7android16CameraParameters14setPreviewSizeEii");
extern "C" long shim_stub_53() { return 0; }
// android::CameraParameters::setPreviewFormat(char const*) (libcamera_client.so)
extern "C" long shim_stub_54() __asm__("_ZN7android16CameraParameters16setPreviewFormatEPKc");
extern "C" long shim_stub_54() { return 0; }
// android::CameraParameters::setPreviewFrameRate(int) (libcamera_client.so)
extern "C" long shim_stub_55() __asm__("_ZN7android16CameraParameters19setPreviewFrameRateEi");
extern "C" long shim_stub_55() { return 0; }
// android::CameraParameters::set(char const*, char const*) (libcamera_client.so)
extern "C" long shim_stub_56() __asm__("_ZN7android16CameraParameters3setEPKcS2_");
extern "C" long shim_stub_56() { return 0; }
// android::CameraParameters::set(char const*, int) (libcamera_client.so)
extern "C" long shim_stub_57() __asm__("_ZN7android16CameraParameters3setEPKci");
extern "C" long shim_stub_57() { return 0; }
// android::CameraParameters::unflatten(android::String8 const&) (libcamera_client.so)
extern "C" long shim_stub_58() __asm__("_ZN7android16CameraParameters9unflattenERKNS_7String8E");
extern "C" long shim_stub_58() { return 0; }
// android::CameraParameters::~CameraParameters() (libcamera_client.so)
extern "C" long shim_stub_59() __asm__("_ZN7android16CameraParametersD1Ev");
extern "C" long shim_stub_59() { return 0; }
// android::SoftwareRenderer::render(void const*, unsigned int, void*) (libstagefright.so)
extern "C" long shim_stub_60() __asm__("_ZN7android16SoftwareRenderer6renderEPKvjPv");
extern "C" long shim_stub_60() { return 0; }
// android::SoftwareRenderer::SoftwareRenderer(android::sp<ANativeWindow> const&, android::sp<android::MetaData> const&) (libstagefright.so)
extern "C" long shim_stub_61() __asm__("_ZN7android16SoftwareRendererC1ERKNS_2spI13ANativeWindowEERKNS1_INS_8MetaDataEEE");
extern "C" long shim_stub_61() { return 0; }
// android::SoftwareRenderer::~SoftwareRenderer() (libstagefright.so)
extern "C" long shim_stub_62() __asm__("_ZN7android16SoftwareRendererD1Ev");
extern "C" long shim_stub_62() { return 0; }
// android::MEDIA_MIMETYPE_VIDEO_AVC (libstagefright.so)
extern "C" const char* shim_data_63 __asm__("_ZN7android24MEDIA_MIMETYPE_VIDEO_AVCE");
extern "C" const char* shim_data_63 = "video/avc";
// android::MEDIA_MIMETYPE_VIDEO_RAW (libstagefright.so)
extern "C" const char* shim_data_64 __asm__("_ZN7android24MEDIA_MIMETYPE_VIDEO_RAWE");
extern "C" const char* shim_data_64 = "video/raw";
// android::MEDIA_MIMETYPE_VIDEO_H263 (libstagefright.so)
extern "C" const char* shim_data_65 __asm__("_ZN7android25MEDIA_MIMETYPE_VIDEO_H263E");
extern "C" const char* shim_data_65 = "video/3gpp";
// android::MEDIA_MIMETYPE_VIDEO_MPEG4 (libstagefright.so)
extern "C" const char* shim_data_66 __asm__("_ZN7android26MEDIA_MIMETYPE_VIDEO_MPEG4E");
extern "C" const char* shim_data_66 = "video/mp4v-es";
// android::MEDIA_MIMETYPE_AUDIO_AMR_NB (libstagefright.so)
extern "C" const char* shim_data_67 __asm__("_ZN7android27MEDIA_MIMETYPE_AUDIO_AMR_NBE");
extern "C" const char* shim_data_67 = "audio/3gpp";
// android::MEDIA_MIMETYPE_AUDIO_AMR_WB (libstagefright.so)
extern "C" const char* shim_data_68 __asm__("_ZN7android27MEDIA_MIMETYPE_AUDIO_AMR_WBE");
extern "C" const char* shim_data_68 = "audio/amr-wb";
// android::MEDIA_MIMETYPE_AUDIO_G711_ALAW (libstagefright.so)
extern "C" const char* shim_data_69 __asm__("_ZN7android30MEDIA_MIMETYPE_AUDIO_G711_ALAWE");
extern "C" const char* shim_data_69 = "audio/g711-alaw";
// android::MEDIA_MIMETYPE_AUDIO_G711_MLAW (libstagefright.so)
extern "C" const char* shim_data_70 __asm__("_ZN7android30MEDIA_MIMETYPE_AUDIO_G711_MLAWE");
extern "C" const char* shim_data_70 = "audio/g711-mlaw";
// android::Camera::sendCommand(int, int, int) (libcamera_client.so)
extern "C" long shim_stub_71() __asm__("_ZN7android6Camera11sendCommandEiii");
extern "C" long shim_stub_71() { return 0; }
// android::Camera::setListener(android::sp<android::CameraListener> const&) (libcamera_client.so)
extern "C" long shim_stub_72() __asm__("_ZN7android6Camera11setListenerERKNS_2spINS_14CameraListenerEEE");
extern "C" long shim_stub_72() { return 0; }
// android::Camera::stopPreview() (libcamera_client.so)
extern "C" long shim_stub_73() __asm__("_ZN7android6Camera11stopPreviewEv");
extern "C" long shim_stub_73() { return 0; }
// android::Camera::startPreview() (libcamera_client.so)
extern "C" long shim_stub_74() __asm__("_ZN7android6Camera12startPreviewEv");
extern "C" long shim_stub_74() { return 0; }
// android::Camera::setParameters(android::String8 const&) (libcamera_client.so)
extern "C" long shim_stub_75() __asm__("_ZN7android6Camera13setParametersERKNS_7String8E");
extern "C" long shim_stub_75() { return 0; }
// android::Camera::releaseRecordingFrame(android::sp<android::IMemory> const&) (libcamera_client.so)
extern "C" long shim_stub_76() __asm__("_ZN7android6Camera21releaseRecordingFrameERKNS_2spINS_7IMemoryEEE");
extern "C" long shim_stub_76() { return 0; }
// android::Camera::setPreviewCallbackFlags(int) (libcamera_client.so)
extern "C" long shim_stub_77() __asm__("_ZN7android6Camera23setPreviewCallbackFlagsEi");
extern "C" long shim_stub_77() { return 0; }
// android::Camera::connect(int, android::String16 const&, int) (libcamera_client.so)
extern "C" long shim_stub_78() __asm__("_ZN7android6Camera7connectEiRKNS_8String16Ei");
extern "C" long shim_stub_78() { return 0; }
// android::MetaData::setCString(unsigned int, char const*) (libstagefright.so)
extern "C" long shim_stub_79() __asm__("_ZN7android8MetaData10setCStringEjPKc");
extern "C" long shim_stub_79() { return 0; }
// android::MetaData::findCString(unsigned int, char const**) (libstagefright.so)
extern "C" long shim_stub_80() __asm__("_ZN7android8MetaData11findCStringEjPPKc");
extern "C" long shim_stub_80() { return 0; }
// android::MetaData::setInt32(unsigned int, int) (libstagefright.so)
extern "C" long shim_stub_81() __asm__("_ZN7android8MetaData8setInt32Eji");
extern "C" long shim_stub_81() { return 0; }
// android::MetaData::setInt64(unsigned int, long long) (libstagefright.so)
extern "C" long shim_stub_82() __asm__("_ZN7android8MetaData8setInt64Ejx");
extern "C" long shim_stub_82() { return 0; }
// android::MetaData::findInt32(unsigned int, int*) (libstagefright.so)
extern "C" long shim_stub_83() __asm__("_ZN7android8MetaData9findInt32EjPi");
extern "C" long shim_stub_83() { return 0; }
// android::MetaData::findInt64(unsigned int, long long*) (libstagefright.so)
extern "C" long shim_stub_84() __asm__("_ZN7android8MetaData9findInt64EjPx");
extern "C" long shim_stub_84() { return 0; }
// android::MetaData::MetaData() (libstagefright.so)
extern "C" long shim_stub_85() __asm__("_ZN7android8MetaDataC1Ev");
extern "C" long shim_stub_85() { return 0; }
// android::OMXCodec::changeBitrate(unsigned int) (libstagefright.so)
extern "C" long shim_stub_86() __asm__("_ZN7android8OMXCodec13changeBitrateEj");
extern "C" long shim_stub_86() { return 0; }
// android::OMXCodec::Create(android::sp<android::IOMX> const&, android::sp<android::MetaData> const&, bool, android::sp<android::MediaSource> const&, char const*, unsigned int, android::sp<ANativeWindow> const&) (libstagefright.so)
extern "C" long shim_stub_87() __asm__("_ZN7android8OMXCodec6CreateERKNS_2spINS_4IOMXEEERKNS1_INS_8MetaDataEEEbRKNS1_INS_11MediaSourceEEEPKcjRKNS1_I13ANativeWindowEE");
extern "C" long shim_stub_87() { return 0; }
// android::OMXCodec::forceIDR() (libstagefright.so)
extern "C" long shim_stub_88() __asm__("_ZN7android8OMXCodec8forceIDREv");
extern "C" long shim_stub_88() { return 0; }
// android::OMXClient::connect() (libstagefright.so)
extern "C" long shim_stub_89() __asm__("_ZN7android9OMXClient7connectEv");
extern "C" long shim_stub_89() { return 0; }
// android::OMXClient::OMXClient() (libstagefright.so)
extern "C" long shim_stub_90() __asm__("_ZN7android9OMXClientC1Ev");
extern "C" long shim_stub_90() { return 0; }
// SkBitmap::setConfig(SkBitmap::Config, int, int, unsigned int) (libskia.so)
extern "C" long shim_stub_91() __asm__("_ZN8SkBitmap9setConfigENS_6ConfigEiij");
extern "C" long shim_stub_91() { return 0; }
// SkBitmap::setPixels(void*, SkColorTable*) (libskia.so)
extern "C" long shim_stub_92() __asm__("_ZN8SkBitmap9setPixelsEPvP12SkColorTable");
extern "C" long shim_stub_92() { return 0; }
// SkBitmap::SkBitmap() (libskia.so)
extern "C" long shim_stub_93() __asm__("_ZN8SkBitmapC1Ev");
extern "C" long shim_stub_93() { return 0; }
// SkBitmap::~SkBitmap() (libskia.so)
extern "C" long shim_stub_94() __asm__("_ZN8SkBitmapD1Ev");
extern "C" long shim_stub_94() { return 0; }
// android::AudioTrack::getPosition(unsigned int*) const (libmedia.so)
extern "C" long shim_stub_95() __asm__("_ZNK7android10AudioTrack11getPositionEPj");
extern "C" long shim_stub_95() { return 0; }
// android::AudioSource::initCheck() const (libstagefright.so)
extern "C" long shim_stub_96() __asm__("_ZNK7android11AudioSource9initCheckEv");
extern "C" long shim_stub_96() { return 0; }
// android::MediaBuffer::range_length() const (libstagefright.so)
extern "C" long shim_stub_97() __asm__("_ZNK7android11MediaBuffer12range_lengthEv");
extern "C" long shim_stub_97() { return 0; }
// android::MediaBuffer::data() const (libstagefright.so)
extern "C" long shim_stub_98() __asm__("_ZNK7android11MediaBuffer4dataEv");
extern "C" long shim_stub_98() { return 0; }
// android::MediaBuffer::size() const (libstagefright.so)
extern "C" long shim_stub_99() __asm__("_ZNK7android11MediaBuffer4sizeEv");
extern "C" long shim_stub_99() { return 0; }
// android::CameraParameters::getSupportedPreviewSizes(android::Vector<android::Size>&) const (libcamera_client.so)
extern "C" long shim_stub_100() __asm__("_ZNK7android16CameraParameters24getSupportedPreviewSizesERNS_6VectorINS_4SizeEEE");
extern "C" long shim_stub_100() { return 0; }
// android::CameraParameters::get(char const*) const (libcamera_client.so)
extern "C" long shim_stub_101() __asm__("_ZNK7android16CameraParameters3getEPKc");
extern "C" long shim_stub_101() { return 0; }
// android::CameraParameters::flatten() const (libcamera_client.so)
extern "C" long shim_stub_102() __asm__("_ZNK7android16CameraParameters7flattenEv");
extern "C" long shim_stub_102() { return 0; }
// android::Camera::getParameters() const (libcamera_client.so)
extern "C" long shim_stub_103() __asm__("_ZNK7android6Camera13getParametersEv");
extern "C" long shim_stub_103() { return 0; }
// android::Surface::getIGraphicBufferProducer() const (libgui.so)
extern "C" long shim_stub_104() __asm__("_ZNK7android7Surface25getIGraphicBufferProducerEv");
extern "C" long shim_stub_104() { return 0; }
// android::MetaData::findData(unsigned int, unsigned int*, void const**, unsigned int*) const (libstagefright.so)
extern "C" long shim_stub_105() __asm__("_ZNK7android8MetaData8findDataEjPjPPKvS1_");
extern "C" long shim_stub_105() { return 0; }
// virtual thunk to android::MediaSource::~MediaSource() (libstagefright.so)
extern "C" long shim_stub_106() __asm__("_ZTv0_n12_N7android11MediaSourceD0Ev");
extern "C" long shim_stub_106() { return 0; }
// virtual thunk to android::MediaSource::~MediaSource() (libstagefright.so)
extern "C" long shim_stub_107() __asm__("_ZTv0_n12_N7android11MediaSourceD1Ev");
extern "C" long shim_stub_107() { return 0; }
