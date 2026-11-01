# Battery observations

Recorded on 31 October 2026 from Android battery history on the owner's watch. AOD is enabled using the owner's normal settings. The active official package at capture was Serein; third-party classification was 0.

| Interval, local watch time | Level | Loss | Duration | Extrapolated full-battery duration |
|---|---|---|---|---|
| 28 Oct 23:40 to 31 Oct 07:07 | 78% to 32% | 46 points | 55.44 hours | 5.02 days |
| 29 Oct 05:20 to 30 Oct 05:11 | 77% to 54% | 23 points | 23.86 hours | 4.32 days |
| 30 Oct 05:11 to 31 Oct 05:09 | 54% to 33% | 21 points | 23.96 hours | 4.75 days |
| 31 Oct 07:23 to 20:45 | 70% to 59% | 11 points | 13.37 hours | 5.07 days |

The intervals overlap; they are not four independent trials. No charge was recorded within the 55.44-hour interval. A morning top-up on 31 October ran approximately 07:07 to 07:23, from 32% to 70%.

Calculation: `estimated days = interval hours / (percentage points lost / 100) / 24`.

The result is approximately **4 to 5 days of extrapolated battery life with AOD enabled** in this use pattern. It is not a completed 100% to 0% endurance run. The owner normally uses short top-ups. Nighttime behavior is included in the multi-day interval; some level updates are deferred until wake-up, so the history should not be interpreted as zero nighttime consumption.

The records describe the modified watch's consumption. They do not separately quantify the before/after savings from removing decorations. Raw dumps contain private app/activity information and are deliberately not distributed.
