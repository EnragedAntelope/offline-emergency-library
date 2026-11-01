# Offline Maps — How to View Them (PC or Phone)

The `OsmAnd\` folder contains offline maps of every US state/region (`.obf.zip` files).
You can use them **on a computer (no phone needed)** or **on a phone/tablet**. Both work
with **no internet**. Dependencies for each are bundled or explained below.

---

## Option 1 — On a computer (no phone) ✅ recommended if you have no phone

Everything you need is bundled — **no separate install, no Java to set up.**

1. Open `OsmAnd\MapViewer-Desktop\`.
2. Double-click **`VIEW-MAPS-ON-PC.bat`**.
   - The **first run** unzips the map files into `OsmAnd\obf\` (this can take several
     minutes and uses extra space — see note below), then opens the viewer.
   - Later runs skip straight to the viewer.
3. The **OsmAndMapCreator** window opens. Your maps are the `.obf` files in `OsmAnd\obf\`.
   Use the app's menus to open/browse a map, zoom, and search.

**Dependencies: fully handled.** This folder includes a **portable Java runtime** (`jre\`)
and the **OsmAndMapCreator** app (`app\`). Nothing else is required — it runs on any
64-bit Windows PC, offline.

> **Space note:** the maps download as compressed `.obf.zip` (~17 GB). Desktop viewing
> needs them **unzipped** to `.obf` (~30 GB), so the first run roughly doubles the map
> space. Make sure the drive has ~30 GB free before using desktop maps. (If space is
> tight, you can delete `OsmAnd\obf\` afterward; re-running the `.bat` recreates it.)

---

## Option 2 — On an Android phone/tablet

No app store or internet needed — the app is bundled.

1. Copy the OsmAnd APK from `Phone-Apps\` (e.g. `OsmAnd-XXXXXX.apk`) to your Android
   device. (See `Phone-Apps\USE-ON-PHONE` for the full phone setup, including Kiwix.)
2. On the device, tap the APK to install. You may need to allow **"Install unknown apps"**
   for your file manager/browser (Settings → Apps → special access).
3. Copy the **`.obf.zip`** map files (from `OsmAnd\`) into the OsmAnd maps folder on the
   device: typically `Android/data/net.osmand.plus/files/` — or in the OsmAnd app use
   **Menu → Configure map / Download maps → Import** and point it at the files.
4. Open OsmAnd. The maps work fully offline (navigation, search, routing).

**Dependency:** the **OsmAnd app** — bundled here as the **OsmAnd~ APK** (the free,
full-featured F-Droid build), so you can install it offline.

---

## Option 3 — On an iPhone/iPad ⚠️

Apple does **not** allow installing apps offline from a file. So:

1. **While you still have internet,** install **OsmAnd Maps** from the **App Store**
   (free). Do this now as part of preparing your kit.
2. Later, import the `.obf` map files into OsmAnd on iOS (via Files / iTunes file sharing),
   or download the regions inside the OsmAnd app while you still have a connection.

This is an Apple platform limitation — there's no offline sideloading like Android.

---

## Which should I use?

| You have… | Use | Dependency status |
|---|---|---|
| A computer, no phone | **Option 1** (desktop viewer) | ✅ fully bundled (Java + app) |
| An Android phone/tablet | **Option 2** (bundled APK) | ✅ bundled APK |
| An iPhone/iPad | **Option 3** (App Store) | ⚠️ install the app while online |

---

## Notes

- The maps are standard **OsmAnd `.obf`** vector maps — detailed roads, towns, terrain,
  and search; routing works in the phone app.
- The desktop viewer (OsmAndMapCreator) is utilitarian but fully functional for finding
  places, roads, and coordinates offline.
- Keep a **paper map** as an ultimate backup — electronics fail.
