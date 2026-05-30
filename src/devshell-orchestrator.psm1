# --- TDD Sprint 1: Configuration File Check ---
$expectedConfigPath = Join-Path $PSScriptRoot "..\orchestrator.conf.json"
if (-not (Test-Path $expectedConfigPath)) {
    throw [System.IO.FileNotFoundException]::new("Kritische Konfigurationsdatei nicht gefunden: $expectedConfigPath")
}
# ----------------------------------------------
<#
.Synopsis
    Core module for the DevShell Orchestrator.
#>

function Get-ProjectRootPath {
    [CmdletBinding()]
    param()

    $currentPath = Get-Location
    $marker = ($script:Config.Project.MarkerFile, "Run-Tests.ps1" -ne $null)[0]
    
    for ($i = 0; $i -lt 4; $i++) {
        # HIER SIND DIE CHECK-BREAKS: Abbruch bei Null, Leerstring oder Laufwerkswurzel
        if ($null -eq $currentPath -or [string]::IsNullOrEmpty($currentPath) -or $currentPath -eq "\" -or $currentPath.ToString().EndsWith(":\")) {
            break
        }
        
        $testMarkerPath = Join-Path $currentPath $marker -ErrorAction SilentlyContinue
        if ([string]::IsNullOrEmpty($testMarkerPath)) {
            break
        }

        if (Test-Path $testMarkerPath -ErrorAction SilentlyContinue) {
            if ($currentPath -is [System.Management.Automation.PathInfo]) {
                return $currentPath.Path
            }
            return $currentPath.ToString()
        }
        
        $currentPath = Split-Path $currentPath -ErrorAction SilentlyContinue
    }
    return $null
}

function Run-Tests {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$VerboseOutput
    )

    $projectRoot = Get-ProjectRootPath
    if (-not $projectRoot) {
        Write-Host "[-] Kein Projektkontext (Run-Tests.ps1) in den oberen Verzeichnissen gefunden." -ForegroundColor Yellow
        return
    }

    $testPath = Join-Path $projectRoot "tests"
    if (-not (Test-Path $testPath)) {
        Write-Host "[-] Der 'tests'-Ordner wurde im Projekt-Root nicht gefunden: $testPath" -ForegroundColor Yellow
        return
    }

    if ($VerboseOutput) {
        $runScript = Join-Path $projectRoot ($script:Config.Project.MarkerFile, "Run-Tests.ps1" -ne $null)[0]
        if (Test-Path $runScript) {
            & $runScript
        } else {
            Invoke-Pester -Path $testPath
        }
    } else {
        Write-Host "[Profile] Executing test suite in LEAN mode (Data streamed to Clipboard)..." -ForegroundColor Gray
        
        # Nutzen der verifizierten Objekt-Konfiguration ohne Parameter-Kollisionen
        $config = [PesterConfiguration]::Default
        $config.Run.Path = $testPath
        $config.Output.Verbosity = 'Minimal'
        $config.Run.PassThru = $true
        
        $result = Invoke-Pester -Configuration $config
        
        # Konvertieren und streamen
        $outputText = $result | Out-String
        if (-not [string]::IsNullOrEmpty($outputText)) {
            $outputText | Set-Clipboard
            Write-Host "[Clipboard] Testergebnisse erfolgreich in die Zwischenablage transferiert!" -ForegroundColor Green
        }
    }
}

function Get-ProjectFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath = "tests\buddy.Tests.ps1"
    )
    
    # Schutz vor absoluten Pfaden (Path Traversal Protection)
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Path Traversal detected! Absolute paths are forbidden."
    }

    $projectRoot = Get-ProjectRootPath
    if (-not $projectRoot) {
        Write-Host "[-] Kein Projektkontext gefunden. Navigiere in ein Projektverzeichnis." -ForegroundColor Yellow
        return
    }
    
    $fullPath = Join-Path $projectRoot $RelativePath
    
    if (Test-Path $fullPath) {
        try {
            Get-Content -Path $fullPath -Raw -ErrorAction Stop | Set-Clipboard
            Write-Host "[Clipboard] Inhalt von '$RelativePath' aus Projekt '$(Split-Path $projectRoot -Leaf)' kopiert!" -ForegroundColor Green
        } catch {
            Write-Host "[-] Fehler beim Lesen der Datei oder Schreiben in die Zwischenablage: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "[-] Datei nicht gefunden unter: $fullPath" -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function Get-ProjectRootPath, Run-Tests, Get-ProjectFile





