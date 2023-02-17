
# Overview

The "W3CLogs" module has a single function `Import-W3CLog`, which parses and imports W3C log files.

# System Requirements

* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell Core 6+

# Installing

To install globally:

```powershell
Install-Module -Name 'W3CLogs'
Import-Module -Name 'W3CLogs'
```

To install privately:

```powershell
Save-Module -Name 'W3CLogs' -Path '.'
Import-Module -Name '.\W3CLogs'
```

# Usage

Pass the path to a single log file to parse to the function's `Path` parameter:

```powershell
Import-W3CLog -Path 'log.log'
```

To parse multiple logs, pipe them in:

```powershell
Get-ChildItem -Recurse -Filter '*.log' | Import-W3CLog
```
