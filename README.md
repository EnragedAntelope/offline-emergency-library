# 🛟 Offline Emergency Library

**A complete, offline, no-internet "survival knowledge" kit you can download with a single
command.** Built for emergencies, grid-down scenarios, remote areas, or anyone who wants a
self-contained offline reference + AI on a drive.

One command asks you **only one thing — where to save the files — then downloads
everything** and writes all the documentation (Markdown **and** HTML). After that, it all
works with **no internet**.

---

## What you get

| Component | What it is | Size (approx) | Needs to run |
|---|---|---|---|
| **Offline AI chat** | 3 local AI models (Llama 3.2 3B, Llama 3.1 8B, Qwen2.5 7B) + CPU & GPU engines (llama.cpp) | ~11 GB | CPU only (GPU optional) |
| **Offline doc-Q&A** | GPT4All — ask an AI questions about your PDFs, with citations | ~0.7 GB | CPU, one-time install |
| **Wikipedia** | Full English Wikipedia article text (compressed) | ~24 GB | Kiwix (or archival) |
| **Offline US maps** | Every US state/region map for the OsmAnd app | ~17 GB | OsmAnd app (phone) |
| **Repair archive** | iFixit — cars, appliances, electronics, phones | ~3.4 GB | Kiwix |
| **DIY archive** | Appropedia — plumbing, electrical, construction, energy, water, food | ~0.6 GB | Kiwix |
| **Medical** | Offline medical Wikipedia (WikiMed) + curated medical guide | ~1.8 GB | Kiwix |
| **Survival** | Post-disaster, water, food prep, knots (zimgit) | ~0.8 GB | Kiwix |
| **Army manuals** | Public-domain US Army field/technical manuals (survival, first aid, hand tools, carpentry, auto mechanics, rigging, field cooking) | ~0.2 GB | Any browser (PDF) |
| **Medical books** | *Where There Is No Doctor / No Dentist*, *Ship's Medicine Chest* | ~45 MB | Any browser (PDF) |
| **Radio guide** | How ham/CB/shortwave/GMRS radio works + emergency comms | tiny | Any browser |
| **Kiwix reader** | Portable app to read all `.zim` archives (no install) | ~0.15 GB | — |
| **Total** | | **≈ 60 GB** | |

Everything is **free and legally redistributable** — open-weight AI models, openly-licensed
Kiwix archives, and public-domain US-government manuals. **No piracy.**

---

## 📦 Storage requirements — what kind of drive do I need?

The full library is **~60 GB**. Always leave headroom (for the AI's temp files, GPT4All
install, and future updates), so plan for more than 60 GB.

| Drive | Recommendation |
|---|---|
| **Minimum** | **128 GB** drive (full library + working room) |
| **Comfortable** | **256 GB** drive (room to add your own files, Survivor Library, etc.) |
| **USB flash drive** | Works for **storage + reading** PDFs/Wikipedia/maps. Use **USB 3.0+ / 128 GB+**. Cheap flash drives are slow — fine for reading, slow for AI. |
| **External SSD** ⭐ | **Best choice.** Running the AI models from an SSD is far faster than from a flash drive or spinning disk. A 256 GB+ USB-C SSD is ideal. |
| **Internal HDD/SSD** | Perfect if you're keeping it on a PC. |

> **Tip:** If you only want the reference material (no AI), you can skip the big pieces
> with `-SkipModels` and still get Wikipedia, maps, and all manuals in ~30 GB. If you also
> skip Wikipedia and maps (`-SkipWikipedia -SkipMaps`), the AI + manuals fit in ~20 GB.

---

## 💻 Hardware requirements — what machine do I need to USE it?

**To download:** any Windows 10/11 (64-bit) PC with internet and `curl` + PowerShell
(both built into Windows). Downloading ~60 GB can take a few hours.

**To use it afterward (offline):**

| Task | Needs |
|---|---|
| Read PDFs, HTML guides, Wikipedia, maps | **Any computer** with a web browser. Even an old/weak PC. |
| Read `.zim` archives | **Kiwix** (bundled, portable). Any Windows PC. |
| **Offline AI — small model (3B)** | Any 64-bit PC, **~4 GB RAM**. Works on CPU; no graphics card needed. |
| **Offline AI — big model (8B)** | **~8 GB RAM** recommended. CPU only. |
| **Offline AI — GPU model (Qwen 7B)** | A graphics card with **~6 GB VRAM** (NVIDIA/AMD/Intel) for a big speed boost. Optional. |
| **GPT4All doc-Q&A** | 64-bit PC, ~8 GB RAM recommended. CPU only. Self-contained (no Python/CUDA). |
| **Maps** | The free **OsmAnd** app on a phone/tablet (copy the map files to it). |

**Key points:**
- **No GPU is required** for the AI — it runs on an ordinary CPU (just slower). A 6 GB GPU
  is a bonus.
- The AI engine ships **x64, ARM64, and Vulkan-GPU** builds, so it runs on Intel/AMD and
  ARM Windows machines.
- The whole kit is **portable** — copy the `OfflineLibrary` folder to any PC and use it.

---

## 🚀 How to download (pick one)

### A) Easiest — double-click `install.bat`
Download/clone the repo, then **double-click `install.bat`**. It opens a window, asks you
where to save, and downloads everything. No commands, no PowerShell knowledge needed.
(If Windows SmartScreen warns, click **More info → Run anyway**.)

### B) In Claude Code (one prompt)
Install this repo's skill, then say:
```
/offline-emergency-library
```
It will ask **only**: *"Where would you like to save these files?"* — then download
everything.

### C) PowerShell one-liner (no Claude needed)
```powershell
irm https://raw.githubusercontent.com/elhajahmadj/offline-emergency-library/main/Get-OfflineLibrary.ps1 | iex
```
It will prompt you for the save location, then download everything.

### D) Clone and run
```powershell
git clone https://github.com/elhajahmadj/offline-emergency-library.git
cd offline-emergency-library
./Get-OfflineLibrary.ps1 -Destination "E:\"
```

**All methods are resumable** — if the download is interrupted, run the same command again
and it continues where it left off.

---

## 🧭 After it finishes

Open **`START-HERE.html`** in the destination folder (`<your path>\OfflineLibrary\`). It
indexes everything and links to each component's guide:

- `AI-Offline\HOW-TO-RUN-OFFLINE-AI.html` — run the offline AI chat
- `AI-Offline\DocReader-GPT4All\HOW-TO-ASK-YOUR-DOCS.html` — ask AI about your PDFs
- `Kiwix-Reader\HOW-TO-USE-KIWIX.html` — read the `.zim` archives
- `Manuals\READ-ME-FIRST.html` and `Medical\READ-ME-FIRST.html`
- `Manuals\Radio-Communications\RADIO-GUIDE.html` — emergency radio comms

---

## Options (optional, for small drives)

| Flag | Effect | Saves |
|---|---|---|
| `-SkipWikipedia` | Don't download the 24 GB Wikipedia dump | ~24 GB |
| `-SkipMaps` | Don't download the US OsmAnd maps | ~17 GB |
| `-SkipModels` | Skip the large 8B/7B AI models (keeps the small 3B) | ~9 GB |

Example: `./Get-OfflineLibrary.ps1 -Destination "F:\" -SkipWikipedia -SkipMaps`

---

## ⚠️ Disclaimers

- Offline AIs and older manuals **can be wrong or outdated**. Verify anything
  safety-critical (medical, electrical, structural) against authoritative sources when
  possible. This kit is reference material, **not** professional advice.
- Modern copyrighted code books (NEC/UPC) and brand auto manuals (Haynes/Chilton) are
  **not** included. Their topics are covered by the openly-licensed iFixit/Appropedia
  archives and public-domain Army technical manuals.
- Respect your local laws for radio transmission (listening is always fine; see the radio
  guide).

## License
Code and documentation in this repo: **MIT** (see `LICENSE`). Downloaded content retains
its original licenses (open-weight model licenses, CC licenses for Kiwix content, public
domain for US-government works).
