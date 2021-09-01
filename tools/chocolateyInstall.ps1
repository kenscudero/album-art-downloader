# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference = 'Stop';

$toolsDir	= "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageName	= 'album-art-downloader'
$url		= 'https://managedway.dl.sourceforge.net/project/album-art/album-art-xui/AlbumArtDownloaderXUI-1.05.exe'
$fileType	= ( $(Split-Path -leaf $url) -split('\.') )[-1].ToUpper()
$checksum	= '4B0AD1CCA82F3B7BD2D7BBF2F5744AD5305CFA31615C3E584613E6163110D62A'
$checksumType	= 'sha256'
$silentArgs	= '/quiet /S /VERYSILENT'

$packageArgs = @{
  packageName		= $packageName
  unzipLocation		= $toolsDir
  fileType		= $fileType

  url			= $url

  softwareName		= 'Album Art Downloader*'

  checksum		= $checksum
  checksumType		= $checksumType

  silentArgs		= $silentArgs

  validExitCodes = @(0)
}

Install-ChocolateyPackage @packageArgs
