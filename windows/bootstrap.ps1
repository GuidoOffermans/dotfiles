# Set up a fresh Windows machine from these dotfiles. Safe to re-run.
#
#   winget install --id Git.Git -e
#   git clone https://github.com/GuidoOffermans/dotfiles.git $HOME\dotfiles
#   powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\windows\bootstrap.ps1
#
# Run as your normal user; it asks for admin (UAC) only where needed.

$ErrorActionPreference = 'Stop'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# --- System settings (HKLM, one UAC prompt for whatever is missing) ----------
$machineSettings = @(
    # lets stow and `ln -s` create symlinks without admin
    @{ Name = 'Developer Mode'; Key = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'; Value = 'AllowDevelopmentWithoutDevLicense' },
    # paths over 260 chars for apps that opt in (git has its own core.longpaths)
    @{ Name = 'Long paths';     Key = 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem';          Value = 'LongPathsEnabled' }
)
Step 'System settings'
$missing = @()
foreach ($s in $machineSettings) {
    $current = (Get-ItemProperty "Registry::$($s.Key)" -ErrorAction SilentlyContinue).($s.Value)
    if ($current -eq 1) {
        Write-Host "$($s.Name) already enabled"
    } else {
        $missing += $s
    }
}
if ($missing) {
    $cmds = ($missing | ForEach-Object { "reg add `"$($_.Key)`" /t REG_DWORD /f /v $($_.Value) /d 1" }) -join ' && '
    $p = Start-Process cmd.exe -Verb RunAs -Wait -PassThru -ArgumentList "/c $cmds"
    if ($p.ExitCode -ne 0) { throw "failed to enable: $(($missing.Name) -join ', ')" }
    Write-Host "enabled: $(($missing.Name) -join ', ')"
}

# --- WSL2 (Docker Desktop's backend) ------------------------------------------
Step 'WSL2'
$rebootNeeded = $false
# PS 5.1 turns redirected native stderr into a terminating error under 'Stop'
$ErrorActionPreference = 'Continue'
wsl.exe --status *> $null
$wslInstalled = $LASTEXITCODE -eq 0
$ErrorActionPreference = 'Stop'
if ($wslInstalled) {
    Write-Host 'already installed'
} else {
    # --no-distribution: just the WSL2 platform, no Ubuntu
    $p = Start-Process wsl.exe -Verb RunAs -Wait -PassThru -ArgumentList '--install --no-distribution'
    if ($p.ExitCode -ne 0) { throw "failed to install WSL (exit $($p.ExitCode))" }
    $rebootNeeded = $true
    Write-Host 'installed (reboot required)'
}

# --- User environment ---------------------------------------------------------
# Point XDG-aware tools (nvim, git, gh, lazygit, ...) at ~/.config instead of
# %APPDATA% / %LOCALAPPDATA%, matching Mac/Linux so config/.config can be shared
Step 'XDG_CONFIG_HOME'
$xdg = "$env:USERPROFILE\.config"
if ([Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'User') -eq $xdg) {
    Write-Host 'already set'
} else {
    [Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $xdg, 'User')
    Write-Host "set to $xdg"
}
$env:XDG_CONFIG_HOME = $xdg

# --- Packages ----------------------------------------------------------------
# One at a time rather than `winget import`: import exits non-zero whenever
# anything is already installed, which would hide real failures.
Step 'winget packages'
$wingetFlags = @('--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
$packages = (Get-Content "$PSScriptRoot\packages.json" -Raw | ConvertFrom-Json).Sources.Packages.PackageIdentifier
foreach ($id in $packages) {
    winget list --id $id -e --accept-source-agreements --disable-interactivity | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$id already installed"
        continue
    }
    Write-Host "installing $id"
    winget install --id $id -e @wingetFlags
    if ($LASTEXITCODE -ne 0) { throw "failed to install $id (exit $LASTEXITCODE)" }
}
Update-Path

# Build Tools need a custom --override, so they can't live in packages.json
Step 'Visual Studio Build Tools (C++ linker for Rust)'
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
function Get-VSPath($requires) {
    if (-not (Test-Path $vswhere)) { return $null }
    $vsArgs = @('-products', '*', '-property', 'installationPath')
    if ($requires) { $vsArgs += @('-requires', $requires) }
    & $vswhere @vsArgs | Select-Object -First 1
}
$vcWorkload = 'Microsoft.VisualStudio.Workload.VCTools'
if (Get-VSPath 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64') {
    Write-Host 'already installed'
} elseif ($btPath = Get-VSPath) {
    # Build Tools/VS present but without the C++ tools: winget would say
    # "already installed" and do nothing, so add the workload directly
    Write-Host "adding C++ workload to $btPath"
    $setup = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe"
    $p = Start-Process $setup -Verb RunAs -Wait -PassThru -ArgumentList `
        "modify --installPath `"$btPath`" --add $vcWorkload --includeRecommended --passive --norestart"
    if ($p.ExitCode -notin 0, 3010) { throw "failed to add C++ workload (exit $($p.ExitCode))" }
} else {
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e @wingetFlags `
        --override "--wait --passive --add $vcWorkload --includeRecommended"
    if ($LASTEXITCODE -ne 0) { throw "failed to install Build Tools (exit $LASTEXITCODE)" }
}

Step 'Rust stable toolchain'
& "$env:USERPROFILE\.cargo\bin\rustup.exe" default stable
if ($LASTEXITCODE -ne 0) { throw 'rustup failed' }

# --- Font ----------------------------------------------------------------------
Step 'JetBrains Mono Nerd Font'
# installed per-user (HKCU) by oh-my-posh, but may also exist machine-wide (HKLM)
$hasFont = 'HKCU:', 'HKLM:' | Where-Object {
    $fonts = Get-ItemProperty "$_\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
    $fonts -and ($fonts.PSObject.Properties.Value -like '*JetBrainsMonoNerdFont-Regular*')
}
if ($hasFont) {
    Write-Host 'already installed'
} else {
    oh-my-posh font install JetBrainsMono
    if ($LASTEXITCODE -ne 0) { throw 'font install failed' }
}

# --- Stow + symlinks (Git Bash) -------------------------------------------------
$bash = "$env:ProgramFiles\Git\bin\bash.exe"
$here = $PSScriptRoot -replace '\\', '/'

Step 'GNU Stow'
& $bash -lc "'$here/install-stow.sh'"
if ($LASTEXITCODE -ne 0) { throw 'stow install failed' }

Step 'ble.sh'
& $bash -lc "'$here/install-blesh.sh'"
if ($LASTEXITCODE -ne 0) { throw 'ble.sh install failed' }

Step 'Linking dotfiles'
& $bash -lc "'$here/install.sh'"
if ($LASTEXITCODE -ne 0) { throw 'linking failed' }

Write-Host "`nDone. Open a new Windows Terminal window to pick everything up." -ForegroundColor Green
if ($rebootNeeded) {
    Write-Host 'Reboot to finish the WSL install; Docker Desktop will not start until then.' -ForegroundColor Yellow
}
