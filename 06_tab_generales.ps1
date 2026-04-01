#==========================================================================
# LOGICA - TAB UTILIDADES GENERALES
#==========================================================================

# OEMINFO MDM HONOR
$btnEditOem.Add_Click({
    $fd=New-Object System.Windows.Forms.OpenFileDialog
    $fd.Filter="OEMINFO Files (*.img;*.bin)|*.img;*.bin|Todos|*.*"
    if ($fd.ShowDialog() -ne "OK") { return }
    $Global:_oemPath=$fd.FileName
    $Global:_oemRoot=$script:SCRIPT_ROOT
    $fn=[System.IO.Path]::GetFileName($Global:_oemPath)
    $fs=(Get-Item $Global:_oemPath).Length
    GenLog "`r`n[*] ===== OEMINFO MDM HONOR ====="
    GenLog "[*] Archivo : $fn ($([math]::Round($fs/1KB,2)) KB)"
    GenLog "[~] Procesando..."
    $Global:_btnOem=$btnEditOem; $Global:_btnOem.Enabled=$false; $Global:_btnOem.Text="PROCESANDO..."
    $stamp=Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
    $backDir=[System.IO.Path]::Combine($Global:_oemRoot,"BACKUPS","OEMINFO_MDM_HONOR",$stamp)
    [OemPatcher]::Run($Global:_oemPath,$backDir)
    $Global:_oemTimer=New-Object System.Windows.Forms.Timer; $Global:_oemTimer.Interval=400
    $Global:_oemTimer.Add_Tick({
        $msg=""
        while ([OemPatcher]::Q.TryDequeue([ref]$msg)) { GenLog $msg }
        if ([OemPatcher]::Done) {
            $Global:_oemTimer.Stop(); $Global:_oemTimer.Dispose()
            $Global:_btnOem.Enabled=$true; $Global:_btnOem.Text="OEMINFO MDM HONOR"
        }
    })
    $Global:_oemTimer.Start()
})

#==========================================================================
# MODEM MI ACCOUNT
#==========================================================================
$btnEFSMod.Add_Click({
    $btnEFSMod.Enabled = $false; $btnEFSMod.Text = "PROCESANDO..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        GenLog ""
        GenLog "[*] =========================================="
        GenLog "[*] MODEM MI ACCOUNT - RNX TOOL PRO"
        GenLog "[*] Renombrar cardapp.xxx -> 00000000000"
        GenLog "[*] =========================================="
        GenLog ""
        $fd = New-Object System.Windows.Forms.OpenFileDialog
        $fd.Filter = "Modem Image (*.img;*.bin)|*.img;*.bin|Todos|*.*"
        $fd.Title = "Selecciona modem.img / modem.bin (CTRL para seleccionar 2)"
        $fd.Multiselect = $true
        if ($fd.ShowDialog() -ne "OK") { GenLog "[~] Cancelado."; return }
        $selectedFiles = $fd.FileNames
        if ($selectedFiles.Count -eq 0) { GenLog "[~] Sin archivos seleccionados."; return }
        if ($selectedFiles.Count -gt 2) {
            GenLog "[!] Maximo 2 archivos permitidos. Seleccionaste: $($selectedFiles.Count)"
            return
        }
        GenLog "[+] Archivos seleccionados: $($selectedFiles.Count)"
        foreach ($f in $selectedFiles) {
            $fn = [System.IO.Path]::GetFileName($f)
            $fs = [math]::Round((Get-Item $f).Length / 1MB, 2)
            GenLog " -> $fn ($fs MB)"
        }
        $modemRoot = $script:SCRIPT_ROOT
        $stamp = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
        $backDir = [System.IO.Path]::Combine($modemRoot, "BACKUPS", "MODEM_MI_ACCOUNT", $stamp)
        [ModemMiPatcher]::Run($selectedFiles, $backDir)
        $Global:_modemTimer = New-Object System.Windows.Forms.Timer
        $Global:_modemTimer.Interval = 500
        $Global:_modemTimer.Add_Tick({
            $msg = ""
            while ([ModemMiPatcher]::Q.TryDequeue([ref]$msg)) { GenLog $msg }
            if ([ModemMiPatcher]::Done) {
                $Global:_modemTimer.Stop(); $Global:_modemTimer.Dispose()
                $btnEFSMod.Enabled = $true
                $btnEFSMod.Text = "MODEM MI ACCOUNT"
            }
        })
        $Global:_modemTimer.Start()
    } catch {
        GenLog "[!] Error inesperado: $_"
        $btnEFSMod.Enabled = $true; $btnEFSMod.Text = "MODEM MI ACCOUNT"
    }
})

# BORRAR DATOS
$btnsG1[0].Add_Click({
    GenLog "[*] BORRAR DATOS..."
    if (-not (Check-ADB)) { GenLog "[!] No hay equipo ADB."; return }
    $r=[System.Windows.Forms.MessageBox]::Show("Esto borrara TODOS los datos.`nEsta seguro?","CONFIRMAR",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($r -eq "Yes") {
        GenLog "[~] Enviando wipe..."; & adb shell "wipe data" 2>$null; & adb reboot recovery 2>$null
        GenLog "[OK] Wipe enviado - reiniciando recovery."
    } else { GenLog "[~] Cancelado." }
})

# DESHABILITAR OTA
$btnsG1[1].Add_Click({
    GenLog "[*] DESHABILITANDO OTA..."
    if (-not (Check-ADB)) { GenLog "[!] No hay equipo ADB."; return }
    & adb shell "pm disable com.wssyncmldm" 2>$null
    & adb shell "pm disable com.sec.android.soagent" 2>$null
    GenLog "[OK] OTA deshabilitado."
})

# FLASHEAR ROOT
$btnsG1[2].Add_Click({ GenLog "[>] FLASHEAR ROOT: usa Magisk patched boot.img en INICIAR FLASHEO" })

# VERIFICAR ROOT
$btnsG1[3].Add_Click({
    if (-not (Check-ADB)) { GenLog "[!] No hay equipo ADB."; return }
    GenLog "[*] Verificando root..."; $r=Detect-Root; GenLog "[+] ROOT STATE : $r"
    $rootStr2=if ($r -ne "NO ROOT") {"SI"} else {"NO"}; $Global:lblRoot.Text = "ROOT : $rootStr2"
    $Global:lblRoot.ForeColor = if ($r -ne "NO ROOT") {[System.Drawing.Color]::Lime} else {[System.Drawing.Color]::Red}
})

# EFS SAMSUNG SIM 2
$btnEFSDirec.Add_Click({
    $fd = New-Object System.Windows.Forms.OpenFileDialog
    $fd.Filter = "EFS Image (*.img;*.bin)|*.img;*.bin|Todos|*.*"
    $fd.Title = "Selecciona archivo EFS Samsung (efs.img / efs.bin)"
    if ($fd.ShowDialog() -ne "OK") { return }
    $Global:_efsPath = $fd.FileName
    $Global:_efsRoot = $script:SCRIPT_ROOT
    $fn = [System.IO.Path]::GetFileName($Global:_efsPath)
    $fs = (Get-Item $Global:_efsPath).Length
    GenLog "`r`n[*] ===== EFS SAMSUNG SIM 2 ====="
    GenLog "[*] Archivo : $fn ($([math]::Round($fs/1KB,2)) KB)"
    GenLog "[~] Editando imagen EFS directamente..."
    $Global:_btnEfsDirec = $btnEFSDirec
    $Global:_btnEfsDirec.Enabled = $false
    $Global:_btnEfsDirec.Text = "PROCESANDO..."
    $stamp = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
    $backDir = [System.IO.Path]::Combine($Global:_efsRoot, "BACKUPS", "EFS_SAMSUNG_SIM2", $stamp)
    [EfsPatcher]::Run($Global:_efsPath, $backDir)
    $Global:_efsDirTimer = New-Object System.Windows.Forms.Timer
    $Global:_efsDirTimer.Interval = 400
    $Global:_efsDirTimer.Add_Tick({
        $msg = ""
        while ([EfsPatcher]::Q.TryDequeue([ref]$msg)) { GenLog $msg }
        if ([EfsPatcher]::Done) {
            $Global:_efsDirTimer.Stop(); $Global:_efsDirTimer.Dispose()
            $Global:_btnEfsDirec.Enabled = $true
            $Global:_btnEfsDirec.Text = "EFS SAMSUNG SIM 2"
        }
    })
    $Global:_efsDirTimer.Start()
})

# PERSIST MI ACCOUNT
$btnPersist.Add_Click({
    $fd = New-Object System.Windows.Forms.OpenFileDialog
    $fd.Filter = "Persist Image (*.img;*.bin)|*.img;*.bin|Todos|*.*"
    $fd.Title = "Selecciona archivo Persist Xiaomi (persist.img / persist.bin)"
    if ($fd.ShowDialog() -ne "OK") { return }
    $Global:_persistPath = $fd.FileName
    $Global:_persistRoot = $script:SCRIPT_ROOT
    $fn = [System.IO.Path]::GetFileName($Global:_persistPath)
    $fs = (Get-Item $Global:_persistPath).Length
    GenLog "`r`n[*] ===== PERSIST MI ACCOUNT ====="
    GenLog "[*] Archivo : $fn ($([math]::Round($fs/1KB,2)) KB)"
    GenLog "[~] Navegando ext4..."
    $Global:_btnPersist = $btnPersist
    $Global:_btnPersist.Enabled = $false
    $Global:_btnPersist.Text = "PROCESANDO..."
    $stamp = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
    $backDir = [System.IO.Path]::Combine($Global:_persistRoot, "BACKUPS", "PERSIST_MI_ACCOUNT", $stamp)
    [PersistPatcher]::Run($Global:_persistPath, $backDir)
    $Global:_persistTimer = New-Object System.Windows.Forms.Timer
    $Global:_persistTimer.Interval = 400
    $Global:_persistTimer.Add_Tick({
        $msg = ""
        while ([PersistPatcher]::Q.TryDequeue([ref]$msg)) { GenLog $msg }
        if ([PersistPatcher]::Done) {
            $Global:_persistTimer.Stop(); $Global:_persistTimer.Dispose()
            $Global:_btnPersist.Enabled = $true
            $Global:_btnPersist.Text = "PERSIST MI ACCOUNT"
        }
    })
    $Global:_persistTimer.Start()
})

# LEER IMEI
$btnsG3[2].Add_Click({
    GenLog "[*] LEER IMEI..."
    if (-not (Check-ADB)) {
        $hdet=Invoke-HeimdallAdv "detect"
        if ($hdet -imatch "Device detected") {
            $pit=Invoke-HeimdallAdv "print-pit"
            $pit -split "`n" | Where-Object { $_ -imatch "IMEI" } | ForEach-Object { GenLog "[+] $_" }
        } else { GenLog "[!] Sin ADB ni Download Mode"; return }
        return
    }
    $imeiRaw=(& adb shell "service call iphonesubinfo 1" 2>$null)
    if ($imeiRaw -match "'\s*(\d{5,})\s*'") { GenLog "[+] IMEI : $($Matches[1])" }
    else {
        $imei2=(& adb shell "dumpsys iphonesubinfo" 2>$null) | Select-String "Device ID" | Select-Object -First 1
        if ($imei2) { GenLog "[+] $imei2" } else { GenLog "[!] IMEI no disponible" }
    }
})

# Stubs MTK
$btnsG3[0].Add_Click({ GenLog "[>] BYPASS MTK : en desarrollo" })
$btnsG3[1].Add_Click({ GenLog "[>] ESCRIBIR IMEI : requiere EDL o herramienta MTK" })
$btnsG3[3].Add_Click({ GenLog "[>] DESBLOQUEAR BL : fastboot flashing unlock" })

#==========================================================================
# REPAIR NVDATA
#==========================================================================
$btnRepairNV.Add_Click({
    $btn = $btnRepairNV
    $btn.Enabled = $false; $btn.Text = "REPARANDO..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        GenLog ""
        GenLog "[*] =========================================="
        GenLog "[*] REPAIR NVDATA - RNX TOOL PRO"
        GenLog "[*] =========================================="
        if (-not (Check-ADB)) { GenLog "[!] No hay equipo ADB."; return }
        $rootChk = (& adb shell "su -c id" 2>$null) -join ""
        if ($rootChk -notmatch "uid=0") { GenLog "[!] ROOT requerido."; return }
        GenLog "[+] Root: OK"
        $nvPart = ""
        foreach ($n in @("nvdata","NVDATA","userdata","nvcfg")) {
            $found = (& adb shell "su -c 'ls /dev/block/by-name/$n 2>/dev/null'" 2>$null) -join ""
            if ($found -imatch $n) { $nvPart = $n; break }
        }
        if (-not $nvPart) {
            $parts = (& adb shell "su -c 'ls /dev/block/by-name/ 2>/dev/null'" 2>$null) -join " "
            $nvPart = ($parts -split "\s+" | Where-Object { $_ -imatch "^nv" } | Select-Object -First 1)
            if (-not $nvPart) { GenLog "[!] Particion NVDATA no encontrada."; return }
        }
        GenLog "[+] Particion: /dev/block/by-name/$nvPart"
        $stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $bakDir = [System.IO.Path]::Combine($script:SCRIPT_ROOT, "BACKUPS", "NVDATA", $stamp)
        New-Item $bakDir -ItemType Directory -Force | Out-Null
        $bakPath = Join-Path $bakDir "nvdata_backup.img"
        GenLog "[~] Creando backup..."
        & adb shell "su -c 'dd if=/dev/block/by-name/$nvPart of=/sdcard/nvdata_rnx.img bs=4096'" 2>$null | Out-Null
        & adb pull /sdcard/nvdata_rnx.img $bakPath 2>$null | Out-Null
        & adb shell "su -c 'rm -f /sdcard/nvdata_rnx.img'" 2>$null | Out-Null
        if (Test-Path $bakPath) {
            $sz = [math]::Round((Get-Item $bakPath).Length / 1MB, 2)
            GenLog "[+] Backup: $bakPath ($sz MB)"
        }
        $fsckResult = (& adb shell "su -c 'fsck.ext4 -y /dev/block/by-name/$nvPart 2>&1'" 2>$null) -join "`n"
        if ($fsckResult) { foreach ($fl in ($fsckResult -split "`n")) { if ($fl.Trim()) { GenLog " $($fl.Trim())" } } }
        foreach ($cmd in @("rm -f /data/nvram/md/NVRAM/NVD_IMEI/BT_Addr","rm -f /data/nvram/APCFG/APRDCL/*","chmod 770 /data/nvram")) {
            & adb shell "su -c '$cmd'" 2>$null | Out-Null
        }
        GenLog "[OK] REPAIR NVDATA completado. Reinicia el dispositivo."
    } catch { GenLog "[!] Error: $_" }
    finally { $btn.Enabled = $true; $btn.Text = "REPAIR NVDATA" }
})

#==========================================================================
# FLASH PARTICION IMG
#==========================================================================
$btnFlashPart.Add_Click({
    $btn = $btnFlashPart
    $btn.Enabled = $false; $btn.Text = "EJECUTANDO..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        GenLog ""
        GenLog "[*] =========================================="
        GenLog "[*] FLASH PARTICION IMG - RNX TOOL PRO"
        GenLog "[*] =========================================="
        $fd = New-Object System.Windows.Forms.OpenFileDialog
        $fd.Filter = "Imagen de particion (*.img;*.bin)|*.img;*.bin|Todos|*.*"
        $fd.Title = "Selecciona imagen de particion (.img)"
        if ($fd.ShowDialog() -ne "OK") { GenLog "[~] Cancelado."; return }
        $imgPath = $fd.FileName
        $imgName = [System.IO.Path]::GetFileName($imgPath)
        $imgSz = [math]::Round((Get-Item $imgPath).Length / 1MB, 2)
        GenLog "[+] Archivo : $imgName ($imgSz MB)"
        Add-Type -AssemblyName Microsoft.VisualBasic
        $partName = [Microsoft.VisualBasic.Interaction]::InputBox(
            "Nombre exacto de la particion a flashear:`n(ej: system, vendor, boot, recovery, modem, efs, nvdata...)",
            "FLASH PARTICION IMG",
            [System.IO.Path]::GetFileNameWithoutExtension($imgPath)
        )
        if (-not $partName -or -not $partName.Trim()) { GenLog "[~] Cancelado."; return }
        $partName = $partName.Trim()
        GenLog "[+] Particion: $partName"
        $fbExe = Get-FastbootExe
        $fbDev = if ($fbExe) { (& $fbExe devices 2>$null) -join "" } else { "" }
        $adbDev = (& adb devices 2>$null) -join ""
        if ($fbDev -imatch "\tfastboot") {
            GenLog "[+] Modo Fastboot..."
            $ec = Invoke-FastbootLive "flash $partName `"$imgPath`""
            if ($ec -eq 0) { GenLog "[OK] Particion '$partName' flasheada." } else { GenLog "[!] Flash codigo: $ec" }
        } elseif ($adbDev -imatch "`tdevice") {
            GenLog "[+] Modo ADB - verificando root..."
            $rootCheck = (& adb shell "su -c id" 2>$null) -join ""
            if ($rootCheck -notmatch "uid=0") { GenLog "[!] ROOT requerido para ADB flash."; return }
            $remotePath = "/data/local/tmp/rnx_part.img"
            GenLog "[~] Copiando imagen..."
            & adb push "$imgPath" $remotePath 2>$null | Out-Null
            $partDev = (& adb shell "su -c 'readlink -f /dev/block/by-name/$partName 2>/dev/null'" 2>$null) -join ""
            $partDev = $partDev.Trim()
            if (-not $partDev) { $partDev = "/dev/block/by-name/$partName" }
            GenLog "[+] Bloque: $partDev"
            $ddOut = (& adb shell "su -c 'dd if=$remotePath of=$partDev bs=4096 conv=fsync 2>&1'" 2>$null) -join "`n"
            foreach ($dl in ($ddOut -split "`n")) { if ($dl.Trim()) { GenLog " $($dl.Trim())" } }
            & adb shell "su -c 'rm -f $remotePath'" 2>$null | Out-Null
            if ($ddOut -imatch "records out|bytes") { GenLog "[OK] Particion '$partName' flasheada via dd." }
            else { GenLog "[~] Verifica el log - escritura no confirmada." }
        } else {
            GenLog "[!] No se detecta ADB ni Fastboot."
        }
    } catch { GenLog "[!] Error: $_" }
    finally { $btn.Enabled = $true; $btn.Text = "FLASH PARTICION IMG" }
})

#==========================================================================
# WINUSB DRIVER
#==========================================================================
$btnWinUSB.Add_Click({
    $btnWinUSB.Enabled = $false
    $btnWinUSB.Text = "INSTALANDO..."
    [System.Windows.Forms.Application]::DoEvents()
    $Global:logOdin.Clear()
    $cpuNow = Get-SamsungCPUInfo
    if ($cpuNow.MODE -ne "DOWNLOAD_MODE") {
        OdinLog "[!] No hay dispositivo en Download Mode"
        OdinLog "[~] Conecta en Download Mode: Vol- + Power o adb reboot download"
        $btnWinUSB.Enabled = $true
        $btnWinUSB.Text = "INSTALAR DRIVER WINUSB"
        return
    }
    $ok = Install-WinUSBDriver -vid $cpuNow.VID -usbpid $cpuNow.USBPID -friendlyName $cpuNow.USB_NAME
    if ($ok) {
        $btnWinUSB.ForeColor = [System.Drawing.Color]::Lime
        $btnWinUSB.Text = "DRIVER OK - RECONECTA"
        $Global:lblStatus.Text = " RNX TOOL PRO v2.3 | WinUSB instalado | Reconecta el equipo"
    } else {
        $btnWinUSB.ForeColor = [System.Drawing.Color]::Red
        $btnWinUSB.Text = "ERROR - VER LOG"
    }
    $btnWinUSB.Enabled = $true
})

#==========================================================================
# CREAR FICHA CLIENTE
# - Genera un JSON independiente por cliente en CLIENTES\
# - Correlativo corto (RNX-0001, RNX-0002...) apto para sticker en equipo
# - Ventana de formulario correctamente dimensionada y completa
#==========================================================================
function Get-NextFichaCorrelativo {
    $clientDir = [System.IO.Path]::Combine($script:SCRIPT_ROOT, "CLIENTES")
    if (-not (Test-Path $clientDir)) {
        New-Item $clientDir -ItemType Directory -Force | Out-Null
        return "RNX-0001"
    }
    $existing = Get-ChildItem $clientDir -Filter "RNX-*.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^RNX-(\d{4})_' } |
        ForEach-Object { [int]($_.Name -replace '^RNX-(\d{4})_.*','$1') } |
        Sort-Object -Descending |
        Select-Object -First 1

    if ($null -eq $existing) { return "RNX-0001" }
    $next = $existing + 1
    return "RNX-{0:D4}" -f $next
}

$btnCrearFicha.Add_Click({
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $correlativo = Get-NextFichaCorrelativo

        #--- Ventana principal del formulario ---
        $frmFicha = New-Object System.Windows.Forms.Form
        $frmFicha.Text          = "Nueva Ficha Cliente  [$correlativo]"
        $frmFicha.Size          = New-Object System.Drawing.Size(540, 620)
        $frmFicha.MinimumSize   = New-Object System.Drawing.Size(540, 620)
        $frmFicha.StartPosition = "CenterScreen"
        $frmFicha.FormBorderStyle = "FixedDialog"
        $frmFicha.MaximizeBox   = $false
        $frmFicha.BackColor     = [System.Drawing.Color]::FromArgb(28,28,35)
        $frmFicha.ForeColor     = [System.Drawing.Color]::WhiteSmoke
        $frmFicha.Font          = New-Object System.Drawing.Font("Segoe UI", 9)

        # Panel scrollable para el formulario
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Location    = New-Object System.Drawing.Point(0, 0)
        $panel.Size        = New-Object System.Drawing.Size(524, 520)
        $panel.AutoScroll  = $true
        $panel.BackColor   = [System.Drawing.Color]::FromArgb(28,28,35)
        $frmFicha.Controls.Add($panel)

        $colLabel = [System.Drawing.Color]::FromArgb(160,160,200)
        $colInput = [System.Drawing.Color]::FromArgb(40,40,55)
        $colBorde = [System.Drawing.Color]::FromArgb(80,80,120)

        $y      = 12
        $lx     = 14
        $ix     = 160
        $lw     = 140
        $iw     = 330
        $rowH   = 32

        function Add-Campo {
            param($label, $nombre, [string]$default="", [int]$multiline=0)
            $lbl = New-Object System.Windows.Forms.Label
            $lbl.Text      = $label
            $lbl.Location  = New-Object System.Drawing.Point($lx, ($script:y + 3))
            $lbl.Size      = New-Object System.Drawing.Size($lw, 22)
            $lbl.ForeColor = $colLabel
            $panel.Controls.Add($lbl)

            if ($multiline -gt 0) {
                $txt = New-Object System.Windows.Forms.TextBox
                $txt.Multiline    = $true
                $txt.ScrollBars   = "Vertical"
                $txt.Location     = New-Object System.Drawing.Point($ix, $script:y)
                $txt.Size         = New-Object System.Drawing.Size($iw, ($multiline * 20 + 8))
                $txt.Text         = $default
                $txt.BackColor    = $colInput
                $txt.ForeColor    = [System.Drawing.Color]::WhiteSmoke
                $txt.BorderStyle  = "FixedSingle"
                $panel.Controls.Add($txt)
                $script:campos[$nombre] = $txt
                $script:y += $multiline * 20 + 14
            } else {
                $txt = New-Object System.Windows.Forms.TextBox
                $txt.Location     = New-Object System.Drawing.Point($ix, $script:y)
                $txt.Size         = New-Object System.Drawing.Size($iw, 22)
                $txt.Text         = $default
                $txt.BackColor    = $colInput
                $txt.ForeColor    = [System.Drawing.Color]::WhiteSmoke
                $txt.BorderStyle  = "FixedSingle"
                $panel.Controls.Add($txt)
                $script:campos[$nombre] = $txt
                $script:y += $rowH
            }
        }

        function Add-Separador {
            param([string]$titulo)
            $sep = New-Object System.Windows.Forms.Label
            $sep.Text      = "  $titulo"
            $sep.Location  = New-Object System.Drawing.Point(8, ($script:y + 2))
            $sep.Size      = New-Object System.Drawing.Size(500, 20)
            $sep.BackColor = [System.Drawing.Color]::FromArgb(50,50,80)
            $sep.ForeColor = [System.Drawing.Color]::FromArgb(180,180,255)
            $sep.Font      = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
            $panel.Controls.Add($sep)
            $script:y += 26
        }

        $script:campos = @{}
        $script:y = $y

        # Correlativo (solo lectura, visible)
        $lblCorr = New-Object System.Windows.Forms.Label
        $lblCorr.Text      = "N° Ficha:"
        $lblCorr.Location  = New-Object System.Drawing.Point($lx, ($script:y + 3))
        $lblCorr.Size      = New-Object System.Drawing.Size($lw, 22)
        $lblCorr.ForeColor = $colLabel
        $panel.Controls.Add($lblCorr)
        $txtCorr = New-Object System.Windows.Forms.TextBox
        $txtCorr.Location  = New-Object System.Drawing.Point($ix, $script:y)
        $txtCorr.Size      = New-Object System.Drawing.Size(110, 22)
        $txtCorr.Text      = $correlativo
        $txtCorr.ReadOnly  = $true
        $txtCorr.BackColor = [System.Drawing.Color]::FromArgb(20,20,30)
        $txtCorr.ForeColor = [System.Drawing.Color]::FromArgb(100,200,255)
        $txtCorr.BorderStyle = "FixedSingle"
        $txtCorr.Font      = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
        $panel.Controls.Add($txtCorr)
        $script:y += $rowH

        Add-Separador "── DATOS DEL CLIENTE ──────────────────────────"
        Add-Campo "Nombre / Razón:" "nombre"
        Add-Campo "Teléfono:"       "telefono"
        Add-Campo "Email:"          "email"

        Add-Separador "── DATOS DEL EQUIPO ───────────────────────────"
        Add-Campo "Marca:"          "marca"
        Add-Campo "Modelo:"         "modelo"
        Add-Campo "IMEI:"           "imei"
        Add-Campo "S/N (Serial):"   "serial"
        Add-Campo "Color:"          "color"
        Add-Campo "Estado físico:"  "estado_fisico"

        Add-Separador "── SERVICIO ───────────────────────────────────"
        Add-Campo "Falla reportada:" "falla" "" 3
        Add-Campo "Diagnóstico:"     "diagnostico" "" 3
        Add-Campo "Servicio a realizar:" "servicio" "" 2
        Add-Campo "Precio (S/):"     "precio"

        Add-Separador "── OBSERVACIONES ──────────────────────────────"
        Add-Campo "Notas:"           "notas" "" 3

        # Fecha automática
        $fechaHoy = Get-Date -Format "dd/MM/yyyy HH:mm"

        # Botones en la parte inferior de la ventana (fuera del panel scroll)
        $pnlBotones = New-Object System.Windows.Forms.Panel
        $pnlBotones.Location  = New-Object System.Drawing.Point(0, 520)
        $pnlBotones.Size      = New-Object System.Drawing.Size(524, 60)
        $pnlBotones.BackColor = [System.Drawing.Color]::FromArgb(20,20,28)
        $frmFicha.Controls.Add($pnlBotones)

        $btnGuardar = New-Object System.Windows.Forms.Button
        $btnGuardar.Text      = "💾  GUARDAR FICHA"
        $btnGuardar.Location  = New-Object System.Drawing.Point(20, 12)
        $btnGuardar.Size      = New-Object System.Drawing.Size(200, 36)
        $btnGuardar.BackColor = [System.Drawing.Color]::FromArgb(30,100,60)
        $btnGuardar.ForeColor = [System.Drawing.Color]::White
        $btnGuardar.FlatStyle = "Flat"
        $btnGuardar.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $pnlBotones.Controls.Add($btnGuardar)

        $btnCancelar = New-Object System.Windows.Forms.Button
        $btnCancelar.Text     = "Cancelar"
        $btnCancelar.Location = New-Object System.Drawing.Point(240, 16)
        $btnCancelar.Size     = New-Object System.Drawing.Size(100, 28)
        $btnCancelar.BackColor = [System.Drawing.Color]::FromArgb(70,30,30)
        $btnCancelar.ForeColor = [System.Drawing.Color]::White
        $btnCancelar.FlatStyle = "Flat"
        $pnlBotones.Controls.Add($btnCancelar)

        $btnCancelar.Add_Click({ $frmFicha.Close() })

        $btnGuardar.Add_Click({
            # Validacion minima
            if (-not $script:campos["nombre"].Text.Trim()) {
                [System.Windows.Forms.MessageBox]::Show(
                    "El campo NOMBRE es obligatorio.",
                    "Validacion",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                return
            }

            # Construir objeto JSON
            $ficha = [ordered]@{
                correlativo      = $correlativo
                fecha_ingreso    = $fechaHoy
                fecha_modified   = $fechaHoy
                cliente = [ordered]@{
                    nombre   = $script:campos["nombre"].Text.Trim()
                    telefono = $script:campos["telefono"].Text.Trim()
                    email    = $script:campos["email"].Text.Trim()
                }
                equipo = [ordered]@{
                    marca         = $script:campos["marca"].Text.Trim()
                    modelo        = $script:campos["modelo"].Text.Trim()
                    imei          = $script:campos["imei"].Text.Trim()
                    serial        = $script:campos["serial"].Text.Trim()
                    color         = $script:campos["color"].Text.Trim()
                    estado_fisico = $script:campos["estado_fisico"].Text.Trim()
                }
                servicio = [ordered]@{
                    falla_reportada   = $script:campos["falla"].Text.Trim()
                    diagnostico       = $script:campos["diagnostico"].Text.Trim()
                    servicio_realizar = $script:campos["servicio"].Text.Trim()
                    precio            = $script:campos["precio"].Text.Trim()
                    estado            = "PENDIENTE"
                }
                notas = $script:campos["notas"].Text.Trim()
            }

            # Definir nombre de archivo y carpeta destino
            $clientDir = [System.IO.Path]::Combine($script:SCRIPT_ROOT, "CLIENTES")
            if (-not (Test-Path $clientDir)) {
                New-Item $clientDir -ItemType Directory -Force | Out-Null
            }

            # Nombre del archivo: RNX-0001_NombreCliente_Modelo.json
            $nombreSafe = ($ficha.cliente.nombre -replace '[\\/:*?"<>|]','_') -replace '\s+','_'
            $modeloSafe = ($ficha.equipo.modelo  -replace '[\\/:*?"<>|]','_') -replace '\s+','_'
            if (-not $nombreSafe) { $nombreSafe = "Cliente" }
            if (-not $modeloSafe) { $modeloSafe = "Equipo" }
            $fileName = "${correlativo}_${nombreSafe}_${modeloSafe}.json"
            $filePath = [System.IO.Path]::Combine($clientDir, $fileName)

            try {
                $jsonStr = $ficha | ConvertTo-Json -Depth 5
                [System.IO.File]::WriteAllText($filePath, $jsonStr, [System.Text.Encoding]::UTF8)

                GenLog ""
                GenLog "[*] ===== FICHA CLIENTE CREADA ====="
                GenLog "[+] N° Ficha   : $correlativo"
                GenLog "[+] Cliente    : $($ficha.cliente.nombre)"
                GenLog "[+] Equipo     : $($ficha.equipo.marca) $($ficha.equipo.modelo)"
                GenLog "[+] IMEI       : $($ficha.equipo.imei)"
                GenLog "[+] Archivo    : CLIENTES\$fileName"
                GenLog "[OK] Ficha guardada correctamente."

                [System.Windows.Forms.MessageBox]::Show(
                    "Ficha creada exitosamente!`n`nN° Ficha: $correlativo`nArchivo: $fileName",
                    "FICHA GUARDADA",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
                $frmFicha.Close()
            } catch {
                GenLog "[!] Error al guardar ficha: $_"
                [System.Windows.Forms.MessageBox]::Show(
                    "Error al guardar la ficha:`n$_",
                    "ERROR",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })

        $frmFicha.ShowDialog() | Out-Null

    } catch {
        GenLog "[!] Error al abrir formulario de ficha: $_"
    }
})

#==========================================================================
# ORGANIZAR FIRMWARE
#
# Logica de clasificacion inteligente:
#   1. Pares EFS + sec_efs con correlacion de hora exacta -> juntos
#   2. Pares NVRAM + NVDATA con correlacion inmediata (+-60s) -> juntos
#   3. Grupo NVRAM + NVDATA + protect1 + protect2 si todos correlacionan
#   4. Archivos .ffu -> EMMC_FIRMWARE\
#   5. Archivos .qcn -> QCN\
#   6. Solo mueve archivos que tengan relacion con telefonos:
#      - Nombre contiene IMEI (15 digitos), S/N, modelo conocido,
#        marca, terminos de telefonia o particiones de movil
#   7. El resto (documentos, instaladores, etc) NO SE MUEVE
#==========================================================================

# Base de conocimiento: terminos que identifican archivos de telefono
$script:PhoneKeywords = @(
    # Marcas
    'samsung','xiaomi','redmi','poco','huawei','honor','motorola','moto',
    'nokia','oppo','realme','vivo','oneplus','asus','lg','htc','sony',
    'alcatel','zte','wiko','tecno','infinix','itel','blackview',
    # Terminos de particiones / firmware movil
    'efs','sec_efs','nvram','nvdata','nvcfg','persist',
    'modem','baseband','bootloader','recovery','boot',
    'system','vendor','product','userdata','cache',
    'protect','protect1','protect2',
    'firmware','rom','flash','odin','qfil','qpst',
    'scatter','preloader','lk','tee','super',
    # Terminos de identificacion
    'imei','serial','sn','sncode','meid','iccid',
    # Extensiones / formatos de firmware
    'tar\.md5','\.ozip','\.ofp','\.kdz','\.ffu','\.qcn',
    # Modelos comunes (prefijos/sufijos)
    'sm-','sph-','sch-','gt-',    # Samsung
    'miui','mi\d','redmi\d',       # Xiaomi
    'rn\d','m\d+s','m\d+pro',
    'g\d{3}','g\d{4}',             # Motorola/LG
    'cph\d','rmx\d',               # OPPO/Realme
    'vne-','lya-','ana-','elle-',  # Huawei
    # Terminos generales hardware movil
    'mtk','mediatek','qualcomm','snapdragon','exynos','helio',
    'baseband','qcn','qdl','edl','diag',
    'aboot','sbl','emmc','ufs','nand'
)

function Test-EsArchivoTelefono {
    param([string]$nombreArchivo)

    $name = [System.IO.Path]::GetFileNameWithoutExtension($nombreArchivo).ToLower()
    $ext  = [System.IO.Path]::GetExtension($nombreArchivo).ToLower()

    # Extensiones que son SIEMPRE de telefono
    if ($ext -in @('.ffu','.qcn','.ofp','.ozip','.kdz')) { return $true }

    # Detectar IMEI: 15 digitos consecutivos en cualquier parte del nombre
    if ($name -match '\d{15}') { return $true }

    # Detectar numero de serie tipo alfanumerico largo (8-20 chars alfanum)
    # Heuristica: segmento de 8+ chars solo alfanumericos sin separadores
    if ($name -match '[a-z0-9]{10,20}' -and $name -notmatch '\s') {
        # Solo si ademas hay otro indicador de telefono
    }

    # Buscar cualquier keyword en cualquier parte del nombre
    foreach ($kw in $script:PhoneKeywords) {
        if ($name -match $kw) { return $true }
    }

    # Detectar modelos Samsung: letras+numeros tipicos (SM-G998, A52s, etc)
    if ($name -match '\b(sm|sph|sch|gt)-[a-z0-9]+\b') { return $true }
    if ($name -match '\b[a-z]\d{2,4}[a-z]?\b' -and $name.Length -lt 30) {
        # Corto y parece modelo: A52, G998, etc — solo si hay ext tipica
        if ($ext -in @('.img','.bin','.tar','.zip','.md5')) { return $true }
    }

    return $false
}

function Get-GrupoCorrelativo {
    param(
        [System.IO.FileInfo]$fileA,
    [System.IO.FileInfo]$fileB,
        [int]$toleranciaSegundos = 60
    )
    $diff = [math]::Abs(($fileA.LastWriteTime - $fileB.LastWriteTime).TotalSeconds)
    return ($diff -le $toleranciaSegundos)
}

$btnOrganizarFW.Add_Click({
    $btn = $btnOrganizarFW
    $btn.Enabled = $false; $btn.Text = "ORGANIZANDO..."
    [System.Windows.Forms.Application]::DoEvents()

    try {
        GenLog ""
        GenLog "[*] ================================================"
        GenLog "[*] ORGANIZAR FIRMWARE - RNX TOOL PRO"
        GenLog "[*] ================================================"

        # Seleccionar carpeta origen
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Selecciona la carpeta con los archivos de firmware a organizar"
        $folderBrowser.ShowNewFolderButton = $false
        if ($folderBrowser.ShowDialog() -ne "OK") { GenLog "[~] Cancelado."; return }

        $srcDir  = $folderBrowser.SelectedPath
        $destDir = $srcDir  # Organizar dentro de la misma carpeta

        GenLog "[+] Carpeta: $srcDir"
        GenLog ""

        # Obtener todos los archivos (no recursivo en raiz)
        $allFiles = Get-ChildItem $srcDir -File -ErrorAction SilentlyContinue

        if ($allFiles.Count -eq 0) { GenLog "[~] No hay archivos en la carpeta."; return }
        GenLog "[+] Archivos encontrados: $($allFiles.Count)"
        GenLog ""

        # --- FASE 1: Filtrar solo archivos de telefono ---
        GenLog "[~] Fase 1: Clasificando archivos de telefono..."
        $phoneFiles = $allFiles | Where-Object { Test-EsArchivoTelefono $_.Name }
        $skipped    = $allFiles.Count - $phoneFiles.Count

        GenLog "[+] Archivos de telefono identificados: $($phoneFiles.Count)"
        if ($skipped -gt 0) { GenLog "[~] Archivos ignorados (no son de telefono): $skipped" }
        GenLog ""

        if ($phoneFiles.Count -eq 0) {
            GenLog "[~] No se encontraron archivos relacionados con telefonos."
            return
        }

        # Helper para mover archivo con log
        function Move-FW {
            param([System.IO.FileInfo]$file, [string]$subDir, [string]$motivo)
            $dest = [System.IO.Path]::Combine($destDir, $subDir)
            if (-not (Test-Path $dest)) { New-Item $dest -ItemType Directory -Force | Out-Null }
            $destFile = [System.IO.Path]::Combine($dest, $file.Name)
            if (-not (Test-Path $destFile)) {
                Move-Item $file.FullName $destFile -Force
                GenLog "  [->] $($file.Name)"
                GenLog "       => $subDir  ($motivo)"
            } else {
                GenLog "  [=] $($file.Name) ya existe en $subDir - omitido"
            }
        }

        $moved = [System.Collections.Generic.HashSet[string]]::new()

        # --- FASE 2: Detectar pares EFS + sec_efs correlacionados ---
        GenLog "[~] Fase 2: Buscando pares EFS / sec_efs correlacionados..."
        $efsFiles    = $phoneFiles | Where-Object { $_.Name -imatch '\befs\b' -and $_.Name -notmatch 'sec_efs' }
        $secEfsFiles = $phoneFiles | Where-Object { $_.Name -imatch 'sec_efs' }

        foreach ($ef in $efsFiles) {
            foreach ($sf in $secEfsFiles) {
                if ($moved.Contains($ef.FullName) -or $moved.Contains($sf.FullName)) { continue }
                # Correlacion EXACTA (misma hora, tolerancia 0s para confirmar lectura simultanea)
                if (Get-GrupoCorrelativo $ef $sf -toleranciaSegundos 0) {
                    $subG = "EFS_PARES\EFS_$($ef.LastWriteTime.ToString('yyyyMMdd_HHmmss'))"
                    GenLog "[+] Par EFS correlacionado (hora exacta):"
                    Move-FW $ef    $subG "EFS principal"
                    Move-FW $sf    $subG "sec_efs par"
                    $moved.Add($ef.FullName) | Out-Null
                    $moved.Add($sf.FullName) | Out-Null
                }
            }
        }

        # EFS sin par -> carpeta EFS sola
        foreach ($ef in $efsFiles) {
            if ($moved.Contains($ef.FullName)) { continue }
            GenLog "[+] EFS sin par:"
            Move-FW $ef "EFS_PARES\EFS_SOLO" "EFS sin sec_efs correlacionado"
            $moved.Add($ef.FullName) | Out-Null
        }
        foreach ($sf in $secEfsFiles) {
            if ($moved.Contains($sf.FullName)) { continue }
            GenLog "[+] sec_efs sin par:"
            Move-FW $sf "EFS_PARES\EFS_SOLO" "sec_efs sin EFS correlacionado"
            $moved.Add($sf.FullName) | Out-Null
        }

        # --- FASE 3: Detectar grupos NVRAM / NVDATA / protect1 / protect2 ---
        GenLog ""
        GenLog "[~] Fase 3: Buscando grupos NV correlacionados..."

        $nvramFiles    = $phoneFiles | Where-Object { $_.Name -imatch '\bnvram\b'    -and -not $moved.Contains($_.FullName) }
        $nvdataFiles   = $phoneFiles | Where-Object { $_.Name -imatch '\bnvdata\b'   -and -not $moved.Contains($_.FullName) }
        $protect1Files = $phoneFiles | Where-Object { $_.Name -imatch '\bprotect1\b' -and -not $moved.Contains($_.FullName) }
        $protect2Files = $phoneFiles | Where-Object { $_.Name -imatch '\bprotect2\b' -and -not $moved.Contains($_.FullName) }

        foreach ($nv in $nvramFiles) {
            if ($moved.Contains($nv.FullName)) { continue }

            $grupo = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
            $grupo.Add($nv)
            $stamp = $nv.LastWriteTime.ToString('yyyyMMdd_HHmmss')

            # Buscar NVDATA correlacionado (+-60s)
            $nvdataPar = $nvdataFiles | Where-Object {
                -not $moved.Contains($_.FullName) -and (Get-GrupoCorrelativo $nv $_ -toleranciaSegundos 60)
            } | Select-Object -First 1

            if ($nvdataPar) { $grupo.Add($nvdataPar) }

            # Si tenemos NVRAM+NVDATA, buscar protect1 y protect2 tambien correlacionados
            if ($nvdataPar) {
                $p1 = $protect1Files | Where-Object {
                    -not $moved.Contains($_.FullName) -and (Get-GrupoCorrelativo $nv $_ -toleranciaSegundos 60)
                } | Select-Object -First 1
                $p2 = $protect2Files | Where-Object {
                    -not $moved.Contains($_.FullName) -and (Get-GrupoCorrelativo $nv $_ -toleranciaSegundos 60)
                } | Select-Object -First 1
                if ($p1) { $grupo.Add($p1) }
                if ($p2) { $grupo.Add($p2) }
            }

            $subG = if ($grupo.Count -ge 3) {
                "NV_GRUPOS\NV_COMPLETO_$stamp"
            } elseif ($grupo.Count -eq 2) {
                "NV_GRUPOS\NV_PAR_$stamp"
            } else {
                "NV_GRUPOS\NV_SOLO"
            }

            $tipoLabel = switch ($grupo.Count) {
                1 { "NVRAM solo" }
                2 { "Par NVRAM+NVDATA" }
                default { "Grupo NV completo ($($grupo.Count) archivos)" }
            }
            GenLog "[+] $tipoLabel ($stamp):"
            foreach ($gf in $grupo) {
                Move-FW $gf $subG $tipoLabel
                $moved.Add($gf.FullName) | Out-Null
            }
        }

        # NVDATA sin par NVRAM
        foreach ($nd in $nvdataFiles) {
            if ($moved.Contains($nd.FullName)) { continue }
            GenLog "[+] NVDATA sin par:"
            Move-FW $nd "NV_GRUPOS\NV_SOLO" "NVDATA sin NVRAM correlacionado"
            $moved.Add($nd.FullName) | Out-Null
        }

        # protect1/protect2 que quedaron solos
        foreach ($pf in ($protect1Files + $protect2Files)) {
            if ($moved.Contains($pf.FullName)) { continue }
            Move-FW $pf "NV_GRUPOS\PROTECT_SOLO" "Protect sin grupo NV"
            $moved.Add($pf.FullName) | Out-Null
        }

        # --- FASE 4: Archivos .ffu -> EMMC_FIRMWARE ---
        GenLog ""
        GenLog "[~] Fase 4: Archivos FFU (EMMC Firmware)..."
        $ffuFiles = $phoneFiles | Where-Object { $_.Extension -ieq '.ffu' -and -not $moved.Contains($_.FullName) }
        foreach ($ff in $ffuFiles) {
            Move-FW $ff "EMMC_FIRMWARE" "Archivo FFU"
            $moved.Add($ff.FullName) | Out-Null
        }

        # --- FASE 5: Archivos .qcn ---
        GenLog ""
        GenLog "[~] Fase 5: Archivos QCN (NV Qualcomm)..."
        $qcnFiles = $phoneFiles | Where-Object { $_.Extension -ieq '.qcn' -and -not $moved.Contains($_.FullName) }
        foreach ($qf in $qcnFiles) {
            Move-FW $qf "QCN" "Archivo QCN Qualcomm"
            $moved.Add($qf.FullName) | Out-Null
        }

        # --- FASE 6: Resto de archivos de telefono -> FIRMWARE_GENERAL ---
        GenLog ""
        GenLog "[~] Fase 6: Resto de archivos de telefono..."
        $remaining = $phoneFiles | Where-Object { -not $moved.Contains($_.FullName) }
        foreach ($rf in $remaining) {
            Move-FW $rf "FIRMWARE_GENERAL" "Archivo de telefono"
            $moved.Add($rf.FullName) | Out-Null
        }

        # --- Resumen ---
        GenLog ""
        GenLog "[*] ================================================"
        GenLog "[OK] ORGANIZACION COMPLETADA"
        GenLog "[+] Archivos movidos   : $($moved.Count)"
        GenLog "[+] Archivos ignorados : $skipped (no relacionados con telefonos)"
        GenLog "[+] Destino            : $destDir"
        GenLog "[*] ================================================"

    } catch {
        GenLog "[!] Error en Organizar Firmware: $_"
    } finally {
        $btn.Enabled = $true; $btn.Text = "ORGANIZAR FIRMWARE"
    }
})