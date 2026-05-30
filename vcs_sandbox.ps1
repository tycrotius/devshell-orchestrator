# SIDE-QUEST: VERIFIKATION PARAMETER-BINDUNG IN SCRIPTBLÖCKEN (PS 5.1)

Write-Host "--- TEST 1: Der aktuelle Zustand (Explizite Parameter) ---" -ForegroundColor Cyan
$GitCalls = [System.Collections.Generic.List[string]]::new()
$VcsExecutorWithParam = { 
    param($Binary, $Arguments) 
    Write-Host "DEBUG WithParam - `$Binary: $Binary"
    Write-Host "DEBUG WithParam - `$Arguments Typ: $($Arguments.GetType().Name)"
    Write-Host "DEBUG WithParam - `$Arguments Inhalt: ($($Arguments -join ' '))"
    $GitCalls.Add(($Arguments -join " ")) 
}

# Verhalte dich exakt wie die Funktion im Modul:
$argList = @("init", "C:\Dummy\Path")
& $VcsExecutorWithParam "git" $argList

Write-Host "Ergebnis im Speicher: $($GitCalls[0])"
Write-Host "--------------------------------------------------------`n"


Write-Host "--- TEST 2: Das Phänomen untersuchen (Alte `$args Methode) ---" -ForegroundColor Yellow
$GitCallsOld = [System.Collections.Generic.List[string]]::new()
$VcsExecutorWithArgs = { 
    Write-Host "DEBUG WithArgs - `$args Count: $($args.Count)"
    for($i=0; $i -lt $args.Count; $i++) {
        Write-Host "  -> `$args[$i]: $($args[$i]) (Typ: $($args[$i].GetType().Name))"
    }
    $GitCallsOld.Add(($args -join " ")) 
}

& $VcsExecutorWithArgs "git" $argList
Write-Host "Ergebnis im Speicher (Alte Methode): $($GitCallsOld[0])"
