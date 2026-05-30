# Project Backlog & Feature Pipeline

## 🚀 In Flight / Next Up

### [FEATURE] Native Project-Initializer (Defensive Bootstrapper)
* **Description:** A global command (`New-ProjectWorkspace`) that generates a standardized project structure, initializes a Git repository, checks for required CLI tools (like `gh`), installs them via Chocolatey if missing, and establishes the remote VCS tracking completely headless.
* **Architecture Pattern (Proven):**
  1. **Pre-Flight Check:** Scan system for required binaries (`Get-Command`).
  2. **Automated Remediation:** Inline deployment via `choco install` if missing.
  3. **Session Hydration:** Dynamic environment block refresh without shell restart.
  4. **Interactive Authentication Handling:** Guard rails for CLI logins (e.g., `gh auth status/login`).
  5. **VCS Wiring:** Automated `git init`, `.gitignore` provisioning, remote creation, and upstream mapping.
* **New Specification (Named Hidden File Transition):**
  * **Goal:** Move away from relying on `Run-Tests.ps1` as the root directory marker.
  * **Implementation:** The initializer must generate a dedicated hidden file named `.devshell-project` directly in the root directory.
  * **Execution:** Set the hidden attribute natively via PowerShell:
    `(Get-Item -Path $markerPath -Force).Attributes = 'Hidden'`
  * **Refactoring Target:** Update `Get-ProjectRootPath` in the core module to scan for this hidden tracker instead of the executable script.

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
* **[2026-05-30] Dynamic Project-Root Configuration (Sprint 1):** Broke the hardcoded dependency on `Run-Tests.ps1`. Implemented a robust configuration checker in the module loader (`orchestrator.conf.json`) and dynamically wired `Get-ProjectRootPath` using a PS 5.1-safe evaluation array fallback. Covered by test cases `[05]` and `[06]`.
* **[2026-05-30] Pester Interception & Data-Streaming:** Fixed the console interception barrier by switching Pester to object-driven configuration. Captured `$result` data cleanly into the Windows clipboard pipeline while preserving the absolute silent "Lean Mode" design.

