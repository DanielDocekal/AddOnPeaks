# Builds the release ZIP for AddOnPeaks.
# Output: dist\AddOnPeaks-<version>.zip, containing one folder "AddOnPeaks".

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$toc = Join-Path $root 'AddOnPeaks.toc'
$version = (Select-String -LiteralPath $toc -Pattern '^## Version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()

$dist = Join-Path $root 'dist'
$stage = Join-Path $dist 'AddOnPeaks'
$zip = Join-Path $dist "AddOnPeaks-$version.zip"

if (Test-Path $dist) { Remove-Item -LiteralPath $dist -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null

# Only the files the game needs plus the license and readme.
$files = 'AddOnPeaks.toc', 'AddOnPeaks.lua', 'LICENSE', 'README.md'
foreach ($f in $files) {
  Copy-Item -LiteralPath (Join-Path $root $f) -Destination $stage
}

Compress-Archive -Path $stage -DestinationPath $zip -Force
Remove-Item -LiteralPath $stage -Recurse -Force

"Hotovo: $zip"
