BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\devshell-orchestrator.psm1"
    Import-Module $modulePath -Force -DisableNameChecking
} # END BeforeAll

Describe "DevShell-Orchestrator Core Validations" {
    Context "Get-ProjectRootPath Context Detection" {
        It "[01] Returns null when no Run-Tests.ps1 marker is present in upper directories" {
            Push-Location $env:TEMP
            try {
                $root = Get-ProjectRootPath
                $root | Should -BeNullOrEmpty
            } finally {
                Pop-Location
            }
        } # END It

        It "[02] Successfully detects the root path when marker file exists" {
            $tempRoot = Join-Path $env:TEMP "PesterTest_Workspace"
            $subFolder = Join-Path $tempRoot "src\sub\deep"
            New-Item -ItemType Directory -Path $subFolder -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempRoot "Run-Tests.ps1") -Force | Out-Null

            Push-Location $subFolder
            try {
                $root = Get-ProjectRootPath
                
                # Radikale Normalisierung über die native .NET API
                $normalizedRoot = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
                $normalizedExpected = [System.IO.Path]::GetFullPath($tempRoot).TrimEnd('\')

                $normalizedRoot | Should -Not -BeNullOrEmpty
                $normalizedRoot | Should -Be $normalizedExpected
            } finally {
                Pop-Location
                Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [02]
    } # END Context

    Context "Get-ProjectFile Clipboard Streaming" {
        It "[03] Gracefully handles missing files without throwing unhandled exceptions" {
            { Get-ProjectFile -RelativePath "gibts\nicht.txt" } | Should -Not -Throw
        } # END It [03]

        It "[04] Throws an exception when an absolute path is provided to prevent path traversal" {
            { Get-ProjectFile -RelativePath "C:\Windows\System32\cmd.exe" } | Should -Throw -ExpectedMessage "*Path Traversal*"
        } # END It [04]
    } # END Context

    #REGION SPRINT_EXTENSION_ZONE
    Context "Module Initialization and Configuration" {
        It "[05] Throws a FileNotFoundException and aborts loading when conf-file is missing" {
            $tempTestDir = Join-Path $env:TEMP "Orchestrator_LoadTest"
            $tempSrcDir = Join-Path $tempTestDir "src"
            New-Item -ItemType Directory -Path $tempSrcDir -Force | Out-Null
            
            $currentModulePath = Join-Path $PSScriptRoot "..\src\devshell-orchestrator.psm1"
            $tempModulePath = Join-Path $tempSrcDir "devshell-orchestrator.psm1"
            Copy-Item -Path $currentModulePath -Destination $tempModulePath -Force
            
            try {
                { Import-Module $tempModulePath -Force -ErrorAction Stop } | Should -Throw -ExpectedMessage "*Kritische Konfigurationsdatei nicht gefunden*"
            } finally {
                Remove-Module -Name "devshell-orchestrator" -ErrorAction SilentlyContinue
                Remove-Item $tempTestDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [05]

        It "[06] Uses the MarkerFile defined in the configuration rather than a hardcoded string" {
            $modObj = (Get-Command Get-ProjectRootPath).Module
            
            # Defensiver Aufbau der Konfiguration im Modul-Scope
            & $modObj {
                if ($null -eq $script:Config) {
                    $script:Config = [PSCustomObject]@{ Project = [PSCustomObject]@{ MarkerFile = "Run-Tests.ps1" } }
                }
                $script:Config.Project.MarkerFile = ".custom-tdd-marker"
            }
            
            $tempRoot = Join-Path $env:TEMP "PesterTest_ConfigWorkspace"
            $subFolder = Join-Path $tempRoot "src"
            New-Item -ItemType Directory -Path $subFolder -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempRoot ".custom-tdd-marker") -Force | Out-Null

            Push-Location $subFolder
            try {
                # Das muss fehlschlagen, da die Funktion noch nach "Run-Tests.ps1" sucht
                $root = Get-ProjectRootPath
                $root | Should -Not -BeNullOrEmpty
            } finally {
                Pop-Location
                Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
                
                # Zurücksetzen auf den Standard-Marker für die anderen Tests
                & $modObj { $script:Config.Project.MarkerFile = "Run-Tests.ps1" }
            }
        } # END It [06]
    } # END Context

    Context "New-ProjectWorkspace Initializer (Sprint 2)" {
        It "[07] Generates the target directory structure and provisions the .devshell-project marker" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspace"
            $expectedMarker = Join-Path $tempWorkspace ".devshell-project"
            try {
                New-ProjectWorkspace -Path $tempWorkspace -Force
                
                # [Cross-Ref -> Module: Process Step 1] Zielverzeichnis sicherstellen
                Test-Path $tempWorkspace | Should -Be $true

                # [Cross-Ref -> Module: Process Step 3] Marker-Datei erzeugen
                Test-Path $expectedMarker | Should -Be $true
            } finally {
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [07]

        It "[08] Natively flags the .devshell-project marker file as Hidden" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspaceAttributes"
            $expectedMarker = Join-Path $tempWorkspace ".devshell-project"
            try {
                New-ProjectWorkspace -Path $tempWorkspace -Force
                $fileItem = Get-Item -Path $expectedMarker -Force
                
                # [Cross-Ref -> Module: Process Step 4] Attribut nativ auf Hidden setzen
                $fileItem.Attributes.HasFlag([System.IO.FileAttributes]::Hidden) | Should -Be $true
            } finally {
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [08]

        It "[09] Accepts a collection of required CLI tools and validates their presence" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspaceTools"
            try {
                # [Cross-Ref -> Module: Process Step 1.5 / Pre-Flight] Validierung der Tool-Abhängigkeiten
                { New-ProjectWorkspace -Path $tempWorkspace -RequiredTools "nonexistent-cli-tool" -ErrorAction Stop } | Should -Throw -ExpectedMessage "*Fehlende CLI-Abhaengigkeiten*"
            } finally {
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [09]

        It "[10] Executes without errors when all specified CLI tools are available" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspaceToolsValid"
            try {
                # [Cross-Ref -> Module: Process Step 1.5 / Pre-Flight] Grüner Pfad bei validen Abhängigkeiten
                { New-ProjectWorkspace -Path $tempWorkspace -RequiredTools "powershell" -ErrorAction Stop } | Should -Not -Throw
            } finally {
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [10]

        It "[11] Initializes a Git repository and provisions a default .gitignore" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspaceGit"
            $expectedIgnore = Join-Path $tempWorkspace ".gitignore"

            $modObj = (Get-Command Get-ProjectRootPath).Module
            & $modObj { 
                $script:GitCalls = [System.Collections.Generic.List[string]]::new()
                $script:VcsExecutor = { 
                    param($Binary, $Arguments) 
                    # Falls $Arguments ein Array ist, joinen wir. 
                    # Falls PS 5.1 es als einzelnes Objekt 'verpackt' hat, packen wir es in ein Array.
                    $resolvedArgs = if ($Arguments -is [array]) { $Arguments } else { @($Arguments) }
                    $script:GitCalls.Add(($resolvedArgs -join " ")) 
                }
            }

            try {
                New-ProjectWorkspace -Path $tempWorkspace -Force
                
                # [Cross-Ref -> Module: Process Step 5] VCS Wiring: Wurde Git mit 'init' gerufen?
                $calls = @(& $modObj { $script:GitCalls })

                $calls.Count | Should -Be 1
                # Statt -Match "init" (was bei PS 5.1/Pester 5.x manchmal den Regex-Kontext verliert)
                # nutzen wir einen präzisen StartsWith-Check oder eine explizite Regex-Verankerung:
                $calls[0] | Should -Match "^init\s"

                Test-Path $expectedIgnore | Should -Be $true
            } finally {
                & $modObj { $script:VcsExecutor = $null }
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [11]
        
        It "[12] Does not re-initialize git if a .git directory already exists" {
            $tempWorkspace = Join-Path $env:TEMP "TDD_NewWorkspaceGitIdempotent"
            $gitFolder = Join-Path $tempWorkspace ".git"
            $expectedIgnore = Join-Path $tempWorkspace ".gitignore"
            
            New-Item -ItemType Directory -Path $gitFolder -Force | Out-Null
            
            $modObj = (Get-Command Get-ProjectRootPath).Module
            & $modObj { 
                $script:GitCalls = [System.Collections.Generic.List[string]]::new()
                # LABORGEPRÜFT: Identische Absicherung für den Idempotenz-Check
                $script:VcsExecutor = { param($Binary, $Arguments) $script:GitCalls.Add(($Arguments -join " ")) }
            }

            try {
                New-ProjectWorkspace -Path $tempWorkspace -Force
                
                # [Cross-Ref -> Module: Process Step 5] Check Idempotenz: Git darf 0-mal gerufen werden
                $calls = @(& $modObj { $script:GitCalls })
                $calls.Count | Should -Be 0
                
                Test-Path $expectedIgnore | Should -Be $true
            } finally {
                & $modObj { $script:VcsExecutor = $null }
                Remove-Item $tempWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        } # END It [12]
    } # END Context
    #ENDREGION SPRINT_EXTENSION_ZONE
} # END Describe




