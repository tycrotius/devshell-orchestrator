# Changelog

## [1.2.0] - 2026-05-30
### Added
- Native Workspace-Scaffolding über die neue Funktion `New-ProjectWorkspace`.
- VCS-Wiring zur automatischen Git-Initialisierung (`git init`) im Zielordner über einen Ambient Context Hook.
- Idempotenz-Absicherung: Abgleich existierender `.git`-Strukturen vor Neuinitialisierung.
- Automatische Generierung einer Standard-`.gitignore` für temporäre Build-Artefakte (`.devshell-local`, `*.log`, `bld/`, `bin/`, `obj/`).
- Erweiterung der globalen `.gitignore` um das Suchmuster `*.patch` sowie die Dateien `vcs_sandbox.ps1` und `coverage.xml`.

### Fixed
- Behebung von Typ-Auflösungsfehlern (`[PesterConfiguration]`) in Pester v5 unter Windows PowerShell 5.1 nach System-Reboot durch explizite Modul-Import-Vorgaben.
- KDP-Bereinigung: Entfernung aller verwaisten Syntax-Elemente (Dangling Braces ganz am Ende des Moduls).
- Zusammenführung unbeabsichtigter Zeilenumbrüche vor `-ForegroundColor` und flachen Pipeline-Strecken (`|`), die zu Syntax-Fehlern führten.
- Bereinigung aller SDB-Debugging-Artefakte (`# SDB: Temp. Insertion` / `Write-Host [DEBUG]`) im produktiven Core-Code.
- Remote-Index-Bereinigung: Versehentlich gestagete Cache- und Sandbox-Dateien (`gemini-code-*.patch`, `vcs_sandbox.ps1`, `coverage.xml`) vom GitHub-Repository entfernt, ohne die lokalen Daten zu beeinträchtigen.

## [1.1.0] - 2026-05-30
### Added
- Testfall [05]: Validierung der Existenz von 'orchestrator.conf.json' beim Modulstart mit dedizierter FileNotFoundException.
- Testfall [06]: Dynamische Evaluierung des Project-Root-Markers ueber die Konfigurationsdatei.

### Changed
- Modul-Loader prueft nun zwingend vor der Initialisierung die Konfiguration.
- 'Get-ProjectRootPath' von der harten Kopplung an 'Run-Tests.ps1' befreit; nutzt nun ein abwaertskompatibles PS 5.1-Evaluierungs-Array mit sicherem Fallback.

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
