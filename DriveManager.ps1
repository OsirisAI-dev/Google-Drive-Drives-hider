# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run as Administrator / Ejecutar como administrador / Als Administrator ausführen."
    Read-Host "Press Enter to exit"; exit
}

$Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"

# --- LANGUAGE DATA ---
$Lang = @{
    Eng = @{
        MenuTitle = "--- Windows Drive Manager ---";
        Opt1      = "1. Hide Specific Drives";
        Opt2      = "2. Show ALL Drives (Restore)";
        Opt3      = "3. Exit";
        Prompt    = "Select an option (1-3)";
        Input     = "Enter letters to HIDE (e.g., C, D, G)";
        Success   = "Success! Changes applied.";
        Restart   = "Restart Explorer now? (Y/N)";
        ExitMsg   = "Script finished. Press Enter to exit.";
        SafeWarn  = "WARNING: You selected drive C (System). Are you sure? (Y/N)"
    };
    Fra = @{
        MenuTitle = "--- Gestionnaire de Disques Windows ---";
        Opt1      = "1. Cacher des disques spécifiques";
        Opt2      = "2. Afficher TOUS les disques (Restaurer)";
        Opt3      = "3. Quitter";
        Prompt    = "Choisissez une option (1-3)";
        Input     = "Entrez les lettres à CACHER (ex: C, D, G)";
        Success   = "Succès ! Modifications appliquées.";
        Restart   = "Redémarrer l'Explorateur maintenant ? (O/N)";
        ExitMsg   = "Script terminé. Appuyez sur Entrée pour quitter.";
        SafeWarn  = "ATTENTION : Vous avez choisi le disque C (Système). Sûr ? (O/N)"
    };
    Ger = @{
        MenuTitle = "--- Windows Laufwerks-Manager ---";
        Opt1      = "1. Bestimmte Laufwerke ausblenden";
        Opt2      = "2. ALLE Laufwerke anzeigen (Wiederherstellen)";
        Opt3      = "3. Beenden";
        Prompt    = "Option wählen (1-3)";
        Input     = "Buchstaben zum AUSBLENDEN eingeben (z. B. C, D, G)";
        Success   = "Erfolg! Änderungen übernommen.";
        Restart   = "Explorer jetzt neu starten? (J/N)";
        ExitMsg   = "Skript beendet. Zum Beenden Eingabetaste drücken.";
        SafeWarn  = "WARNUNG: Laufwerk C (System) ausgewählt. Sicher? (J/N)"
    };
    Spa = @{
        MenuTitle = "--- Administrador de Unidades de Windows ---";
        Opt1      = "1. Ocultar unidades específicas";
        Opt2      = "2. Mostrar TODAS las unidades (Restaurar)";
        Opt3      = "3. Salir";
        Prompt    = "Seleccione una opción (1-3)";
        Input     = "Letras para OCULTAR (ej: C, D, G)";
        Success   = "¡Éxito! Cambios aplicados.";
        Restart   = "¿Reiniciar Explorer ahora? (S/N)";
        ExitMsg   = "Script finalizado. Presione Enter para salir.";
        SafeWarn  = "AVISO: Seleccionó la unidad C (Sistema). ¿Seguro? (S/N)"
    }
}

# --- 1. LANGUAGE SELECTION ---
Clear-Host
Write-Host "Select Language / Sprache wählen / Seleccionar idioma:"
Write-Host "1. English"
Write-Host "2. Français"
Write-Host "3. Deutsch"
Write-Host "4. Español"
$LangChoice = Read-Host "Choice"

$UI = switch ($LangChoice) {
    "2" { $Lang.Fra }
    "3" { $Lang.Ger }
    "4" { $Lang.Spa }
    Default { $Lang.Eng }
}

# --- DRIVE MAP ---
$DriveMap = @{ 'A'=1; 'B'=2; 'C'=4; 'D'=8; 'E'=16; 'F'=32; 'G'=64; 'H'=128; 'I'=256; 'J'=512; 'K'=1024; 'L'=2048; 'M'=4096; 'N'=8192; 'O'=16384; 'P'=32768; 'Q'=65536; 'R'=131072; 'S'=262144; 'T'=524288; 'U'=1048576; 'V'=2097152; 'W'=4194304; 'X'=8388608; 'Y'=16777216; 'Z'=33554432 }

# --- 2. MAIN LOOP ---
while ($true) {
    Clear-Host
    Write-Host $UI.MenuTitle -ForegroundColor Cyan
    Write-Host $UI.Opt1
    Write-Host $UI.Opt2
    Write-Host $UI.Opt3
    $Action = Read-Host "`n$($UI.Prompt)"

    if ($Action -eq "3") { break }

    if ($Action -eq "1") {
        $InputString = Read-Host $UI.Input
        $SelectedDrives = $InputString.ToUpper().Split(',').Trim()
        
        # --- SAFE MODE CHECK ---
        if ($SelectedDrives -contains "C") {
            $ConfirmC = Read-Host $UI.SafeWarn
            if ($ConfirmC -notmatch "[YOJSyojs]") {
                Write-Host "Operation cancelled." -ForegroundColor Yellow
                Read-Host "Press Enter..."; continue
            }
        }

        $TotalValue = 0
        foreach ($D in $SelectedDrives) { if ($DriveMap.ContainsKey($D)) { $TotalValue += $DriveMap[$D] } }
        
        if ($TotalValue -gt 0) {
            if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
            Set-ItemProperty -Path $Path -Name "NoDrives" -Value $TotalValue -Type DWord
            Write-Host $UI.Success -ForegroundColor Green
        }
    }
    elseif ($Action -eq "2") {
        Set-ItemProperty -Path $Path -Name "NoDrives" -Value 0 -Type DWord
        Write-Host $UI.Success -ForegroundColor Green
    }

    $Restart = Read-Host $UI.Restart
    if ($Restart -match "[YOJSyojs]") { Stop-Process -Name explorer -Force }
    
    Read-Host "`n..." 
}

# --- 3. FINAL PAUSE FIX ---
Write-Host "`n$($UI.ExitMsg)" -ForegroundColor Yellow
Read-Host ""