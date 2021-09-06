# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference = 'Stop';

if ( -not ( Test-Path -Path "$env:ProgramData\Chocolatey" ) ) {
	Write-Error -Message "Chocolatey is not installed" -ErrorAction Stop
}

function bTest-NETFX-Lib-Installed() {
	param (
		[Parameter(Mandatory = $true)]
		[string]$sNET_FX_Release_Info
	)

	[bool]$bIs_Operating_System_64Bit = ([System.Environment]::Is64BitOperatingSystem)

	[string]$sRegKey = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
	If ($bIs_Operating_System_64Bit) {
		[string]$sRegKeyFrom = '\Microsoft\'
		[string]$sRegKeyTo = ('\Wow6432Node' + $sRegKeyFrom)
		$sRegKey = $sRegKey.replace($sRegKeyFrom,$sRegKeyTo)
	}
	#Write-Verbose "sRegKey = $( $sRegKey )"
	[int]$iNET_FX_Installed_Release_Value = ( Get-ItemProperty $sRegKey ).Release

	Function sGet_NET_FX_Release_Field() {
	  param (
	    [Parameter(Mandatory = $true)]
	    [string]$sNET_FX_Release_Info,
	    [Parameter(Mandatory = $true)]
	    [string]$sNET_FX_Release_Field
	  )
	  process {
	    switch ( $sNET_FX_Release_Field.ToLower() ) {
	      'name'	{ $iField = 0 }
	      'value'	{ $iField = 1 }
	      default	{ $iField = 1 }
	    }
	  }
	  end {
	    return $( $sNET_FX_Release_Info.split(':')[$iField] )
	  }
	}

	Function bTest_NET_FX_Release_Exceeds() {
	  param (
	    [Parameter(Mandatory = $true)]
	    [int]$iNET_FX_Installed_Release_Value,
	    [Parameter(Mandatory = $true)]
	    [string]$sNET_FX_Release_Info
	  )
	  begin {
	    [string]$sNET_FX_Test_Release_Name		= ( sGet_NET_FX_Release_Field -sNET_FX_Release_Info $sNET_FX_Release_Info -sNET_FX_Release_Field 'Name' )
	    #Write-Verbose "sNET_FX_Test_Release_Name         = $( $sNET_FX_Test_Release_Name )"
	    [int]$iNET_FX_Test_Release_Value		= ( sGet_NET_FX_Release_Field -sNET_FX_Release_Info $sNET_FX_Release_Info -sNET_FX_Release_Field 'Value' )
	   # Write-Verbose "iNET_FX_Test_Release_Value        = $( $iNET_FX_Test_Release_Value )"
	  }
	  process {
	    #Write-Verbose "iNET_FX_Installed_Release_Value   = $( $iNET_FX_Installed_Release_Value )"
	    [bool]$bNET_FX_Installed_Release_Exceeds	=  ( $iNET_FX_Installed_Release_Value -ge $iNET_FX_Test_Release_Value )
	    #Write-Verbose "bNET_FX_Installed_Release_Exceeds = $( $bNET_FX_Installed_Release_Exceeds )"
	  }
	  end {
	    return $bNET_FX_Installed_Release_Exceeds
	  }
	}

	[bool]$bNET_FX_Installed_Release_Exceeds	= `
		( bTest_NET_FX_Release_Exceeds `
			-iNET_FX_Installed_Release_Value $iNET_FX_Installed_Release_Value `
			-sNET_FX_Release_Info $sNET_FX_Release_Info `
		)
	$bTest_NET_FX_Installed_Release_Exceeds_Value	= $true
	#$bTest_NET_FX_Installed_Release_Exceeds_Value	= $false
	If ( $bTest_NET_FX_Installed_Release_Exceeds_Value -and $bNET_FX_Installed_Release_Exceeds ) {
		[string]$sNET_FX_Test_Release_Name	= ( sGet_NET_FX_Release_Field -sNET_FX_Release_Info $sNET_FX_Release_Info -sNET_FX_Release_Field 'Name' )
		[int]$iNET_FX_Test_Release_Value	= ( sGet_NET_FX_Release_Field -sNET_FX_Release_Info $sNET_FX_Release_Info -sNET_FX_Release_Field 'Value' )

		[string]$sUser = ( [System.Security.Principal.WindowsIdentity]::GetCurrent().Name )
		if ( $( $sUser ) -match('\\vagrant$') ) { Write-Host ' ' }
		[string]$sMsg = $null
		$sMsg += "Microsoft NET Framework Release (Installed) >= $( $sNET_FX_Test_Release_Name )"
		$sMsg += "`t($( $iNET_FX_Installed_Release_Value ) >= $( $iNET_FX_Test_Release_Value ))"
		$sMsg += ":`t$( $bNET_FX_Installed_Release_Exceeds )"
		Write-Host $sMsg

		return $true
	}

	[string]$sNET_FX_Test_Release_Name	= ( sGet_NET_FX_Release_Field -sNET_FX_Release_Info $sNET_FX_Release_Info -sNET_FX_Release_Field 'Name' )

	Write-Host ' '
	Write-Warning "
	Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
	must be Installed (and Activated!)
	to use this Chocolatey package."

	#[string]$sPkgName		= 'dotnet4.7.2'
	[string]$sPkgName		= 'netfx-4.7.2'

	Write-Host "
Checking if Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
Chocolatey package [$( $sPkgName )] is Installed.
"

	[bool]$bPkgIsInstalled	= ( ( choco list --lo $sPkgName ) -match($sPkgName) )
	$bTest_NET_FX_Pkg_Is_Installed		= $true
	#$bTest_NET_FX_Pkg_Is_Installed		= $false
	If ( $bTest_NET_FX_Pkg_Is_Installed -and $bPkgIsInstalled ) {
		Write-Warning "
	Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
	Chocolatey package [$( $sPkgName )] is Installed,
	but may not have been Activated!
"
		Write-Warning "
	A Restart will be necessary to Activate
	Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
	Chocolatey package [$( $sPkgName )]!
"
	} Else {
		Write-Warning "
	Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
	package [$( $sPkgName )] needs to be Installed (and Activated!)
	to use this Chocolatey package.
"
		Write-Warning "
	After Microsoft NET Framework Release $( $sNET_FX_Test_Release_Name )
	Chocolatey package [$( $sPkgName )] is Installed,
	a Restart will be necessary to Activate it!
"
	}

	return $false
}