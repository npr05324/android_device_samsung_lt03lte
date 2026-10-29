# Tested lt03lte changes — 2026-10-26

This directory archives tested changes as patches. The branch inherits the
existing device tree; it does not turn that tree into a complete mainline port.

## Platform WebView fix

- Patch: `system-core/0001-libcutils-recognize-sealed-memfds-in-sandbox.patch`
- Target repository: Android `system/core`, LineageOS 24 source.
- Original commit: `3cd368fe13898befe47a0b21bdd08a9d4ae12c51`.
- Apply from `system/core`: `git am /path/to/the/patch`.

The patch keeps recognizing sealed memfds when a sandbox denies proc-fd
readlink. Required grow/shrink seals remain checked. On the tablet, the fixed
library restored HTML and JavaScript/Canvas rendering in WebView 155.
The subsequently rebuilt system image passed build, EROFS, CRC and hash
checks. A follow-up system image including the USB fixes below was installed
and boot-tested on kernel #54. External HTTPS and HTML/JavaScript/Canvas
rendering passed again, including Canvas pixel color and DOM layout checks.

## Recording analysis and validation notes

- Patch: `workspace/0001-acoustic-analysis-and-validation.patch`
- Target: the mainline bring-up workspace, not Android `system/core` or the
  legacy device tree at this branch root.
- Original commit: `264a56ce914e6d9c18ca31797369563209ca69b5`.
- Adds `tools/acoustic-check.py` and `docs/VALIDATION-20261026.md`.

The utility checks recordings for three tone bursts separated by silence.
It detected the reference stimulus and a delayed noisy synthetic sequence;
it rejected continuous tones, noise alone, and the actual zero-valued tablet
recording. These validate the utility, not physical speaker/microphone audio.

## Active USB and serial fallback

- Patch: `workspace/0002-active-usb-and-console-fallback.patch`
- Target: the mainline workspace (device sources under
  `android/device/samsung/lt03lte`), not this legacy tree root.
- Original commit: fc987c5c532715e236773cb34e59c54be8d55768.
- Apply after the first workspace patch with `git am`.

Init starts a board service that holds a bounded wake lock only while USB
is active and a gadget is bound. The serial fallback waits for FunctionFS
readiness, preserving the console during adbd restart. Device tests covered
screen-off debugging, idle with no ADB commands, unbind release/reacquire,
serial fallback while adbd was stopped, and restoration to adb. The system
was installed and rebooted; installed hashes matched the package, the service
started automatically, and another screen-off idle test passed.

This covers active USB access. Physical unplug, host bus suspend and complete
system suspend/resume are still unverified. See the patch validation notes
for failed preliminary tests and the limits of each passing observation.

## Screen-off memory-pressure mitigation

- Patch: `workspace/0003-enable-zram-for-screen-off-stalls.patch`
- Target: the mainline workspace device sources under
  `android/device/samsung/lt03lte`.
- Original commit: `430ca01644b8e7de7e25eb7a5d1c2d253d6f8261`.
- Apply after the preceding workspace patches with `git am`.

The installed image had no swap on this 3 GiB device while Launcher and
RenderThread were being killed under memory pressure. This patch configures
a 1 GiB zram device with the kernel-supported `lzo-rle` compressor and enables
it during boot. The equivalent settings were applied to the running tablet:
zram registered at 1 GiB with priority 32758, and a three-minute screen-off
cycle woke in 255 ms with PowerManager awake, SurfaceFlinger completing its
display transition, and a valid 1.05 MB screenshot. No ANR or renderer stall
occurred during that cycle. The new image itself still needs to be flashed for
boot-time validation and longer idle soak testing.

## Excluded pending hardware validation

No pending kernel edits, microphone/codec fixes, other unverified suspend
changes, binary images, raw logs, backups, or unverified VoLTE fixes are
included. Physical audio, long-duration sleep/resume stability, and VoLTE
two-way call audio remain incomplete.
