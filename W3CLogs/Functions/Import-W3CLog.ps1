
function Import-W3CLog
{
    <#
    .SYNOPSIS
    Parses and imports W3C log files.

    .DESCRIPTION
    The `Import-W3CLog` function parses and imports W3C log files, returning objects representing each line. Pass the
    path to the log file to parse to the `Path` parameter, or to parse multiple files, pipe them into the function.

    .EXAMPLE
    Import-W3CLog -Path log.log

    Demonstrates how to parse and import a single W3C log file by passing its path to the `Path` parameter.

    .EXAMPLE
    Get-ChildItem -Path C:\Inetpub\logs -Filter '*.log' -Recurse | Import-W3CLog

    Demonstrates how to parse multiple logs by piping their paths to the `Import-W3CLog` function.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String] $Path
    )

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        $Path = $Path | Resolve-Path
        if (-not $Path)
        {
            return
        }

        $displayPath = $Path | Resolve-Path -Relative
        if ($displayPath.StartsWith('..'))
        {
            $displayPath = $Path
        }

        Write-Verbose $displayPath

        $fields = @()

        $lineNum = 0
        foreach ($line in (Get-Content -Path $Path))
        {
            $lineNum += 1

            if (-not $line)
            {
                continue
            }

            if ($line.StartsWith('#'))
            {
                if ($line.StartsWith('#Fields: '))
                {
                    $fields = $line.Split(' ') | Select-Object -Skip 1
                }
                else
                {
                    Write-Verbose "  $($line.Substring(1))"
                }
                continue
            }

            $errMsgPrefix = "$($displayPath) line $($lineNum): "

            $entry = [W3CLogs.LogEntry]::New()

            [String[]]$values = $line.Split(' ')
            for ($idx = 0; $idx -lt $values.Length; ++$idx)
            {
                $propertyName = $fieldName = $fields[$idx]
                if ($script:fieldPropertyMap.ContainsKey($fieldName))
                {
                    $propertyName = $script:fieldPropertyMap[$fieldName]
                }
                else
                {
                    $entry | Add-Member -Name $fieldName -MemberType NoteProperty
                }

                $value = $values[$idx]
                if ($value -eq '-')
                {
                    continue
                }

                if ($script:httpMethods.Contains($fieldName))
                {
                    $value = [Net.Http.HttpMethod]::New($value)
                }
                elseif ($script:milliseconds.Contains($fieldName))
                {
                    $value = [TimeSpan]::New(0, 0, 0, 0, $value)
                }

                try
                {
                    $entry.$propertyName = $value
                }
                catch
                {
                    $msg = "$($errMsgPrefix)Failed to convert $($fieldName) value ""$($value)"": $($_)"
                    Write-Error $msg -ErrorAction $ErrorActionPreference
                }
            }

            $entry.DateTime = $entry.Date + $entry.Time

            $hostname = 'example.com'
            if ($entry.Host)
            {
                $hostname = $entry.Host
            }
            elseif ($entry.ServerIP -and $entry.ServerIP.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork)
            {
                $hostname = $entry.ServerIP.IPAddressToString
            }

            $queryString = ''
            if ($entry.Query)
            {
                $queryString = "?$($entry.Query)"
            }

            $stem = $entry.Stem
            if (-not $stem.StartsWith('/'))
            {
                $stem = "/$($stem)"
            }

            $url = "http://$($hostname)$($stem)$($queryString)"
            try
            {
                $entry.Url = [Uri]::New($url)
            }
            catch
            {
                $msg = "$($errMsgPrefix)Failed to convert ""$($url)"" to a [Uri] object: $($_)"
                Write-Error $msg -ErrorAction $ErrorActionPreference
            }

            $entry | Write-Output
        }

    }
}