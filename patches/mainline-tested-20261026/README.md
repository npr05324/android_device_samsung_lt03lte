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
The subsequently rebuilt system image and signed recovery package passed
build, image-content, CRC, and hash checks; that rebuilt image has not been
installed or boot-tested.

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

## Excluded pending hardware validation

No pending kernel edits, microphone/codec fixes, suspend workarounds, binary
images, raw logs, backups, or unverified VoLTE fixes are included. Physical
audio, sleep/resume stability, and VoLTE two-way call audio remain incomplete.
