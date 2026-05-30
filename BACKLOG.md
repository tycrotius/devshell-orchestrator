# Project Backlog & Feature Pipeline

## 🚀 In Flight / Next Up

### [FEATURE] Template-Injektion für New-ProjectWorkspace (Sprint 3)
* **Description:** Erweiterung des Initialisierungs-Befehls, um beim Erstellen eines neuen Workspaces automatisiert vordefinierte Strukturen (z. B. leere `tests/`-Ordner und standardisierte Test-Templates) zu kopieren.

### [FEATURE] Pester-Injektion / Mocking-Framework (Sprint 3)
* **Description:** Bereitstellung einer internen Hilfsfunktion im Orchestrator, um das Mocken des `$script:VcsExecutor` innerhalb der Testdateien zu vereinfachen, ohne dass mühsam über das Modul-Objekt (`& $modObj`) gearbeitet werden muss.

### [TECH DEBT] Plattform-Check & Cross-Platform (Sprint 3)
* **Description:** Validierung der gesamten Pfad- und Normalisierungslogik unter PowerShell Core (7.x), um Cross-Platform-Kompatibilität für Linux und macOS abzusichern.

---

## 📋 Future Pipeline / Ideas

### [TECH DEBT] Platform & Test-Infrastructure Upgrade (PS 7.x & Pester 7.x)
* **Description:** Migrate the runtime from Windows PowerShell 5.1 to PowerShell 7.x (Core) and upgrade Pester from 5.1 to the latest 7.x generation.
* **Impact:** Eliminates old engine syntax limits (enables the Null-Coalescing operator `??`), prevents `[PesterConfiguration]` TypeNotFound errors in fresh console sessions, and removes backward-compatibility array hacks from the production code.

### [ENHANCEMENT] Auto-Update Mechanism for Modules
* Check if a newer version of a module or tool is available on GitHub/Chocolatey during the first shell initialization of the day, running silently in the background to prevent startup lag.

### [TOOLING] Pester Test-Coverage Reporter for Lean Mode
* Extend the `Run-Tests` orchestrator to optionally dump a lightweight coverage summary directly into the shell using ANSI colors, without violating the "Lean Mode" silence guidelines.

---

## 🏁 Completed Milestones
* **[2026-05-30] Workspace-Automatisierung & VCS-Wiring (Sprint 2):** Implementierung von `New-ProjectWorkspace` mit nativer Verbergung des `.devshell-project` Markers. Aufbau der Git-Idempotenz und Absicherung über die Testfälle `[07]` bis `[12]` unter Einhaltung des KDP-Protokolls.
* **[2026-05-30] Dynamic Project-Root Configuration (Sprint 1):** Broke the hardcoded dependency on `Run-Tests.ps1`. Implemented a robust configuration checker in the module loader (`orchestrator.conf.json`) and dynamically wired `Get-ProjectRootPath` using a PS 5.1-safe evaluation array fallback. Covered by test cases `[05]` and `[06]`.
* **[2026-05-30] Pester Interception & Data-Streaming:** Fixed the console interception barrier by switching Pester to object-driven configuration. Captured `$result` data cleanly into the Windows clipboard pipeline while preserving the absolute silent "Lean Mode" design.
