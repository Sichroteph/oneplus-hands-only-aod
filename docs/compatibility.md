# Known configurations

Validated on one personal OnePlus Watch 3 OPWWE251, build OPWWE251_11_A.165, on 15 October 2026.

| Case | Package | Version | Observed folder, not a constant |
|---|---|---|---|
| Serein | com.oplus.wearos.watchface.silence | 3000243 / 3.0.0.243_5019ebe_240919 | /wf/wf12/ |
| Metric Matrix | com.oplus.wearos.watchface.fuzazujian | 3020087 / 3.0.2.87_b9b0160_251117 | /wf/wf0/ |

Serein UUID: `3d02cfd1eb68c553fd9a19097c8aa114`.

Metric Matrix UUID: `d66a97ceff374140beb319370659933e`.

## Exact script fingerprints

Serein original: `317743f9b691ae8f45d8fd763925b3957f5790bae97a585b1bc0d0a892944380`

Serein candidate: `970870a7dc794da746a8ac640c7224e7d2b05f653cd281b759125f995f087ddd`

Metric Matrix original: `d8040e944f7f7088d635edb97a839cf7f80f6d8ae06e26f40b33d8fe5ff82ab9`

Metric Matrix candidate: `328dea6769aa6634a250605e3a676d209594346b3d6f777ba20b460dd1061a5a`

## Evidence

Serein: exact native readback, five original hand styles retained, black background and only the hour/minute hands visually confirmed. Official package active and native classification retained. Effective MCU screen control after unplugging was not separately measured in its original installation log.

Metric Matrix: exact native readback, two hands on black visually confirmed, official package retained, native classification and effective MCU screen control confirmed. Its four styles and palette branches were tested locally.

A separate Metric Matrix experiment used native Line objects for thin hands and then a central ring. The thin hands were visually confirmed; the ring revision had exact transfer verification, with specific visual confirmation still pending in the recorded session. Those optional revisions are not included in these two stock-hand recipes.

Unknown: other models, other firmware builds, other script hashes, persistence after reboot or resynchronisation. Do not infer compatibility from a similar face name or screen size.
