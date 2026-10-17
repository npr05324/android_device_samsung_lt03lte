# lt03lte source patches

Fixes that live outside the device tree because there is no build-time hook
for them. Everything else (APNs, USB IDs, BT config, RIL shims, ...) is done
from the device tree itself.

Apply after `repo sync`:

    device/samsung/lt03lte/patches/apply-patches.sh

Revert with `-r`.

| Repo | Patch | Why |
|------|-------|-----|
| packages/apps/Snap | front camera rotation | `setRotation()` got 271 when orientation is UNKNOWN with a 90 degree sensor offset, crashing on the first front shot |
| hardware/broadcom/libbt | LPM timer | `upio_start_stop_timer()` armed an uninitialised timer before LPM setup |
| hardware/interfaces | BT HCI close | `close()` called a null unlink callback on repeated close (HAL abort) |
| hardware/qcom-caf/msm8974/display | HWC | async QService init and removal of QTI_BSP / libbfqio dependencies missing on this platform |
| system/linkerconfig | VNDK lite | treat `ro.vndk.lite=true` (pre-Treble blobs) as legacy linker namespace layout |
| frameworks/base | SettingsLib phone number | format MDN with the SIM country (kr) instead of the UI locale, avoiding US style hyphens on en-US |
| system/sepolicy | neverallow on user | lets the device opt in to skipping the build-time neverallow check on user builds (msm8974 qcom legacy policy is not Android 11 neverallow clean; runtime policy unchanged and enforcing) |
