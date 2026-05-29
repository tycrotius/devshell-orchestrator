# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-05-30
### Added
* **Core Module:** Initial migration of context-aware dev tools (`Get-ProjectRootPath`, `Run-Tests`, `Get-ProjectFile`) into an isolated `.psm1` module.
* **Lean Mode:** Integrated `PesterConfiguration` object to suppress verbose test output and focus entirely on the "Test-Ampel" summary.
* **Chocolatey Deployment:** Provisioned `.nuspec` and `chocolateyInstall.ps1` skeleton scripts to make the module natively installable and profile-patchable via Choco.
* **Git Configuration:** Initialized local repository, tailored a defensive `.gitignore` block, and pushed via GitHub CLI (`gh`).
