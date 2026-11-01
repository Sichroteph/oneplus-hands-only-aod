# Reproduce the hands-only AOD

These instructions target technical users or an assistant able to inspect APK resources and binary files. The resource mapping step still requires inspection. Do not treat an example folder number as a discovered identity.

## 1. Prepare

Use Windows PowerShell, Python 3, Node.js, a JDK providing javac/jar, Android SDK platform-tools, an installed Android platform and SDK build-tools providing d8. The supplied build script expects the SDK at `$env:LOCALAPPDATA\Android\Sdk`; pass `-SdkRoot` for another location. Use a fresh local working folder outside the public repository for APKs, backups and logs.

Enable Developer options and Wireless debugging on the watch. Pair using the pairing screen's address, port and current code, then connect using the main Wireless debugging screen's port. These are usually different ports. Never commit the pairing code.

```powershell
adb pair WATCH_IP:PAIRING_PORT
adb connect WATCH_IP:CONNECTION_PORT
$serial = 'WATCH_IP:CONNECTION_PORT'
adb -s $serial shell getprop ro.product.model
adb -s $serial shell getprop ro.build.display.id
adb -s $serial shell dumpsys wallpaper
adb -s $serial shell pm path com.oplus.wearos.watchface.silence
```

For Metric Matrix use `com.oplus.wearos.watchface.fuzazujian`. Confirm the active component, package version and physical watch identity. Stop for an untested build until it has been investigated. Do not change the active face during installation.

## 2. Inspect the original APK

Pull the exact APK path returned by `pm path`, keeping the APK private. Inspect it as a ZIP. The tested resources are under `assets/mcu-466x466/`, including `aod/script/main.js`, `aod/script/js_asset.js`, `aod/setting.bin` and root `setting.bin`.

Compare the SHA-256 of the extracted `main.js` with [the compatibility table](compatibility.md). A different hash requires a new analysis, not a disabled guard. The recipe expects exact bytes, including line endings.

## 3. Build a probe for read-only discovery

The Java probe supports read-only discovery and guarded writes. For discovery only, create a JSON manifest from a recipe's model, package, original and candidate hashes. Set `native_path` to the syntactically valid placeholder `/wf/wf99/aod/script/main.js`. This placeholder is NOT an identified target. Never run Install or Restore with this manifest.

```powershell
./scripts/Build-RtosProbe.ps1 -Manifest C:\LOCAL_CASE\discovery.json -WorkDir C:\LOCAL_CASE\probe-discovery
adb -s $serial push C:\LOCAL_CASE\probe-discovery\probe.jar /data/local/tmp/oneplus-aod-read-probe.jar
$probe = 'CLASSPATH=/data/local/tmp/oneplus-aod-read-probe.jar app_process / com.christophe.research.McuReadProbe '
adb -s $serial shell ($probe + 'adb-list')
adb -s $serial shell ($probe + 'adb-pull /wf/wf_manager_config.txt') | Set-Content -Encoding utf8 C:\LOCAL_CASE\manager-response.txt
python ./scripts/decode-native-file.py C:\LOCAL_CASE\manager-response.txt C:\LOCAL_CASE\wf-manager-config.bin
```

## 4. Identify and back up the native resources

`wf_manager_config.txt` is binary despite its extension. Match the watch-face UUID from the APK settings to the corresponding manager record and its `wfN` folder. See the observed UUIDs in the compatibility table. Use a hex editor or a script; verify the UUID and folder belong to the same record, not simply that both appear somewhere in the file.

Historical observations were Serein at `wf12`, Metric Matrix at `wf0`. Neither is universal. The mapping may change after a new synchronization.

Read the identified folder's `aod/script/main.js`, `aod/script/js_asset.js`, `aod/setting.bin` and root `setting.bin`, using `adb-pull` as above and decoding each response to a separate file. Retain the manager backup too. The read allowlist deliberately restricts supported paths.

Compare native `main.js` byte-for-byte with the APK resource. Compare the other resources too. If a script is already patched or differs, identify that state before proceeding. Save the exact native original, model, build, package version, UUID, active component, folder mapping and all hashes together. Do not overwrite an existing backup.

## 5. Generate the exact known candidate locally

Replace `wfNN` below with the independently verified folder. Start with a new output directory. Select the appropriate recipe.

```powershell
python ./scripts/prepare-candidate.py --recipe ./recipes/serein.json --original C:\LOCAL_CASE\native-original.js --native-path /wf/wfNN/aod/script/main.js --out C:\LOCAL_CASE\prepared
```

Put the backed-up `js_asset.js` in the prepared directory. Keep the other backups alongside it. Inspect the difference: only AOD decorations and secondary graphics should be removed. Then run:

```powershell
node --check C:\LOCAL_CASE\prepared\candidate-main.js
node ./scripts/test-serein.cjs C:\LOCAL_CASE\prepared
# For Metric Matrix instead:
node ./scripts/test-matrice-metrique.cjs C:\LOCAL_CASE\prepared
```

Run only the simulator matching your recipe. Serein covers five styles and minute changes. Metric Matrix covers styles, palette variants and 34,560 update events. These local checks do not prove visual behavior on hardware.

## 6. Build the target-specific probe and install

The manifest carries build and package-version metadata for your inspection; the current installer enforces model, package presence and file hashes, but does not automatically enforce the build, version or UUID/folder mapping. You or your agent must verify those before writing.

```powershell
./scripts/Build-RtosProbe.ps1 -Manifest C:\LOCAL_CASE\prepared\manifest.json -WorkDir C:\LOCAL_CASE\probe-target
./scripts/Set-NativeAod.ps1 -Manifest C:\LOCAL_CASE\prepared\manifest.json -WorkDir C:\LOCAL_CASE\probe-target -Serial $serial -Action Install
```

The helper accepts only the exact original or exact candidate state for its compiled target, checks transfers and reads back the native file. On an update failure it attempts to restore the immediately preceding file. Stop if rollback is not verified. Keep the complete log private.

## 7. Confirm the actual result

Take the watch off its charger. Wake it, then let it return to AOD. Confirm just two hands, black background, correct time and unchanged awake face. Verify different hand styles if used. Record visual confirmation separately from transfer verification.

On the tested build:

```powershell
adb -s $serial shell settings get global bs_third_wf
adb -s $serial shell service call bm.manager 1
adb -s $serial shell service call bm.manager 14
adb -s $serial shell dumpsys bm.manager -ms
```

`bs_third_wf=0` indicates not classified as a third-party face. Transaction 1 is `getSmartMode`; transaction 14 is `screenControlledByMcu`. Both were observed as true/1 in the relevant successful native state. Binder transaction numbers are build-specific. Charging, an awake screen and debugging may keep Android active. An intermediate state alone does not establish MCU control.

## 8. Restoration

Keep your original, candidate, manifest and built probe together. [Follow the restoration guide](recovery.md). A successful file transfer and a successful visual reload are separate checks.
