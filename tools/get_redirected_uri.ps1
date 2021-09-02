# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference = 'Stop';

if ( -not ( Test-Path -Path "$env:ProgramData\Chocolatey" ) ) {
	Write-Error -Message "Chocolatey is not installed" -ErrorAction Stop
}

function Get-RedirectedUri {
	<#
	.SYNOPSIS
		Gets the real download URL from the redirection.
	.DESCRIPTION
		Used to get the real URL for downloading a file, this will not work if downloading the file directly.
	.EXAMPLE
		Get-RedirectedUri -Uri "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US"
	.PARAMETER URL
		URL for the redirected URL to be un-obfuscated
	.NOTES
		Code from: Redone per issue #2896 in core https://github.com/PowerShell/PowerShell/issues/2896
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$Uri
	)
	process {
		$myFuncName = $MyInvocation.MyCommand
		$http_response_exception = 'HttpResponseException'
		$http_code_redirect = '302'
		$retry = $true
		do {
			try {
				Write-Verbose "$($myFuncName):Invoke-WebRequest -Method Head -Uri $uri"
				$request = Invoke-WebRequest -Method Head -Uri $Uri
				# This is for Powershell 5
				Write-Verbose "$($myFuncName):Powershell 5:(BaseResponse.ResponseUri.AbsoluteUri)"
				$redirectUri = $request.BaseResponse.ResponseUri.AbsoluteUri
				if ($redirectUri -eq $null) {
					# This is for Powershell Core
					Write-Verbose "$($myFuncName):Powershell Core:(BaseResponse.RequestMessage.RequestUri.AbsoluteUri)"
					$redirectUri = $request.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
				}
				if ($redirectUri -eq $null) {
					Write-Verbose "$($myFuncName):Powershell version:unknown"
					throw "$($myFuncName):Powershell version:unknown"
				}
				Write-Verbose "$($myFuncName):redirectUri=$redirectUri"
				$retry = $false
			} catch {
				if ($_.Exception.GetType() -match $http_response_exception) {
					Write-Verbose "$($myFuncName):$http_response_exception"
				}
				else { throw $_ }
				if ($_.Exception -match $http_code_redirect) {
					Write-Verbose "$($myFuncName):$http_code_redirect"
				}
				else { throw $_ }
				$Uri = $_.Exception.Response.Headers.Location.AbsoluteUri
				Write-Verbose "$($myFuncName):Redirected Uri=$Uri"
			}
		} while ($retry)

		$redirectUri

	}
}
