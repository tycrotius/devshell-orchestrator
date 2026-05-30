# Changelog

## [1.1.0] - 2026-05-30
### Added
- Testfall [05]: Validierung der Existenz von 'orchestrator.conf.json' beim Modulstart mit dedizierter FileNotFoundException.
- Testfall [06]: Dynamische Evaluierung des Project-Root-Markers ueber die Konfigurationsdatei.

### Changed
- Modul-Loader prueft nun zwingend vor der Initialisierung die Konfiguration.
- 'Get-ProjectRootPath' von der harten Kopplung an 'Run-Tests.ps1' befreit; nutzt nun ein abwaertskompatibles PS 5.1-Evaluierungs-Array mit sicherem Fallback.
# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.1] - 2026-05-30
### Added
* **Object Clipboard Streaming:** Extended `Run-Tests` to programmatically capture the internal Pester 5 result object and pipe its summary to the clipboard.

### Fixed
* **Test Path Mismatch:** Resolved 8.3 short-path mismatches (`ADMINI~1`) via `.NET` path normalization.
* **VCS Integrity:** Fixed CRLF line-ending drift through repository renormalization.

## [1.0.0] - 2026-05-30
### Added
* **Core Module:** Initial migration of `Get-ProjectRootPath`, `Run-Tests`, and `Get-ProjectFile`.
* **Lean Mode:** Integrated silent Pester summary output.
* **Chocolatey Deployment:** Provisioned `.nuspec` and install scripts.

