# Instructions for an assistant using this knowledge base

Goal: help the owner reproduce a native hands-only AOD while retaining the original official OnePlus watch-face package.

1. Read README.md, docs/tutorial.md, compatibility.md and recovery.md before interacting with hardware. Explain the tested scope. The disclaimer does not replace the user's authorization for device changes.
2. Use an explicit ADB serial and verify physical model, build, package version and active component after reconnecting. Do not target a phone or infer watch identity from the MCU greeting.
3. Begin with read-only inspection. Identify the UUID/folder mapping on this watch and compare exact native resources with its APK. Never assume wf0 or wf12.
4. Store APKs, native backups and logs privately outside the repository. Never commit pairing codes, network addresses, raw battery logs, complete vendor scripts, APKs, firmware or image packs.
5. Use recipes only on their exact original hash. Keep an immutable original and restoration files. Do not weaken guards to accept an unknown revision.
6. Preserve hand geometry, calculations, user hand styles, minute anti-burn-in movement and the normal awake face. Scope writes to the identified AOD main.js only. No root, flash, firmware changes or unrelated settings.
7. Run the matching local simulator and syntax checks. Inspect the diff. Compile a target-specific probe from the verified manifest. The installer does not automatically enforce build/version/UUID mapping; check those explicitly before installation.
8. Act only within the user's authorized task. Independently distinguish transfer verification, visual reload, native classification and effective MCU screen control. Ask the owner for visual confirmation when a reliable native capture is unavailable.
9. Stop on unknown hashes, ambiguous mappings, failed readback or unverified rollback. Do not blindly repeat writes or automatically change faces.
10. Record each new supported revision as a separate case with model/build/package/version, UUID mapping evidence, before/after hashes, local tests, exact readback and user visual confirmation. Mark unknowns explicitly.

No universal installer or compatibility with other firmware is implied. Battery estimates are extrapolations from measured consumption, not a completed full-discharge experiment or a measured before/after saving.
