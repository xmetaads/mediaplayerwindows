<#
    CONG TAC CHUYEN HUONG  -  mediaplayerwindows.com
    ---------------------------------------------------------------
    Cach dung:

      .\redirect.ps1                 xem trang thai hien tai
      .\redirect.ps1 -Off            TAT chuyen huong
      .\redirect.ps1 -On             BAT chuyen huong
      .\redirect.ps1 -Target "https://vidu.com/"    doi dich den
      .\redirect.ps1 -On -Permanent  bat va dung 301 (SEO, kho tat lai)
      .\redirect.ps1 -On -Temporary  bat va dung 307 (mac dinh, tat duoc ngay)

    Script tu tai repo ve, sua middleware.js, commit va push.
    Vercel deploy trong khoang 30 giay.
#>

[CmdletBinding()]
param(
    [switch]$On,
    [switch]$Off,
    [string]$Target,
    [switch]$Permanent,
    [switch]$Temporary
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/xmetaads/mediaplayerwindows.git'
$SiteUrl = 'https://www.mediaplayerwindows.com/'
$Work    = Join-Path $env:TEMP 'mpw-redirect-switch'

function Get-LiveStatus {
    $url = $SiteUrl + '?probe=' + [guid]::NewGuid().ToString('N')
    try {
        $r = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -UseBasicParsing -TimeoutSec 20
        return [pscustomobject]@{ Code = $r.StatusCode; Location = $null }
    } catch {
        $resp = $_.Exception.Response
        if ($resp) {
            $code = [int]$resp.StatusCode
            $loc  = $resp.Headers['Location']
            return [pscustomobject]@{ Code = $code; Location = $loc }
        }
        return [pscustomobject]@{ Code = 0; Location = $null }
    }
}

function Show-Live {
    $s = Get-LiveStatus
    if ($s.Code -eq 0) {
        Write-Host "  Website     : khong ket noi duoc" -ForegroundColor Red
    } elseif ($s.Code -ge 300 -and $s.Code -lt 400) {
        Write-Host "  Website     : DANG CHUYEN HUONG (HTTP $($s.Code)) -> $($s.Location)" -ForegroundColor Green
    } else {
        Write-Host "  Website     : KHONG chuyen huong (HTTP $($s.Code)) - hien trang goc" -ForegroundColor Yellow
    }
}

if ($On -and $Off)               { throw 'Khong the vua -On vua -Off.' }
if ($Permanent -and $Temporary)  { throw 'Khong the vua -Permanent vua -Temporary.' }

# --- Tai ban moi nhat -----------------------------------------------------
if (Test-Path $Work) { Remove-Item $Work -Recurse -Force }
Write-Host 'Dang tai repo...' -ForegroundColor DarkGray
git clone --quiet --depth 1 $RepoUrl $Work
if ($LASTEXITCODE -ne 0) { throw 'Clone that bai.' }

$File = Join-Path $Work 'middleware.js'
if (-not (Test-Path $File)) { throw "Khong tim thay middleware.js trong repo." }
$text = Get-Content $File -Raw

$curEnabled = [regex]::Match($text, '(?m)^const ENABLED\s*=\s*(true|false);').Groups[1].Value
$curTarget  = [regex]::Match($text, "(?m)^const TARGET\s*=\s*'([^']*)';").Groups[1].Value
$curPerm    = [regex]::Match($text, '(?m)^const PERMANENT\s*=\s*(true|false);').Groups[1].Value

# --- Chi xem trang thai ---------------------------------------------------
if (-not $On -and -not $Off -and -not $Target -and -not $Permanent -and -not $Temporary) {
    Write-Host ''
    Write-Host 'TRANG THAI CHUYEN HUONG' -ForegroundColor Cyan
    if ($curEnabled -eq 'true') {
        Write-Host "  Cong tac    : BAT" -ForegroundColor Green
    } else {
        Write-Host "  Cong tac    : TAT" -ForegroundColor Yellow
    }
    Write-Host "  Dich den    : $curTarget"
    if ($curPerm -eq 'true') {
        Write-Host "  Kieu        : 301 vinh vien (trinh duyet cache lau)"
    } else {
        Write-Host "  Kieu        : 307 tam thoi (tat duoc ngay)"
    }
    Show-Live
    Write-Host ''
    Write-Host '  Doi trang thai:  .\redirect.ps1 -On   |   .\redirect.ps1 -Off' -ForegroundColor DarkGray
    Write-Host ''
    Remove-Item $Work -Recurse -Force
    return
}

# --- Ap dung thay doi -----------------------------------------------------
$newEnabled = $curEnabled
$newTarget  = $curTarget
$newPerm    = $curPerm
$changes    = @()

if ($On)  { $newEnabled = 'true' }
if ($Off) { $newEnabled = 'false' }
if ($Permanent) { $newPerm = 'true' }
if ($Temporary) { $newPerm = 'false' }

if ($Target) {
    if ($Target -notmatch '^https?://') { throw "Dich den phai bat dau bang https:// - ban nhap: $Target" }
    $newTarget = $Target
    if (-not $Off) { $newEnabled = 'true' }   # doi dich thi mac nhien bat len
}

if ($newEnabled -ne $curEnabled) { $changes += "cong tac $curEnabled -> $newEnabled" }
if ($newTarget  -ne $curTarget)  { $changes += "dich den -> $newTarget" }
if ($newPerm    -ne $curPerm)    { $changes += "kieu -> $(if ($newPerm -eq 'true') { '301' } else { '307' })" }

if ($changes.Count -eq 0) {
    Write-Host 'Khong co gi thay doi - cau hinh da dung nhu vay roi.' -ForegroundColor Yellow
    Show-Live
    Remove-Item $Work -Recurse -Force
    return
}

$text = [regex]::Replace($text, '(?m)^const ENABLED(\s*)=\s*(true|false);',   "const ENABLED`$1= $newEnabled;")
$text = [regex]::Replace($text, "(?m)^const TARGET(\s*)=\s*'[^']*';",         "const TARGET`$1= '$newTarget';")
$text = [regex]::Replace($text, '(?m)^const PERMANENT(\s*)=\s*(true|false);', "const PERMANENT`$1= $newPerm;")
Set-Content -Path $File -Value $text -Encoding utf8 -NoNewline

Push-Location $Work
try {
    git add middleware.js
    git commit --quiet -m "Redirect switch: $($changes -join ', ')"
    if ($LASTEXITCODE -ne 0) { throw 'Commit that bai.' }
    $env:GIT_TERMINAL_PROMPT = '0'
    git push --quiet origin HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Push that bai - kiem tra dang nhap GitHub.' }
} finally {
    Pop-Location
}

Write-Host ''
Write-Host 'DA DAY LEN GITHUB:' -ForegroundColor Cyan
foreach ($c in $changes) { Write-Host "  - $c" }
Write-Host ''

# --- Cho Vercel deploy ----------------------------------------------------
$wantRedirect = ($newEnabled -eq 'true')
Write-Host 'Dang cho Vercel deploy' -NoNewline -ForegroundColor DarkGray
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 8
    Write-Host '.' -NoNewline -ForegroundColor DarkGray
    $s = Get-LiveStatus
    $isRedirect = ($s.Code -ge 300 -and $s.Code -lt 400)
    if ($isRedirect -eq $wantRedirect) {
        Write-Host ''
        Write-Host 'XONG.' -ForegroundColor Green
        Show-Live
        Write-Host ''
        Remove-Item $Work -Recurse -Force
        return
    }
}

Write-Host ''
Write-Host 'Da day len GitHub nhung Vercel chua deploy xong sau ~2 phut.' -ForegroundColor Yellow
Write-Host 'Kiem tra lai sau bang:  .\redirect.ps1' -ForegroundColor Yellow
Remove-Item $Work -Recurse -Force
