# LineageOS 18.1 — Samsung Galaxy Note 10.1 2014 Edition LTE (SM-P605S)

| 항목 | 내용 |
|---|---|
| 기기 | SM-P605S (lt03lte, SKT), MSM8974 / Adreno 330, 3 GB RAM, 2560x1600 |
| Android | LineageOS 18.1 (Android 11), 32-bit (armv7-a-neon) |
| 커널 | 3.4.113 — `kernel/samsung/msm8974` (`lineage-18.1` 브랜치), defconfig `lineage_lt03lte_skt_defconfig` |
| 리커버리 | TWRP 3.x (`twrp/build_twrp.sh` 로 F2FS 지원 재패키징) |
| 릴리즈 | `lineage-18.1-20261018-RELEASE-lt03lte-signed.zip` (RC2 확정, user / release-keys) |
| 같은 하드웨어의 Ubuntu Touch 빌드 | `device/samsung/lt03lte_halium` (Readme_Ubuntu_Touch.md) |

## 1. 빌드 조건

- Linux x86_64 호스트, 디스크 여유 약 200 GB (소스 약 80 GB + `out` 약 60 GB), RAM 16 GB 이상 권장
- LineageOS 18.1 빌드 의존성 (https://wiki.lineageos.org/devices/ 의 build 가이드와 동일), `repo`, `git`, `python3`
- vendor 추출용: `adb`, `debugfs` (e2fsprogs), `unzip`, `brotli` (없으면 `m brotli` 로 빌드된 `out/host` 의 것을 사용)
- IMS(VoLTE) 재구성용 (선택): SM-P605S 정품 펌웨어 zip (P605SKSUCQA2, Android 4.4.2), baksmali 2.1.3, smali 2.5.2, `patchelf`, `zip`
- release 빌드용: 자체 서명 키 (`~/.android-certs`, 트리에 넣지 않음)

## 2. 소스 받기

```bash
mkdir -p ~/android/lineage-18.1 && cd ~/android/lineage-18.1
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --git-lfs
mkdir -p .repo/local_manifests
curl -o .repo/local_manifests/lt03lte.xml \
  https://raw.githubusercontent.com/npr05324/android_device_samsung_lt03lte/lineage-18.1/manifests/lt03lte.xml
repo sync -c -j8
```

`manifests/lt03lte.xml` 이 가져오는 저장소:

| 경로 | 저장소 / 브랜치 |
|---|---|
| device/samsung/lt03lte | npr05324/android_device_samsung_lt03lte `lineage-18.1` |
| device/samsung/msm8974-common | npr05324/android_device_samsung_msm8974-common `lineage-18.1` |
| device/samsung/qcom-common | npr05324/android_device_samsung_qcom-common `lineage-18.1` |
| kernel/samsung/msm8974 | npr05324/android_kernel_samsung_msm8974 `lineage-18.1` |
| hardware/samsung | LineageOS/android_hardware_samsung `lineage-18.1` |
| vendor/samsung/msm8974-common | JLST-SM-MSM8974/proprietary_vendor_samsung_msm8974-common (제3자 블롭 저장소) |

`vendor/samsung/lt03lte` 는 배포하지 않는다. 아래 3장에서 직접 만든다.

## 3. vendor 블롭 추출 (`vendor/samsung/lt03lte`)

독점 바이너리는 저장소에 포함하지 않는다. 대신 `proprietary-files.txt` 에 빌드에 쓰이는
330개 항목의 설치 경로, vendor 트리 경로, sha1 이 고정되어 있고, `extract-files.sh` 가
이를 추출·검증한 뒤 `setup-makefiles.sh` 로 makefile 을 생성한다.

```bash
cd device/samsung/lt03lte

# (a) 이 LineageOS 빌드가 설치된 기기에서 (adb root 또는 TWRP 에서 /system 마운트)
./extract-files.sh

# (b) 이 기기용 LineageOS 18.1 OTA zip 에서 (system.new.dat.br 블록 OTA)
./extract-files.sh ~/lineage-18.1-YYYYMMDD-UNOFFICIAL-lt03lte.zip

# (c) system/ 트리를 가진 디렉터리에서 (마운트한 system 이미지 등)
./extract-files.sh /mnt/lt03lte-system-root
```

- 각 파일은 sha1 로 검증한다. 다른 버전을 의도적으로 쓰려면 `--no-verify`.
- `-` 로 시작하는 3개 항목(TimeService.apk, libtime_genoff.so, libTimeService.so)은 빌드 중
  재서명/strip 되는 prebuilt 모듈이라 해시를 고정하지 않는다.
- makefile 템플릿은 `vendor-makefiles/` 에 있다. vendor `Android.mk` 는 LineageOS(`lt03lte`)와
  Ubuntu Touch(`lt03lte_halium`) 두 빌드에서 공유된다.
- 원래 블롭의 출처: 정품 펌웨어 P605SKSU1CQB1(SKT) + CyanogenMod 14.1 시절 lt03lte vendor
  (TheWiggles/proprietary_vendor_samsung_lt03lte) + 이 포팅에서 추가한 BT/Wi-Fi 펌웨어.

### Samsung IMS (VoLTE) 스택

IMS 는 정품 4.4.2 펌웨어에서 Android 11 용으로 재구성한다 (`vendor/samsung/lt03lte/proprietary/ims`).

```bash
device/samsung/lt03lte/ims/build_ims.sh <SM-P605S 정품 펌웨어 zip> baksmali-2.1.3.jar smali-2.5.2.jar
```

- 먼저 한 번 빌드된 트리가 필요하다 (compat 코드가 framework 클래스에 대해 컴파일됨).
- secimsfw / commonimsservice / ImsTelephonyService / VolteSettings 를 deodex 하고, Android 11 에
  없는 메서드 호출을 `ims/patch_smali.py` 로 `org.lineageos.secims.Compat` 으로 바꾸며,
  `libSECIMSJni.so` 의 NEEDED 를 정품 OpenSSL(`*_kk`)과 `libsecims_shim` 으로 patchelf 한다.
- IMS 가 없으면 `TARGET_INCLUDE_SECIMS := false` 로 빌드한다 (LTE 데이터/CSFB 통화는 동작).

## 4. 빌드

```bash
# userdebug (test-keys) flashable zip
device/samsung/lt03lte/tools/build.sh

# user + release-keys 서명 OTA
KEYS=~/.android-certs device/samsung/lt03lte/tools/build.sh user
```

`tools/build.sh` 는 다음을 순서대로 한다.

1. 같은 트리에서 Ubuntu Touch 빌드를 했다면 `lt03lte_halium/tools/halium-switch.sh off` 로
   hybris 패치가 적용된 프로젝트를 LineageOS 리비전으로 되돌린다.
2. `patches/apply-patches.sh` — 기기 트리로 표현할 수 없는 LineageOS 저장소 수정
   (Snap 전면 카메라, libbt LPM 타이머, BT HCI close, msm8974 HWC, linkerconfig VNDK lite,
   SettingsLib 전화번호 형식, sepolicy neverallow opt-in; `patches/README.md`). `-r` 로 되돌림.
3. `lunch lineage_lt03lte-<variant>` 후 `m bacon` (userdebug) 또는 target-files 서명 + `--block` OTA (user).

수동 빌드:

```bash
bash device/samsung/lt03lte/patches/apply-patches.sh
source build/envsetup.sh
lunch lineage_lt03lte-userdebug
m bacon
```

### TWRP (F2FS)

```bash
m bootimage lt03lte_twrp_mkfs.f2fs lt03lte_twrp_fsck.f2fs
device/samsung/lt03lte/twrp/build_twrp.sh <TWRP 램디스크 디렉터리> <출력 디렉터리>
```

ROM 과 같은 커널 + 정적 mkfs/fsck.f2fs + `/data` F2FS fstab 으로 recovery.img 와 Odin 용 tar.md5 를 만든다.
ROM 커널을 바꾸면 TWRP 도 다시 만든다 (`out/target/product/lt03lte/kernel` 이 target-files 의 `BOOT/kernel` 과 같은지 확인).

### Odin 전체 패키지 (BL / AP / CP)

```bash
device/samsung/lt03lte/tools/build_odin.sh <signed target_files zip> <TWRP recovery.img> \
    <정품 펌웨어 디렉터리 (BL_*.tar.md5, CP_*.tar.md5)> <출력 디렉터리>
```

| 파일 | 내용 |
|---|---|
| `AP_P605S_LineageOS-18.1-KNPA-GOV_<날짜>.tar.md5` | boot.img (ROM 커널), recovery.img (TWRP), system.img.ext4 (target-files 의 sparse 이미지 = OTA 와 동일) |
| `BL_P605SKSUCQA2_….tar.md5` | 정품 부트로더 (aboot/sbl1/rpm/tz/sdi/NON-HLOS) 그대로 |
| `CP_P605SKSUANK1_….tar.md5` | 정품 모뎀 (modem.bin) 그대로 |

- 부트로더는 CQA2 (P605S 최종 펌웨어) 와 같은 버전이라야 한다. Samsung 부트로더는 다운그레이드를 거부한다.
- CSC 는 넣지 않는다 (cache / data 는 건드리지 않고 초기화는 TWRP 에서 한다). 정품 CSC 는 쓰면 안 된다.
  정품 cache 이미지의 `recovery/command` 가 `sec_csc.zip` 설치를 지시해서 TWRP 가 Samsung CSC 파일을
  LineageOS `/system` 위에 덮어쓴다.
- EFS / MODEMST / PERSIST / PARAM (IMEI·보정값) 과 PIT 는 넣지 않는다 (재파티션 없음).

## 5. 설치

### (a) TWRP + ROM zip

1. Odin/heimdall 로 TWRP 를 recovery 에 플래시한다.
2. TWRP 에서 Format Data (F2FS) 후 ROM zip 을 설치한다 (GApps 는 OpenGApps arm 11.0 nano 확인됨).
3. 첫 부팅 후 설정 마법사를 끝내야 모바일 데이터가 켜진다.

### (b) Odin 전체 패키지

1. 다운로드 모드로 들어가 Odin 에 BL / AP / CP 를 넣는다 (CSC 칸은 비운다).
   Options 에서 **Auto Reboot 해제**, Re-Partition 은 해제 상태 그대로 두고 Start.
2. 완료 후 기기를 끄고 Android 를 거치지 않고 바로 리커버리(TWRP)로 들어간다.
3. 새로 설치하는 경우 TWRP 에서 Format Data (F2FS) 또는 Wipe > Factory Reset 을 한다
   (같은 LineageOS 위에 덮어쓰는 경우는 생략 가능).
4. GApps 가 필요하면 이 단계에서 TWRP 로 설치한 뒤 재부팅한다.

## 6. 작업 내용

### 커널 (`kernel/samsung/msm8974`, `lineage-18.1`)
- `lineage_lt03lte_skt_defconfig`: LOCALVERSION `-KNPA-GOV`, 디버그 옵션 off, zram/lz4, F2FS, 거버너 조정
- 모뎀 크래시 시 SoC 전체 재부팅 대신 서브시스템 재시작 (coupled SSR)
- USB gadget string ID 고갈 수정 (adbd 재바인드 시 열거 실패)
- eDP 패널 링크 트레이닝/전원 차단 지연 보정
- 진동 세기 sysfs (`intensity`, 0-10000), vibrator HAL 1.3
- 배터리: 충전기 CE 토글 경로 수정, 충전 제한 `batt_charge_limit`(50-100), fuel gauge 사이클/SOH 노출
- bq24260 충전기 `online` 속성 보고 (healthd/uevent 오류 로그 제거), mdss 미지원 ioctl 로그 debug 레벨로 하향
- gcc-wrapper python3, `-Wmaybe-uninitialized` 무시

### 공통 (`device/samsung/msm8974-common`)
- libril: 레거시 radio state 매핑, BASEBAND_VERSION 캐시(모뎀 크래시 원인 제거), CDMA 구독 요청 무시,
  Samsung IMS 등록 unsol(11027) 추적 → VoLTE 등록 시에만 PS 다이얼, IMS SMS 비트 반영, 통화 종료 원인 파싱 수정
- GPS: libdsi_netctrl 스텁으로 loc_api v02 활성화, xtra2, gps_debug.conf
- 센서: Samsung 블롭 `GeomagneticSensor::readEvents()` 가 요청보다 많은 이벤트를 써서 poll 루프가 멈추는 버그를
  multihal 에서 vtable 래퍼로 우회 (`sensors/BlobFixups.cpp`; 증상: 모든 센서·자동 회전 정지, HAL·logd CPU 과점유)
- HAL: vibrator 1.3, sensors, libshim_camera/atomic, 사용하지 않는 livedisplay 인터페이스 제거(system_server watchdog)
- adbd FunctionFS 레거시 모드 (3.4 커널에 AIO 없음), sepolicy 보강

### 기기 (`device/samsung/lt03lte`)
- 텔레포니: SKT APN(`apn/`, lte.sktelecom.com 우선, network_type_bitmask), libsec-ril shim, init.baseband.sh
- VoLTE: 정품 Samsung IMS 스택 이식 (`ims/`), IMS APN persistent, networkAttributes `mobile_ims`
- 오디오: audio_policy_configuration.xml (A2DP/USB/r_submix), 스피커 모드 통화 마이크 매핑
- 블루투스: BCM4339 설정, HFP SCO 설정 (`BTHW_FW_EXTENDED_CONFIGURATION`)
- 카메라: CameraWrapper 수정, Snap 전면 카메라 (overlay `front_camera_restart_preview_onPictureTaken`)
- 키: 왼쪽 터치키 KEY_RECENT → MENU, 하드웨어 키 overlay (Home/Menu/Back), 메뉴 짧게 = 앱 전환 / 길게 = 최근 앱
- 배터리 관리 앱 `parts/` (Lt03lteParts, 설정 > 배터리)
- SELinux enforcing (`sepolicy/vendor`), user 빌드 + release-keys, adb root 제거, `persist.sys.usb.config=mtp`
- zram 1 GB lz4, swappiness 100, `/data` F2FS 우선 (ext4 대체), 태블릿 dalvik heap
- vendor 블롭 추출 체계 (`proprietary-files.txt`, `extract-files.sh`, `setup-makefiles.sh`, `vendor-makefiles/`, `tools/sdat2img.py`)

## 7. 확인된 동작 / 알려진 문제

| 항목 | 상태 |
|---|---|
| LTE 데이터, APN, 전화번호, IMEI | 동작 |
| 음성 통화 (CSFB), VoLTE 착신/발신, SMS/MMS | 동작 (SKT) |
| Wi-Fi, 블루투스 (A2DP AAC, HFP) | 동작 |
| GPS | 동작 (XTRA 는 모뎀이 거부, 콜드 TTFF 약 10분) |
| 카메라 (전/후면), 센서 (가속/자이로/지자기/조도/그립/홀) | 동작 |
| 진동, 배터리 충전 제한 | 동작 |
| SELinux | enforcing |
| 자동 회전 | 동작 (RC2 에서 센서 블롭 버그 우회) |
| RCS (Google 메시지 채팅) | 미지원 — SKT 가 차단 (오류 코드 1005) |
| 3.4 커널 load average 약 10 | 커널 스레드 D 상태로 인한 표시상 값, 실제 부하 아님 |
