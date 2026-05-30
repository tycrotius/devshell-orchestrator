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
