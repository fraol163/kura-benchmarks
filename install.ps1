# Kura Windows Standalone PowerShell Installer
# Installs precompiled Kura native binary and configures user environment.
# Zero telemetry. Zero external build dependencies.

$ErrorActionPreference = "Stop"

# 1. Detect Latest Release Tag
$KuraTag = $env:KURA_VERSION
if (-not $KuraTag) {
    try {
        $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/fraol163/kura-benchmarks/releases/latest" -Headers @{ "User-Agent" = "Kura-Installer" } -ErrorAction Stop
        $KuraTag = $ReleaseInfo.tag_name
    } catch {
        $KuraTag = "v1.0.0"
    }
}
if (-not $KuraTag.StartsWith("v")) {
    $KuraTag = "v$KuraTag"
}

$KuraHome = if ($env:KURA_HOME) { $env:KURA_HOME } else { Join-Path $HOME ".kura" }
$BinDir = Join-Path $KuraHome "bin"
$ExePath = Join-Path $BinDir "kura.exe"

Write-Host @"

  ==================================================================================
                     STORAGE-NATIVE DECOUPLED INFERENCE ENGINE
                 Production Release $KuraTag : Zero-Telemetry Verified
  ==================================================================================

"@ -ForegroundColor Cyan

# 2. Architecture Check
$Arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
Write-Host "[*] Probing host architecture: $Arch on Windows" -ForegroundColor DarkGray

if ($Arch -ne [System.Runtime.InteropServices.Architecture]::X64) {
    Write-Warning "Kura on Windows currently provides prebuilt binaries optimized for x86-64."
}

# 3. Prepare Directories
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $KuraHome "models") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $KuraHome "logs") | Out-Null

# 4. Download Release Asset
$DownloadUrl = "https://github.com/fraol163/kura-benchmarks/releases/download/$KuraTag/kura-windows-x86_64.zip"
$ZipTemp = Join-Path $env:TEMP "kura-windows-x86_64.zip"
$ExtractTemp = Join-Path $env:TEMP "kura-extract-$([System.Guid]::NewGuid().ToString('N'))"

Write-Host "[*] Fetching precompiled native binary for $KuraTag from GitHub Releases..." -ForegroundColor Yellow

$WebClient = New-Object System.Net.WebClient
$WebClient.Headers.Add("User-Agent", "Kura-Installer/0.5")

try {
    $WebClient.DownloadFile($DownloadUrl, $ZipTemp)
} catch {
    Write-Host "[!] Primary release asset download failed from $DownloadUrl" -ForegroundColor Red
    throw $_
}

# 5. Extract Binary
Write-Host "[*] Unpacking binary package..." -ForegroundColor DarkGray
Expand-Archive -Path $ZipTemp -DestinationPath $ExtractTemp -Force

$FoundExe = Get-ChildItem -Path $ExtractTemp -Recurse -Filter "kura*.exe" | Select-Object -First 1
if ($FoundExe) {
    Copy-Item -Path $FoundExe.FullName -Destination $ExePath -Force
} else {
    throw "kura.exe not found in extracted archive."
}

# Cleanup Temp
Remove-Item -Path $ZipTemp -Force -ErrorAction SilentlyContinue
Remove-Item -Path $ExtractTemp -Recurse -Force -ErrorAction SilentlyContinue

# 6. Configure User PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$BinDir*") {
    $NewPath = "$UserPath;$BinDir"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, [EnvironmentVariableTarget]::User)
    $env:Path = "$env:Path;$BinDir"
    Write-Host "[+] Added $BinDir to User Environment PATH" -ForegroundColor Green
} else {
    Write-Host "[+] $BinDir is already in User PATH" -ForegroundColor DarkGray
}

Write-Host "[+] Kura native engine installed successfully ($KuraTag): $ExePath" -ForegroundColor Green
Write-Host @"

Quick Commands:
  kura tui                        Launch interactive terminal UI
  kura run <model.gguf>           Execute text generation
  kura serve --port 8080          Start OpenAI-compatible HTTP server
  kura update check               Query genuine update availability
  kura profile                    Inspect CPU SIMD and NVMe storage bandwidth
  kura plan --model <model.gguf>  Compile LOOM physical execution plan

"@ -ForegroundColor White
