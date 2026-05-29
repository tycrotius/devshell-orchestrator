BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\devshell-orchestrator.psm1"
    Import-Module $modulePath -Force -DisableNameChecking
}

Describe "DevShell-Orchestrator Core Validations" {
    Context "Get-ProjectRootPath Context Detection" {
        It "Returns null when no Run-Tests.ps1 marker is present in upper directories" {
            Push-Location $env:TEMP
            try {
                $root = Get-ProjectRootPath
                $root | Should -BeNullOrEmpty
            } finally {
                Pop-Location
            }
        }

        It "Successfully detects the root path when marker file exists" {
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
        It "Gracefully handles missing files without throwing unhandled exceptions" {
            { Get-ProjectFile -RelativePath "gibts\nicht.txt" } | Should -Not -Throw
        }

        It "Throws an exception when an absolute path is provided to prevent path traversal" {
            { Get-ProjectFile -RelativePath "C:\Windows\System32\cmd.exe" } | Should -Throw -ExpectedMessage "*Path Traversal*"
        }
    }
}
