# Contributing

Thanks for helping make the Offline Emergency Library better! Contributions of all sizes
are welcome — code, docs, testing, new regions, bug reports.

## Good ways to help right now
- **Test an installer on real hardware** (especially **macOS** and **Linux** — the scripts
  are syntax-checked but need real-world runs). Report what worked / what broke.
- **Improve docs** — clarity, typos, translations of the guides.
- **Add map region aliases** (e.g. `UK` → `Great-britain`, `USA` → `US`).
- **Report broken upstream sources** (a model, ZIM, or map URL that changed).

Look for issues labeled **`good first issue`** and **`help wanted`**.

## Project layout
- `Get-OfflineLibrary.ps1` — Windows installer (PowerShell)
- `get-offline-library.sh` — macOS/Linux installer (Bash)
- `build-readme-index.ps1` — generates the root `README.html` index
- `docs/` — all guides as `.md` **and** pre-rendered `.html` (keep both in sync)
- `skills/offline-emergency-library/SKILL.md` — the Claude Code skill

## Ground rules
- **Keep the two installers in parity.** A change to one usually needs the same change in
  the other. Note in your PR if you intentionally only touched one.
- **Only free / openly-licensed / public-domain content.** No piracy, no copyrighted code
  books or brand manuals.
- **Edit `docs/*.md`, then regenerate the matching `.html`** so they stay consistent.
- **Keep line endings correct:** `.ps1`/`.bat` = CRLF, `.sh` = LF (enforced by
  `.gitattributes`).
- Keep the default behavior intact: the installer asks **only** where to save, and maps
  default to **US**.

## Before you open a PR
- `bash -n get-offline-library.sh` passes.
- PowerShell parses (`[System.Management.Automation.Language.Parser]::ParseFile(...)`).
- CI (lint + upstream link check) is green.

## Reporting bugs
Open an issue using the template and include your **OS**, **install method**, **region**,
and the relevant lines from the `_download.log` in your destination folder.
