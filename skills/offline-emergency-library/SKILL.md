---
name: offline-emergency-library
description: >
  Download a complete offline, no-internet "emergency library" to a drive the user
  chooses: an offline AI (chat models + CPU/GPU engine), an offline document-Q&A app
  (GPT4All), full Wikipedia article text, offline US maps (OsmAnd), survival/repair/
  medical archives (Kiwix ZIM: iFixit, Appropedia, WikiMed, survival/water/food/knots),
  public-domain US Army field manuals + medical PDFs, the Kiwix reader, launchers, and
  full documentation (Markdown + HTML). Invoke for requests like "download the offline
  emergency library", "/offline-emergency-library", "set up my offline survival kit",
  "get the offline AI + Wikipedia + maps + manuals". The ONLY thing to ask the user is
  where to save the files.
---

# Offline Emergency Library — one-shot downloader

When this skill is invoked, your job is simple:

1. **Ask exactly one question:** *"Where would you like to save these files?"*
   (e.g. a drive letter like `E:\`, or a folder path, or a USB/external drive path.)
   Do **not** ask anything else — no component menus, no confirmations.
2. **Run the downloader** with that path. From the repo root:
   ```powershell
   ./Get-OfflineLibrary.ps1 -Destination "<the path the user gave>"
   ```
   If you are not in the repo, fetch and run it:
   ```powershell
   $s = Join-Path $env:TEMP 'Get-OfflineLibrary.ps1'
   curl.exe -sL https://raw.githubusercontent.com/elhajahmadj/offline-emergency-library/main/Get-OfflineLibrary.ps1 -o $s
   powershell -NoProfile -ExecutionPolicy Bypass -File $s -Destination "<path>"
   ```
3. The script creates `<path>\OfflineLibrary\`, downloads everything (resumable), writes
   the launcher `.bat` files, and generates all docs as Markdown **and** HTML. It logs to
   `<path>\OfflineLibrary\_download.log`.
4. When it finishes, tell the user to open **`START-HERE.html`** in the destination.

## Notes for the assistant
- The full library is **~60 GB** and can take hours depending on the connection. It is
  **resumable** — if interrupted, just run the same command again.
- The script auto-resolves the **latest** versions (llama.cpp engine, Kiwix reader,
  GPT4All, and the ZIM archives) so it keeps working over time.
- Platform: **Windows (PowerShell + curl)**, which is built in on Windows 10/11.
- Everything downloaded is **free and legally redistributable**: open-weight AI models,
  openly-licensed Kiwix archives, and public-domain US-government manuals. No piracy.
- If the user is low on disk space, you *may* mention the optional flags
  `-SkipWikipedia`, `-SkipMaps`, `-SkipModels` — but do not prompt for them unless asked.

See `README.md` for the full contents list, storage/hardware requirements, and how to
use each component after downloading.
