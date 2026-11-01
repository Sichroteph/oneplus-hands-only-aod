# I just wanted the hands. So I stripped the stock OnePlus Watch 3 AOD: classy, and the best AOD battery life I've had.

Hi,

I tried every official OnePlus face available on my Watch 3, looking for a very ambitious feature: just the hands on a black background.

There was always some faint background or decoration left in AOD. I find the hands alone much nicer, but I also wanted to keep the native low-power chip doing its job.

The interesting part is that the official watch face is signed by OnePlus. Rebuilding and signing it yourself loses that official signature. But it also has a separate AOD implementation running on the low-power RTOS chip, and that rendering is controlled by a JavaScript file. That's the file I modified, leaving the signed Android APK intact.

I've done this with Serein and Metric Matrix. The video shows the result: the normal face when awake, just the hands in AOD, with native low-power operation retained. No root or firmware flash. The anti-burn-in movement is preserved too.

With AOD enabled, my recorded battery drain works out to roughly **4 to 5 days by extrapolation**. One interval was 78% to 32% over about 55.5 hours without charging. Pretty happy with that for something I mainly did because I disliked a background.

I've documented the method, backups and restoration, with tools and instructions for either doing it yourself or working through it with an AI assistant. Tested on my Watch 3, firmware A.165. Experimental and at your own risk.

GitHub: https://github.com/Sichroteph/oneplus-hands-only-aod
