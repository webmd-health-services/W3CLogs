<#
.SYNOPSIS
Gets your computer ready to develop the W3CLogs module.

.DESCRIPTION
The init.ps1 script makes the configuraion changes necessary to get your computer ready to develop for the
W3CLogs module. It:


.EXAMPLE
.\init.ps1

Demonstrates how to call this script.
#>
[CmdletBinding()]
param(
)

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
