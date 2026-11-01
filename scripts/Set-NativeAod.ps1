param(
    [Parameter(Mandatory=$true)][string]$Manifest,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [Parameter(Mandatory=$true)][string]$Serial,
    [ValidateSet('Install','Restore')][string]$Action='Install'
)
$ErrorActionPreference='Stop'
$Manifest=(Resolve-Path -LiteralPath $Manifest).Path
$config=Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
$built=Get-Content -LiteralPath (Join-Path $WorkDir 'build.json') -Raw | ConvertFrom-Json
foreach($field in @('native_path','original_sha256','candidate_sha256')){
    if($built.$field -ne $config.$field){throw "Built probe differs from manifest: $field"}
}
if($config.native_path -notmatch '^/wf/wf[0-9]{1,2}/aod/script/main\.js$'){throw 'Unsupported target'}
if($config.package -notmatch '^com\.oplus\.wearos\.watchface\.[a-z0-9.]+$'){throw 'Invalid package'}
$model=(& adb -s $Serial shell getprop ro.product.model | Out-String).Trim()
if($LASTEXITCODE -ne 0 -or $model -ne $config.model){throw "Unexpected device: $model"}
$packagePaths=& adb -s $Serial shell pm path $config.package
if($LASTEXITCODE -ne 0 -or !($packagePaths -match '^package:/')){throw 'Expected original package unavailable'}
$base=Split-Path -Parent $Manifest
$original=Join-Path $base $config.original_file
$candidate=Join-Path $base $config.candidate_file
$probe=Join-Path $WorkDir 'probe.jar'
foreach($entry in @(@($original,$config.original_sha256),@($candidate,$config.candidate_sha256),@($probe,$built.probe_sha256))){
    if((Get-FileHash -LiteralPath $entry[0] -Algorithm SHA256).Hash -ne $entry[1]){throw ('Hash mismatch: '+$entry[0])}
}
$remoteDir='/data/local/tmp/oneplus-rtos-watchface'
& adb -s $Serial shell mkdir -p $remoteDir
if($LASTEXITCODE -ne 0){throw 'Staging directory unavailable'}
foreach($entry in @(@($original,'aod-main-original.js'),@($candidate,'aod-main-candidate.js'),@($probe,'probe.jar'))){
    & adb -s $Serial push $entry[0] ($remoteDir+'/'+$entry[1])
    if($LASTEXITCODE -ne 0){throw ('Transfer failed: '+$entry[1])}
}
$mode=if($Action -eq 'Restore'){'adb-restore-aod'}else{'adb-install-aod'}
$remoteCommand='CLASSPATH='+$remoteDir+'/probe.jar app_process / com.christophe.research.McuReadProbe '+$mode
$result=& adb -s $Serial shell $remoteCommand 2>&1
$exitCode=$LASTEXITCODE
$log=Join-Path $WorkDir ('native-aod-'+$Action.ToLower()+'-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.txt')
$result | Set-Content -LiteralPath $log -Encoding utf8
$result | Where-Object {$_ -match '^MCU_|Exception|Probe finished'}
if($exitCode -ne 0 -or !($result -match '^MCU_AOD_(VERIFIED_SHA256|ALREADY_VERIFIED) ')){throw "Operation not verified. Inspect $log"}
Write-Output 'Transfer verified. Check native AOD off the charger and record visual confirmation separately.'
