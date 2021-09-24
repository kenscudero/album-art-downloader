# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference = 'Stop';

$toolsDir	= "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageName	= 'album-art-downloader'
$softwareName	= 'AlbumArtDownloader*'
$url		= 'https://managedway.dl.sourceforge.net/project/album-art/album-art-xui/AlbumArtDownloaderXUI-1.05.exe'
$fileType	= ( $(Split-Path -leaf $url) -split('\.') )[-1].ToUpper()
$checksum	= '4B0AD1CCA82F3B7BD2D7BBF2F5744AD5305CFA31615C3E584613E6163110D62A'
$checksumType	= 'sha256'
$silentArgs	= '/S'
$validExitCodes	= @(0)

$helpers = @('helpers')
foreach ($helper in $helpers) {
	Write-Verbose "$($MyInvocation.MyCommand):Looking for helper script: $toolsDir\$helper.ps1"
	if ( ( Test-Path -Path "$toolsDir\$helper.ps1" ) ) {
		Write-Verbose "$($MyInvocation.MyCommand):Loading helper script: $toolsDir\$helper.ps1"
		. $toolsDir\$helper.ps1
	} else {
		Write-Error -Message "Helper script is not installed: $toolsDir\$helper.ps1" -ErrorAction Stop
	}
}

$sNET_FX_Release_Info = '4.7.2:461808'
#Write-Verbose "sNET_FX_Release_Info = $( $sNET_FX_Release_Info )"
$bTest_NETFX_Lib_Installed = ( bTest-NETFX-Lib-Installed $sNET_FX_Release_Info )
#Write-Verbose "bTest_NETFX_Lib_Installed = $( $bTest_NETFX_Lib_Installed )"
if ( -not ( $bTest_NETFX_Lib_Installed ) ) {
	Write-Warning "
	Microsoft NET Framework Release ($( $sNET_FX_Release_Info.split(':')[0] ))
	is missing or not Activated.
"
	$msg = "
Cannot install Chocolatey package [$( $packageName )]
"
	Write-Error -Message $msg -ErrorAction Stop
}
Write-Host "
Found Microsoft NET Framework Release ($( $sNET_FX_Release_Info.split(':')[0] ) or newer)
is Installed and Activated!
"

$packageArgs = @{
  packageName		= $packageName
  fileType		= $fileType

  url			= $url

  softwareName		= $softwareName

  checksum		= $checksum
  checksumType		= $checksumType

  silentArgs		= $silentArgs

  validExitCodes	= $validExitCodes
}

Install-ChocolateyPackage @packageArgs #-UseOnlyPackageSilentArguments
