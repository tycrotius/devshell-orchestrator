BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\devshell-orchestrator.psm1"
    Import-Module $modulePath -Force -DisableNameChecking
}

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
        }

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
        }
    }

    Context "Get-ProjectFile Clipboard Streaming" {
        It "[03] Gracefully handles missing files without throwing unhandled exceptions" {
            { Get-ProjectFile -RelativePath "gibts\nicht.txt" } | Should -Not -Throw
        }

        It "[04] Throws an exception when an absolute path is provided to prevent path traversal" {
            { Get-ProjectFile -RelativePath "C:\Windows\System32\cmd.exe" } | Should -Throw -ExpectedMessage "*Path Traversal*"
        }
    }

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
        }

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
        }
    }
    #ENDREGION SPRINT_EXTENSION_ZONE
}



