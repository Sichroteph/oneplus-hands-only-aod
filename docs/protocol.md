# Native RTOS access

The official Android watch-face APK and the resources executed by the low-power MCU are separate. Keeping the signed official APK while editing its existing RTOS AOD resources avoids replacing it with a personally signed third-party APK.

On the tested firmware, a Java helper launched by ADB shell accesses the Android Binder `mcu` service and `android.app.wear.IMcuManager`. It opens `createDataEventConnection("com.android.shell", listener)`, registers message class 18 and message type 0x1201. MCU replies use 0x1202.

The payload transports ADB packets (CNXN, OPEN, WRTE, OKAY, CLSE). Opening `sync:` supports file RECV and SEND. The helper acknowledges WRTE packets, reassembles fragmented packets, writes in 1024-byte blocks and checks the resulting file. Native read responses are base64-encoded to preserve binary content through shell output.

The listener descriptor is discovered by reflection; the observed descriptor was `com.oppo.sensorhub.service.ISensorDataChangedListener`. The MCU greeting may say "oppo watch4", "OPPO" or "mido". It is not proof of the watch's physical model. Verify identity with Android properties.

The manager at `/wf/wf_manager_config.txt` is binary. Match UUID and folder in the corresponding record, then compare native files to the APK. No general-purpose automated manager parser is supplied. The scripts intentionally restrict paths and the native shell command allowlist.

On this build `getAodMode()` returned 0 even when the AOD rendered; it is not a useful stand-alone verification. Use readback, physical appearance, official package/classification and actual MCU screen control as separate observations.

## Related research

* [OnePlus Watch 3 firmware analysis](https://github.com/zekog/oneplus-watch-3-firmware-dump)
* [Community OPPO watch-face toolkit](https://github.com/TeslaCN/oppo-watch-face-dev), a different watch and environment, not a compatibility guarantee

The native transfer and the two modifications described here were tested on the physical OPWWE251. Related projects provided research context; they should not be assumed to provide this exact validated workflow.
