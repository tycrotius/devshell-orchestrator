# DevShell-Orchestrator - Core Module
function Get-ProjectRootPath {
    $currentPath = Get-Location
    $marker = "Run-Tests.ps1"
    for ($i = 0; $i -lt 4; $i++) {
        if (Test-Path (Join-Path $currentPath $marker)) { return $currentPath }
        $currentPath = Split-Path $currentPath
    }
    return $null
}

function Run-Tests {
    param([Parameter()][switch]$VerboseOutput)
    $projectRoot = Get-ProjectRootPath
    if ($projectRoot) {
        $testPath = Join-Path $projectRoot "Run-Tests.ps1"
        if ($VerboseOutput) { & $testPath } else {
            Write-Host "[Profile] Executing test suite in LEAN mode..." -ForegroundColor Gray
            $config = [PesterConfiguration]::Default
            $config.Run.Path = (Join-Path $projectRoot "tests")
            $config.Output.Verbosity = 'Minimal'
            $config.Output.Cli.DisplayRules = 'None'
            Invoke-Pester -Configuration $config
        }
    } else { Write-Host "[-] Kein Projektkontext (Run-Tests.ps1) gefunden." -ForegroundColor Yellow }
}

function Get-ProjectFile {
    param ([string]$RelativePath = "tests\buddy.Tests.ps1")
    $projectRoot = Get-ProjectRootPath
    if (-not $projectRoot) { Write-Host "[-] Kein Projektkontext gefunden." -ForegroundColor Yellow ; return }
    $fullPath = Join-Path $projectRoot $RelativePath
    if (Test-Path $fullPath) {
        Get-Content -Path $fullPath -Raw | Set-Clipboard
        Write-Host "[Clipboard] Inhalt von '$RelativePath' kopiert!" -ForegroundColor Green
    } else { Write-Host "[-] Datei nicht gefunden unter: $fullPath" -ForegroundColor Yellow }
}

Export-ModuleMember -Function Get-ProjectRootPath, Run-Tests, Get-ProjectFile
