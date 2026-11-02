# Kolibri — Offline Learning App (smaller, selectable courses)

**Kolibri** is a free offline learning platform from Learning Equality. Unlike the
all-in-one Khan Academy archive (one giant ~168 GB file), Kolibri lets you **choose exactly
which subjects/channels to download and at what video quality** — so you can build a course
library in the **tens of GB** (or smaller) instead of hundreds.

This is the **"pick what you want" education option.** The big all-in-one option is the
Khan Academy Kiwix archive (see `Education\READ-ME-FIRST`). You can use either or both.

> Added only if you ran the installer with `-Kolibri` / `--kolibri`. If you see installer
> files in `Education\Kolibri\`, you're set.

---

## 1. Install the Kolibri app (offline)

Pick the file in `Education\Kolibri\` for your system:

| System | File | Install |
|---|---|---|
| Windows | `kolibri-*-windows-setup.exe` | Double-click, follow the wizard |
| macOS | `kolibri-*.dmg` | Open, drag Kolibri to Applications |
| Debian/Ubuntu Linux | `kolibri_*_all.deb` | `sudo apt install ./kolibri_*_all.deb` |
| Other Linux | `kolibri-*.pex` | Needs Python 3: `python3 kolibri-*.pex start` |
| Android | `kolibri-*.apk` (in `Phone-Apps\`) | Copy to phone, tap to install |

Launch Kolibri. The first run creates a facility/admin account (local only) and opens the
app in your browser at `http://127.0.0.1:8080`.

---

## 2. Import content (this is where you pick size)

Kolibri content is organized into **channels** (Khan Academy, CK-12, Blockly, etc.). You
import only what you want:

1. Sign in as the admin you created.
2. Go to **Device → Channels → Import** (or the "+" / Import button).
3. Choose the source:
   - **Kolibri Studio** (online catalog) — browse channels like **Khan Academy**, pick the
     channel, then **select specific topics/subjects** instead of the whole thing.
   - **Local drive / another Kolibri** — if you already have content on a USB.
4. When prompted, **choose the lower video quality** to save a lot of space.
5. Import. You can add more channels/subjects later.

> **Do the import while you still have internet** (Kolibri Studio is online). Once imported,
> it all works **offline**. Pick a few key subjects + low-res video to stay in the tens of
> GB; grab everything only if you have the space.

---

## 3. Use it (offline)

- Open Kolibri (desktop app or the Android app) → learn from your imported channels, fully
  offline. Multiple learners/profiles are supported.
- To share with other devices on a local network, Kolibri can act as a server — other
  devices browse to your machine's address. (Optional; not required for single-device use.)

---

## Kolibri vs. the Khan Academy archive — which should I use?

| | Kolibri (`--kolibri`) | Khan Academy ZIM (`--education`) |
|---|---|---|
| Size | **You choose** — tens of GB or less | ~168 GB (all, incl. video) |
| Pick subjects / quality | **Yes** | No (all-or-nothing) |
| Setup | Install app + import channels (online once) | Drop-in file, open in Kiwix |
| Extra dependency | The Kolibri app | None (Kiwix already bundled) |
| Best for | A tailored course library | One-shot "grab everything" |

Both are free and openly licensed. Use Kolibri if you want a **smaller, curated** set; use
the Khan Academy archive if you want **everything in one file** and have the space.
