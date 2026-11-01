param(
    [Parameter(Mandatory=$true)][string]$Manifest,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [string]$SdkRoot=(Join-Path $env:LOCALAPPDATA 'Android\Sdk')
)
$ErrorActionPreference='Stop'
$config=Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
if($config.native_path -notmatch '^/wf/wf[0-9]{1,2}/aod/script/main\.js$'){throw 'Unsupported native target'}
foreach($field in @('original_sha256','candidate_sha256')){
    if($config.$field -notmatch '^[a-fA-F0-9]{64}$'){throw "Invalid $field"}
}
$WorkDir=[IO.Path]::GetFullPath($WorkDir)
$androidJar=Get-ChildItem -LiteralPath (Join-Path $SdkRoot 'platforms') -Directory |
    Where-Object {$_.Name -match '^android-\d+$'} | Sort-Object {[int]($_.Name -replace 'android-','')} -Descending |
    ForEach-Object {Join-Path $_.FullName 'android.jar'} | Where-Object {Test-Path -LiteralPath $_} | Select-Object -First 1
$d8=Get-ChildItem -LiteralPath (Join-Path $SdkRoot 'build-tools') -Directory |
    Where-Object {$_.Name -match '^\d+\.\d+\.\d+$'} | Sort-Object {[version]$_.Name} -Descending |
    ForEach-Object {Join-Path $_.FullName 'd8.bat'} | Where-Object {Test-Path -LiteralPath $_} | Select-Object -First 1
if(!$androidJar -or !$d8){throw 'Android platform or d8 unavailable'}
$classes=Join-Path $WorkDir 'classes'
$dex=Join-Path $WorkDir 'dex'
New-Item -ItemType Directory -Path $WorkDir,$classes,$dex -Force | Out-Null
$template=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'McuReadProbe.java.template') -Raw
$source=$template.Replace('@@NATIVE_PATH@@',$config.native_path).Replace('@@ORIGINAL_SHA@@',$config.original_sha256.ToLower()).Replace('@@CANDIDATE_SHA@@',$config.candidate_sha256.ToLower())
$sourcePath=Join-Path $WorkDir 'McuReadProbe.java'
[IO.File]::WriteAllText($sourcePath,$source,[Text.UTF8Encoding]::new($false))
& javac --release 8 -Xlint:-options -cp $androidJar -d $classes $sourcePath
if($LASTEXITCODE -ne 0){throw 'Java compilation failed'}
$classesJar=Join-Path $WorkDir 'probe-classes.jar'
& jar cf $classesJar -C $classes .
if($LASTEXITCODE -ne 0){throw 'Class archive failed'}
& $d8 --lib $androidJar --output $dex $classesJar
if($LASTEXITCODE -ne 0){throw 'Dex compilation failed'}
$probe=Join-Path $WorkDir 'probe.jar'
& jar cf $probe -C $dex classes.dex
if($LASTEXITCODE -ne 0){throw 'Probe archive failed'}
[ordered]@{
    native_path=$config.native_path
    original_sha256=$config.original_sha256.ToLower()
    candidate_sha256=$config.candidate_sha256.ToLower()
    probe_sha256=(Get-FileHash -LiteralPath $probe -Algorithm SHA256).Hash.ToLower()
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $WorkDir 'build.json') -Encoding utf8
Write-Output $probe
