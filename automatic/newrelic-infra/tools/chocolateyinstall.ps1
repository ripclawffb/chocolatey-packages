﻿$ErrorActionPreference = 'Stop';

$additionalArgs = ''
$packageParameters = Get-PackageParameters

# see if any parameters were passed
if ($packageParameters['GenerateConfig']) { $GenerateConfig = $packageParameters['GenerateConfig'] }
if ($packageParameters['LicenseKey']) { $LicenseKey = $packageParameters['LicenseKey'] }
if ($packageParameters['DisplayName']) { $DisplayName = $packageParameters['DisplayName'] }
if ($packageParameters['Proxy']) { $Proxy = $packageParameters['Proxy'] }
if ($packageParameters['CustomAttributes']) { $CustomAttributes = $packageParameters['CustomAttributes'] }

if(Get-Variable -Name GenerateConfig -ErrorAction SilentlyContinue) {
  $additionalArgs = 'GENERATE_CONFIG=true'

  if(Get-Variable -Name LicenseKey -ErrorAction SilentlyContinue) {
    $additionalArgs += " LICENSE_KEY=$LicenseKey"
  }

  if(Get-Variable -Name DisplayName -ErrorAction SilentlyContinue) {
    $additionalArgs += " DISPLAY_NAME=$DisplayName"
  }

  if(Get-Variable -Name Proxy -ErrorAction SilentlyContinue) {
    $additionalArgs += " PROXY=$Proxy"
  }

  if(Get-Variable -Name CustomAttributes -ErrorAction SilentlyContinue) {
    $additionalArgs += " CUSTOM_ATTRIBUTES=$CustomAttributes"
  }
}

# Enable TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

$packageName     = 'newrelic-infra'
$softwareName    = 'newrelic-infra*'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64      = 'https://download.newrelic.com/infrastructure_agent/windows/newrelic-infra.1.63.0.msi'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url64bit      = $url64

  softwareName  = $softwareName

  checksum64     = '6c027b6f7d50ca6ffc096275e022c092879d98a2da780deffd66064648d3f1d6'
  checksumType64 = 'sha256'

  silentArgs    = "/qn $additionalArgs /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
