<#
.SYNOPSIS
  Render profile/profile.html into profile/profile.png.

.DESCRIPTION
  The organisation profile is a single image, so profile\profile.html is the
  source of truth. This script is the only thing that produces the PNG.
  Run it after any change to the poster markup or the vendored design-system
  CSS, then commit the regenerated profile.png alongside the source change.

  Requires a Chrome/Chromium install and network access for the webfonts.

.EXAMPLE
  .\scripts\render-profile.ps1
#>
[CmdletBinding()]
param(
  [int]$Width = 1200
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'profile\profile.html'
$out = Join-Path $root 'profile\profile.png'

$candidates = @(
  "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
)
$chrome = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw 'no Chrome/Edge found' }

$url = 'file:///' + ((Resolve-Path $src).Path -replace '\\', '/')
$err = Join-Path $env:TEMP 'hw-render-profile-err.txt'

# Pass 1: the page writes its own rendered height into <title>, so the
# screenshot viewport can be sized to the content instead of guessing.
$domFile = Join-Path $env:TEMP 'hw-profile-dom.html'
$measure = @(
  '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-sandbox',
  "--window-size=$Width,1200", '--virtual-time-budget=15000', '--dump-dom', $url
)
Start-Process -FilePath $chrome -ArgumentList $measure -NoNewWindow -Wait `
  -RedirectStandardOutput $domFile -RedirectStandardError $err | Out-Null

$dom = Get-Content $domFile -Raw
$m = [regex]::Match($dom, 'HW-H(\d+)')
if (-not $m.Success) { throw "could not measure the rendered height of $src" }
$height = [int]$m.Groups[1].Value

# Pass 2: screenshot at exactly that height.
if (Test-Path $out) { Remove-Item $out -Force }
$shoot = @(
  '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-sandbox',
  '--force-device-scale-factor=1', "--screenshot=$out",
  "--window-size=$Width,$height", '--virtual-time-budget=15000', $url
)
Start-Process -FilePath $chrome -ArgumentList $shoot -NoNewWindow -Wait `
  -RedirectStandardError $err | Out-Null

if (-not (Test-Path $out)) { throw 'the screenshot was not written' }
Write-Host "wrote $out (${Width}x$height) $((Get-Item $out).Length) bytes"
