# Roadmap

Ideas for where this is headed. Nothing here is promised — it's a place to coordinate.
Want one of these? Comment on (or open) the matching issue. PRs welcome.

## Near term
- [x] **`--lite` quick-start preset** — a ~2–3 GB "get running in minutes" build (3B AI +
      medical + survival + regional maps, no 24 GB Wikipedia). _Done: `-Lite` / `--lite` (see CHANGELOG)._
- [x] **Checksums on releases** — publish SHA-256 for the installers so people can verify
      before running. _Done: `SHA256SUMS.txt` is attached to each release since v1.1._
- [x] **Real-hardware testing** of the macOS and Linux installers (help wanted). _Done: macOS in #1, Linux x64 + Raspberry Pi arm64 in #2._
- [x] **Country-name aliases** — accept `UK`, `USA`, ISO-3 codes, etc. and map them to
      OsmAnd region names. _Done in v1.3._

## Phone experience
- [ ] **"Phone docs" pack** — a small bundle of the RAG-friendly PDFs + guides, importable
      into on-device document-AI apps (e.g. NomadAI), for iOS and Android.
- [ ] QR code + one-tap download link for the phone pack.

## Content
- [ ] More curated public-domain / openly-licensed manuals (gardening, water, comms).
- [ ] Optional extra ZIM archives (Wikibooks, Wikivoyage, WikiHow) behind a flag.

## Platform / packaging
- [ ] Optional GUI wrapper for non-technical users.
- [ ] Verify/handle upstream source changes automatically (see CI link check).

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) to get started.
