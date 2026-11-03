# Radio Frequency Reference

**US baseline - checked 2026-11-03. All frequencies below are in MHz.**
Save this file with its HTML companion; open the HTML in a browser and use
**Print / Save as PDF**. All tables and notes are included offline. Source links
are for checking updates while online. See the [Radio Guide](RADIO-GUIDE.html)
([Markdown](RADIO-GUIDE.md)) for equipment and calling procedures.

**Before transmitting:** follow the rules for your country, radio service,
license, equipment and location. Receiving public broadcasts generally needs no
transmit license; local scanner, interception and disclosure restrictions may
still apply. An amateur license does not authorize marine, aviation or GMRS
transmissions. Emergency exceptions are service-specific, not blanket permission
to transmit anywhere. FCC 97.403/97.405 concern amateur stations. [1]

**Region matters:** these personal-radio channel numbers and amateur privileges
are US FCC references. They are not a worldwide allocation table. Marine radio
US/International/Canada settings can change channel behavior. Check the national
regulator and local channel/band plan before traveling or programming transmit
memories. A calling frequency is not a promise that anyone is listening.

## NOAA Weather Radio - receive only

Tune by **frequency**, not just a receiver's WX preset number: NOAA explicitly
notes that manufacturers use different numbering schemes. Scan these FM weather
broadcasts and save the strongest local station. They are not two-way help
channels. SAME geographic alert codes are separate from frequency selection. [2]

| Frequency | Frequency |
|---|---|
| 162.400 | 162.500 |
| 162.425 | 162.525 |
| 162.450 | 162.550 |
| 162.475 | |

## FRS and GMRS - US shared channels

FM voice. FRS is license-by-rule using compliant FRS equipment; GMRS normally
requires an individual FCC license and compliant GMRS equipment. The channel
number alone does not determine a radio's lawful power or service. [3]

| Channel | MHz | Channel | MHz |
|---|---|---|---|
| 1 | 462.5625 | 12 | 467.6625 |
| 2 | 462.5875 | 13 | 467.6875 |
| 3 | 462.6125 | 14 | 467.7125 |
| 4 | 462.6375 | 15 | 462.5500 |
| 5 | 462.6625 | 16 | 462.5750 |
| 6 | 462.6875 | 17 | 462.6000 |
| 7 | 462.7125 | 18 | 462.6250 |
| 8 | 467.5625 | 19 | 462.6500 |
| 9 | 467.5875 | 20 | 462.6750 |
| 10 | 467.6125 | 21 | 462.7000 |
| 11 | 467.6375 | 22 | 462.7250 |

| Channels | FRS maximum ERP | GMRS maximum |
|---|---|---|
| 1-7 | 2 W | 5 W ERP |
| 8-14 | 0.5 W | 0.5 W ERP; handheld portable units only |
| 15-22 | 2 W | 50 W transmitter output; fixed stations 15 W |

ERP includes antenna effects; transmitter output is a different measurement.
These are regulatory maxima, not recommended settings. FRS radios have
non-removable antennas and cannot operate through GMRS repeaters. "Privacy
codes" (CTCSS/DCS) only filter what your speaker hears; they do not make a
channel private. No FRS/GMRS channel has a guaranteed emergency watch. [3]

### GMRS repeaters - confirm the local configuration

Conventional **+5 MHz** input/output pairings are shown below. The FCC lists the
authorized 462 and 467 MHz main frequencies; this table pairs them in the usual
same-order repeater configuration. Confirm the repeater's actual input, output,
access permission and tones locally. Equipment memory labels such as "23-30"
are not universal channel identifiers. [3]

| Shared channel / output | Receive: repeater output | Transmit: repeater input |
|---|---|---|
| 15 | 462.5500 | 467.5500 |
| 16 | 462.5750 | 467.5750 |
| 17 | 462.6000 | 467.6000 |
| 18 | 462.6250 | 467.6250 |
| 19 | 462.6500 | 467.6500 |
| 20 | 462.6750 | 467.6750 |
| 21 | 462.7000 | 467.7000 |
| 22 | 462.7250 | 467.7250 |

Do not confuse the 467 MHz **main** repeater inputs above with shared channels
8-14. Mobile/handheld/control transmissions on these main inputs are for repeater
communications or permitted brief tests, not ordinary simplex conversation. [3]

## MURS - US only

License-by-rule with compliant MURS equipment; maximum **2 W transmitter output**
on every channel. For analog FM, use the radio's proper MURS setting; occupied
bandwidth limits are listed rather than ambiguous "wide/narrow" menu names. [4]

| Channel | Frequency | Maximum occupied bandwidth |
|---|---|---|
| 1 | 151.820 | 11.25 kHz |
| 2 | 151.880 | 11.25 kHz |
| 3 | 151.940 | 11.25 kHz |
| 4 | 154.570 | 20.0 kHz |
| 5 | 154.600 | 20.0 kHz |

## Marine VHF - select the correct country channel group

Use a marine radio for marine service, not for casual land communications.
The following is a **selected US operational reference**, not the complete
international marine channel plan. Voice entries use FM simplex: ship transmit
and receive frequencies are the same. Channel 70 is digital, not voice. [5]

| Channel | Frequency | Use |
|---|---|---|
| **16** | **156.800** | International distress, urgency, safety and initial calling; move working traffic when directed |
| **70** | **156.525** | DSC digital distress/safety/calling only; **never voice** |
| 13 | 156.650 | Bridge-to-bridge navigation safety; normally 1 W, with rule-specific exceptions |
| 6 | 156.300 | Intership safety and coordinated ship-aircraft search and rescue |
| 9 | 156.450 | US noncommercial vessel calling; not the initial distress channel |
| 22A / 1022 | 157.100 | US Coast Guard liaison/working channel after initial contact or instructions |

**22A / 1022 is the simplex ship-frequency channel**, not international duplex
channel 22. ITU's four-digit convention prefixes "10" to identify use of the
ship frequency alone; older US radios commonly show the "A" suffix. [5, 6]

Local Vessel Traffic Service and bridge-to-bridge rules can override a generic
list. In specified lower Mississippi waterways, covered vessels use **67,
156.375** for bridge-to-bridge service rather than 13; consult the exact
geographic limits in 33 CFR 26.03(e). Do not improvise a DSC distress test:
learn the radio's test procedure and program its correct MMSI beforehand. [5]

## Aviation and distress beacons - different equipment and modes

| Frequency | Equipment / mode | Purpose |
|---|---|---|
| **121.500** | Aviation AM voice | Civil aviation emergency/guard; if already communicating with ATC, use that frequency first |
| 243.000 | Aviation UHF AM voice | Emergency/guard, particularly military; ordinary VHF airband radios cannot tune it |
| **406 MHz band** | Approved EPIRB / ELT / PLB; digital beacon | Satellite distress alert, **not a voice calling channel** |
| 121.5 beacon signal | Beacon homing transmitter | Local search-team homing; separate from 406 MHz satellite alerting |

EPIRB = maritime beacon; ELT = aircraft beacon; PLB = personal locator beacon.
Register a 406 MHz beacon, keep the registration current, and use its approved
self-test procedure. Activate for genuine distress according to its instructions;
do not try to send beacon messages using a programmable voice radio. [7, 8]

Cospas-Sarsat stopped satellite detection of **121.5/243 MHz analog beacon
alerts in 2009**. This did **not** discontinue aviation emergency voice on those
frequencies, or local homing. A scanner hearing 121.5 is not a satellite alert
receiver. Marine rules prohibit voice telephony on 243 MHz. [5, 7, 8]

## Amateur radio - calling frequencies and band-plan summary

**US stations / ITU Region 2 baseline.** A license, permitted mode and suitable
equipment are required. ARRL/IARU band plans guide coordination; FCC rules set
the legal limits. Local repeater coordinators and emergency nets may use
different channels. Listen first; give priority to existing emergency traffic.
**There is no universal amateur distress channel or guaranteed rescue watch.**

| Frequency | Mode | Role / region |
|---|---|---|
| 29.600 | FM simplex | 10 m calling; US General or higher for FM here |
| 52.525 | FM simplex | US 6 m primary simplex |
| 146.520 | FM simplex | US 2 m national simplex calling |
| 446.000 | FM simplex | US 70 cm national simplex |
| 7.240 / 7.275 | LSB voice | IARU Region 2 emergency centers of activity |
| 14.300 | USB voice | IARU global emergency center of activity |
| 18.160 | USB voice | IARU global emergency center of activity |
| 21.360 | USB voice | IARU global emergency center of activity |

Emergency centers of activity are **places to look for traffic**, not exclusive
channels, mandatory nets or dispatch services. HF entries require US General
or higher voice privileges. "Global" describes IARU coordination, not permission
to transmit outside your national allocation or license. [9, 10, 11]

### Selected US bands and General-class voice segments

This compact plan covers common HF/VHF/UHF emergency equipment, not every
amateur allocation. Limits below are **band edges**, not safe dial settings:
keep the entire transmitted signal within your authorized segment. [9]

| Band | US band limits | General-class voice segment |
|---|---|---|
| 160 m | 1.800-2.000 | 1.800-2.000 |
| 80/75 m | 3.500-4.000 | 3.800-4.000 |
| 40 m | 7.000-7.300 | 7.175-7.300 |
| 30 m | 10.100-10.150 | No voice; CW/data |
| 20 m | 14.000-14.350 | 14.225-14.350 |
| 17 m | 18.068-18.168 | 18.110-18.168 |
| 15 m | 21.000-21.450 | 21.275-21.450 |
| 12 m | 24.890-24.990 | 24.930-24.990 |
| 10 m | 28.000-29.700 | 28.300-29.700; follow mode/bandwidth subbands |
| 6 m | 50.000-54.000 | 50.100-54.000; local band plan |
| 2 m | 144.000-148.000 | 144.100-148.000; local band plan |
| 1.25 m | 222.000-225.000 | 222.000-225.000; local band plan |
| 70 cm | 420.000-450.000 | 420.000-450.000; geographic/sharing limits |

Technicians have voice privileges on the listed VHF/UHF bands, subject to the
same mode and local restrictions. Their HF voice privilege is **28.300-28.500
SSB, 200 W PEP maximum**; it does not include 29.600 FM or the HF emergency
activity centers above. Extra/Advanced privileges differ from the General
segments. **60 m has special channel/segment, power and emission rules** that
changed in 2026; consult current 97.303(h), 97.305 and 97.313 rather than an old
five-channel card. The separate 219-220 MHz amateur allocation is data-only,
not included as a voice band here. [9]

Before relying on a repeater, record its output, input/offset, tone, owner
permission and fallback simplex channel. Do not assume every 2 m or 70 cm
repeater uses the same offset or that it has backup power.

## Fill in your local plan before an outage

| Item | Your local information |
|---|---|
| Country / region and date checked | __________________________________ |
| NOAA station frequency / SAME areas | __________________________________ |
| Family channel / frequency / mode | __________________________________ |
| Backup channel / check-in times | __________________________________ |
| Repeater RX / TX / tone / permission | __________________________________ |
| Local emergency net / schedule / mode | __________________________________ |
| Marine channel group / local VTS | __________________________________ |
| Call sign / beacon registration reminder | __________________________________ |

## Sources and update checks

Checked **2026-11-03**. Numeric regulatory data is US federal-government material;
the explanatory text and compact tables here are an original summary. ARRL and
IARU are cited for operating conventions; their charts are not reproduced.
Regulations and local assignments can change. Recheck these references before
programming transmitters and print your local plan while online.

1. FCC, amateur emergency provisions: [47 CFR 97.403](https://www.ecfr.gov/current/title-47/section-97.403)
   and [97.405](https://www.ecfr.gov/current/title-47/section-97.405).
2. NOAA/NWS, [Weather Radio frequencies and channel-number warning](https://www.weather.gov/marine/wxradio).
3. FCC, [FRS channels, 95.563](https://www.ecfr.gov/current/title-47/section-95.563);
   [power, 95.567](https://www.ecfr.gov/current/title-47/section-95.567);
   [antenna, 95.587](https://www.ecfr.gov/current/title-47/section-95.587);
   [GMRS channels, 95.1763](https://www.ecfr.gov/current/title-47/section-95.1763);
   [power, 95.1767](https://www.ecfr.gov/current/title-47/section-95.1767);
   licensing: [95.305](https://www.ecfr.gov/current/title-47/section-95.305),
   [95.1705](https://www.ecfr.gov/current/title-47/section-95.1705).
4. FCC, MURS [channels, 95.2763](https://www.ecfr.gov/current/title-47/section-95.2763),
   [power, 95.2767](https://www.ecfr.gov/current/title-47/section-95.2767),
   [bandwidth, 95.2773](https://www.ecfr.gov/current/title-47/section-95.2773).
5. FCC, marine [80.369(e)](https://www.ecfr.gov/current/title-47/section-80.369),
   [80.373(f) and table footnotes](https://www.ecfr.gov/current/title-47/section-80.373),
   [power, 80.215(g)](https://www.ecfr.gov/current/title-47/section-80.215),
   [prohibited transmissions, 80.89](https://www.ecfr.gov/current/title-47/section-80.89);
   USCG, [bridge-to-bridge rules, 33 CFR 26.03(e)](https://www.ecfr.gov/current/title-33/section-26.03).
6. ITU-R, [M.1084-5](https://www.itu.int/dms_pubrec/itu-r/rec/m/R-REC-M.1084-5-201203-I!!PDF-E.pdf),
   Annex 4 section 3 (printed page 12): four-digit simplex numbering;
   Annex 3 section 2.9.2: channel 70 DSC.
7. FAA AIM, [6-3-1(h), emergency frequencies](https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap6_section_3.html)
   and [6-2-4, ELTs](https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap6_section_2.html).
8. NOAA SARSAT, [406 MHz emergency distress beacons](https://www.sarsat.noaa.gov/emergency-406-beacons/).
9. FCC, amateur [bands, 97.301](https://www.ecfr.gov/current/title-47/section-97.301),
   [sharing, 97.303](https://www.ecfr.gov/current/title-47/section-97.303),
   [emissions, 97.305](https://www.ecfr.gov/current/title-47/section-97.305),
   [standards, 97.307](https://www.ecfr.gov/current/title-47/section-97.307),
   [power, 97.313](https://www.ecfr.gov/current/title-47/section-97.313).
10. ARRL, [voluntary band plans](https://www.arrl.org/band-plan):
    10 m, 6 m, 2 m and 70 cm calling/simplex entries.
11. IARU Region 2, [September 2020 band plan](https://www.iaru-r2.org/wp-content/uploads/2020/02/IARU-Region-2-Band-plan.pdf),
    40 m, 20 m, 17 m and 15 m emergency centers of activity. These are
    coordination conventions, not frequency reservations or legal privileges.
