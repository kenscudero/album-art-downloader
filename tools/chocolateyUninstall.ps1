# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference = 'Stop';

$packageName	= 'album-art-downloader'
$softwareName	= 'AlbumArtDownloader*'
#$silentArgs	= '/S'
#$validExitCodes	= @(0, 3010, 1605, 1614, 1641)
$Bits		= Get-ProcessorBits

If ( $Bits -eq 64 ) {
	$installPathRoot	= "${Env:ProgramFiles}"
} Else {
	$installPathRoot	= "${Env:ProgramFiles(x86)}"
}
$installName		= ( $softwareName.replace('*',$null) )
$installPath		= ( Join-Path -Path $installPathRoot -ChildPath $installName )
$startMenuPathRoot	= ( Join-Path -Path $env:APPDATA -ChildPath "Microsoft" )
$startMenuPathRoot	= ( Join-Path -Path $startMenuPathRoot -ChildPath "Windows" )
$startMenuPathRoot	= ( Join-Path -Path $startMenuPathRoot -ChildPath "Start Menu" )
$startMenuPathRoot	= ( Join-Path -Path $startMenuPathRoot -ChildPath "Programs" )
$startMenuName		= ($installName) -creplace('(.)([A|D])','$1 $2')
$startMenuPath		= ( Join-Path -Path $startMenuPathRoot -ChildPath $startMenuName )
$localAppDataPathRoot	= "${Env:LOCALAPPDATA}"
$localAppDataPath	= ( Join-Path -Path $localAppDataPathRoot -ChildPath $installName )

$regKeyHKCR_Shell	= "HKCR:\\Folder\shell\$installName"
If ( $Bits -eq 64 ) {
	$regKeyHKLM_Uninstall	= "HKLM:\\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Album Art Downloader XUI"
} Else {
	$regKeyHKLM_Uninstall	= "HKLM:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\Album Art Downloader XUI"
}
$regKeyHKLM_ProductDir	= "HKLM:\\Software\Microsoft\Windows\CurrentVersion\App Paths\AlbumArt.exe"

$appName                = ( ( Split-Path -Path ( Join-Path -Path $installPath -ChildPath 'Album*.exe' ) -Leaf -Resolve ).replace('.exe',$null) )
Start-CheckandStop "$appName"

If ( $false ) {
	Write-Host "`
installName		= $($installName)		`
installPath		= $($installPath)		`
startMenuPathRoot	= $($startMenuPathRoot)		`
startMenuName		= $($startMenuName)		`
startMenuPath		= $($startMenuPath)		`
localAppDataPathRoot	= $($localAppDataPathRoot)	`
localAppDataPath	= $($localAppDataPath)		`
`
regKeyHKCR_Shell	= $($regKeyHKCR_Shell)		`
regKeyHKLM_Uninstall	= $($regKeyHKLM_Uninstall)	`
regKeyHKLM_ProductDir	= $($regKeyHKLM_ProductDir)	`
"
	exit
}

If ( Test-Path -Path $installPath ) {
	Write-Host "Removing '$($installName)' Install Path '$($installPath)'"
	Remove-Item -Path $installPath -Force -Recurse
}

If ( Test-Path -Path $startMenuPath ) {
	Write-Host "Removing '$($installName)' Start Menu Path '$($startMenuPath)'"
	Get-ChildItem -Path $startMenuPath -Recurse | Remove-Item -force -recurse
	Remove-Item -Path $startMenuPath -Force
}

If ( Test-Path -Path $localAppDataPath ) {
	Write-Host "Removing '$($installName)' Local App Path '$($localAppDataPath)'"
	Remove-Item -Path $localAppDataPath -Force -Recurse
}

Write-Host " "

Get-Item -Path $regKeyHKCR_Shell -ErrorAction SilentlyContinue 2>&1 | Out-Null
If ( $? ) {
	Write-Host "Removing '$($installName)' Registry Key '$($regKeyHKCR_Shell)'"
	Remove-Item -Path $regKeyHKCR_Shell
}

Get-Item -Path $regKeyHKLM_Uninstall -ErrorAction SilentlyContinue 2>&1 | Out-Null
If ( $? ) {
	Write-Host "Removing '$($installName)' Registry Key '$($regKeyHKLM_Uninstall)'"
	Remove-Item -Path $regKeyHKLM_Uninstall
}

Get-Item -Path "$regKeyHKLM_ProductDir" -ErrorAction SilentlyContinue 2>&1 | Out-Null
If ( $? ) {
	Write-Host "Removing '$($installName)' Registry Key '$($regKeyHKLM_ProductDir)'"
	Remove-Item -Path $regKeyHKLM_ProductDir
}

exit 0