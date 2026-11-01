# Restore and troubleshoot

For the exact two-state installation represented by your own manifest:

```powershell
./scripts/Set-NativeAod.ps1 -Manifest C:\LOCAL_CASE\prepared\manifest.json -WorkDir C:\LOCAL_CASE\probe-target -Serial WATCH_IP:CONNECTION_PORT -Action Restore
```

The helper verifies that the current native script is a recognized original/candidate, writes the original if necessary and verifies the readback. Confirm the actual AOD off the charger afterward. Keep backups even after restoration.

If the native script is unrecognized, do not replace its hash in the manifest to force a write. Determine whether a firmware update, face update, different folder mapping, prior customization or synchronization changed it. An original for one revision is not necessarily the original for another.

If update rollback is reported as failed or not verified, stop further writes and retain the full local log. Inspect through read-only methods before any next action. Never repeatedly write unknown states.

If the old AOD remains visible after exact readback, wake the watch and allow a new AOD transition off the charger. A successful hash does not prove reload. Do not blindly switch faces or reboot as a first fix: either may cause resource resynchronisation and overwrite the patch.

If ADB cannot connect, pairing and connection use different screens and often different ports. Rediscover the address after reconnecting. Pairing codes must remain private. Debugging and charging can affect power-state observations, so do not use a long active debug session as a battery benchmark.

This repository does not document firmware recovery from a bricked device, does not require root or bootloader changes, and does not guarantee recovery on untested versions.
