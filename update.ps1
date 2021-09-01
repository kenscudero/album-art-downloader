# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
if ( -not ( Test-Path -Path "$env:ProgramData\Chocolatey" ) ) {
	Write-Error -Message "Chocolatey is not installed" -ErrorAction Stop
}

import-module au

$domain		= 'https://sourceforge.net'
$releases	= $domain + '/projects/album-art/files/latest/Download'

function global:au_SearchReplace {
	@{
		".\tools\chocolateyInstall.ps1" = @{
			"($i)(^\s*url\s*=\s*)('.*')"			= "`$1'$($Latest.URL32)'"
			"($i)(^\s*checksum\s*=\s*)('.*')"		= "`$1'$($Latest.Checksum32)'"
			"($i)(^\s*filetype\s*=\s*)('.*')"		= "`$1'$($Latest.FileType)'"
		}
	}
}

function global:au_GetLatest {
	$myFuncName = $MyInvocation.MyCommand
	Write-Verbose "$($myFuncName):releases = $releases"
	try {
		$url = ( Get-RedirectedUrl -url $releases )
	} catch {
		Write-Error -Message "Unable to find resolve url $releases" -ErrorAction Stop
	}
	Write-Verbose "$($myFuncName):url = $url"
	$url = ( $url ).replace('.zip','.exe')
	Write-Verbose "$($myFuncName):url = $url"
	try {
		$statusCode = Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive -Method head | % {$_.StatusCode}
		Write-Verbose "$($myFuncName):statusCode=$statusCode"
	} catch {
		Write-Error -Message "Unable to find resolve url $url" -ErrorAction Stop
	}
	$p = Split-Path "$url" -leaf
	Write-Verbose "$($myFuncName):p=$($p)"
	$filetype = ( ( Split-Path -leaf $url ).split('.')[-1].ToUpper() )
	Write-Verbose "$($myFuncName):filetype=$($filetype)"
	$version = (($p.split('-'))[-1])
	Write-Verbose "$($myFuncName):version=$($version)"
	$version = $version.Substring(0,$version.Length - 1 - $filetype.Length)
	Write-Verbose "$($myFuncName):version=$($version)"
	$s = "URL32 = '$($url)'; Version = '$($version)'; FileType = '$($filetype)';"
	Write-Verbose "$($myFuncName):s=$s"
	Invoke-Expression "@{ $s }"
}

#au_GetLatest
update

