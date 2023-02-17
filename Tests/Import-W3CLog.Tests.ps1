
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [W3CLogs.LogEntry[]] $script:result = @()

    function GivenLogFile
    {
        param(
            [Parameter(Mandatory)]
            [String] $FileName,

            [Parameter(Mandatory)]
            [String] $WithContent
        )

        $WithContent | Set-Content -Path (Join-Path -Path $TestDrive -ChildPath $FileName)
    }

    function ThenImported
    {
        param(
            [Parameter(Mandatory)]
            [hashtable[]] $ExpectedLine
        )

        $emptyEntry = [W3CLogs.LogEntry]::New()

        $script:result | Should -HaveCount $ExpectedLine.Length

        for ($idx = 0; $idx -lt $script:result.Length; ++$idx)
        {
            $actualLine = $script:result[$idx]
            $line = $ExpectedLine[$idx]

            foreach ($propertyName in $emptyEntry.psobject.Properties.Name)
            {
                if ($line.ContainsKey($propertyName))
                {
                    $actualLine.$propertyName |
                        Should -Be $line[$propertyName] -Because "should parse $($propertyName) field on line $($idx)"
                }
                else
                {
                    $actualLine.$propertyName |
                        Should -Be $emptyEntry.$propertyName `
                               -Because "should not parse $($propertyName) field on line $($idx)"
                }
            }
        }
    }

    function WhenImporting
    {
        param(
            [Parameter(Mandatory)]
            [String] $FileName
        )

        $script:result = Import-W3CLog -Path (Join-Path -Path $TestDrive -ChildPath $FileName)
    }
}

Describe 'Import-W3CLog' {
    BeforeEach {
        $script:result = $null
    }

    It 'should parse a log file' {
        GivenLogFile 'log1.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:02 195.52.225.44 - WEB1 192.166.0.24 GET /default.htm - 200 1703 279 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) - http://www.webtrends.com/def_f1.htm
1996-01-01 10:48:02 195.52.225.44 - WEB1 192.166.0.24 GET /loganalyzer/info.htm - 200 3960 303 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://www.webtrends.com/def_f1.htm
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /styles/style1.css - 200 586 249 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 -
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /graphics/atremote/remote.jpg - 200 12367 301 656 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://webtrends.sample.com/wt_f2.htm
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /graphics/backg/backg1.gif - 200 448 313 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://webtrends.sample.com/loganalyzer/info.htm
'@        
        WhenImporting 'log1.log'

        ThenImported @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/default.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 1703;
            BytesReceived = 279;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = $null;
            Referer = [Uri]'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/default.htm';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/loganalyzer/info.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 3960;
            BytesReceived = 303;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = 'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/loganalyzer/info.htm';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/styles/style1.css';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 586;
            BytesReceived = 249;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Url = 'http://192.166.0.24/styles/style1.css';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/graphics/atremote/remote.jpg';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 12367;
            BytesReceived = 301;
            TimeTaken = [TimeSpan]::New(0, 0, 0, 0, 656)
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = [Uri]'http://webtrends.sample.com/wt_f2.htm';
            Url = 'http://192.166.0.24/graphics/atremote/remote.jpg';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/graphics/backg/backg1.gif';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 448;
            BytesReceived = 313;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = [Uri]'http://webtrends.sample.com/loganalyzer/info.htm';
            Url = 'http://192.166.0.24/graphics/backg/backg1.gif';
        }
    }

    It 'should parse a log file that switches fields' {
        GivenLogFile 'log2.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:02 195.52.225.44 - WEB1 192.166.0.24 GET /default.htm - 200 1703 279 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) - http://www.webtrends.com/def_f1.htm

# Ignore me
#Fields: cs(Referer) cs(Cookie) cs(User-Agent) cs-version time-taken cs-bytes sc-bytes sc-status cs-uri-query cs-uri-stem cs-method s-ip s-computername cs-username c-ip time date
http://www.webtrends.com/def_f1.htm WEBTRENDS_ID=195.52.225.44-100386000.29188902 Mozilla/4.0+[en]+(WinNT;+I) HTTP/1.0 0 303 3960 200 - /loganalyzer/info.htm GET 192.166.0.24 WEB1 - 195.52.225.44 10:48:02 1996-01-01
'@        
        WhenImporting 'log2.log'

        ThenImported @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/default.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 1703;
            BytesReceived = 279;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = $null;
            Referer = [Uri]'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/default.htm';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/loganalyzer/info.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 3960;
            BytesReceived = 303;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = 'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/loganalyzer/info.htm';
        }
    }

    It 'should parse multiple log files' {
        GivenLogFile 'log1.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:02 195.52.225.44 - WEB1 192.166.0.24 GET /default.htm - 200 1703 279 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) - http://www.webtrends.com/def_f1.htm
'@        
        GivenLogFile 'log2.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:02 195.52.225.44 - WEB1 192.166.0.24 GET /loganalyzer/info.htm - 200 3960 303 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://www.webtrends.com/def_f1.htm
'@        
        GivenLogFile 'log3.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /styles/style1.css - 200 586 249 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 -
'@        
        GivenLogFile 'log4.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /graphics/atremote/remote.jpg - 200 12367 301 656 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://webtrends.sample.com/wt_f2.htm
'@        
        GivenLogFile 'log5.log' -WithContent @'
#Fields: date time c-ip cs-username s-computername s-ip cs-method cs-uri-stem cs-uri-query sc-status sc-bytes cs-bytes time-taken cs-version cs(User-Agent) cs(Cookie) cs(Referer)
1996-01-01 10:48:05 195.52.225.44 - WEB1 192.166.0.24 GET /graphics/backg/backg1.gif - 200 448 313 0 HTTP/1.0 Mozilla/4.0+[en]+(WinNT;+I) WEBTRENDS_ID=195.52.225.44-100386000.29188902 http://webtrends.sample.com/loganalyzer/info.htm
'@        
        $script:result = Get-ChildItem -Path $TestDrive -Filter '*.log' | Import-W3CLog

        ThenImported @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/default.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 1703;
            BytesReceived = 279;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = $null;
            Referer = [Uri]'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/default.htm';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:02';
            DateTime = [DateTime]'1996-01-01 10:48:02';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/loganalyzer/info.htm';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 3960;
            BytesReceived = 303;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = 'http://www.webtrends.com/def_f1.htm';
            Url = 'http://192.166.0.24/loganalyzer/info.htm';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/styles/style1.css';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 586;
            BytesReceived = 249;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Url = 'http://192.166.0.24/styles/style1.css';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/graphics/atremote/remote.jpg';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 12367;
            BytesReceived = 301;
            TimeTaken = [TimeSpan]::New(0, 0, 0, 0, 656)
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = [Uri]'http://webtrends.sample.com/wt_f2.htm';
            Url = 'http://192.166.0.24/graphics/atremote/remote.jpg';
        },
        @{
            Date = [DateTime]'1996-01-01';
            Time = [TimeSpan]'10:48:05';
            DateTime = [DateTime]'1996-01-01 10:48:05';
            ClientIP = [ipaddress]'195.52.225.44'
            ComputerName = 'WEB1';
            ServerIP = [ipaddress]'192.166.0.24';
            Method = [Net.Http.HttpMethod]::New('GET');
            Stem = '/graphics/backg/backg1.gif';
            Status = [Net.HttpStatusCode]200;
            BytesSent = 448;
            BytesReceived = 313;
            TimeTaken = [TimeSpan]::Zero;
            Version = 'HTTP/1.0';
            UserAgent = 'Mozilla/4.0+[en]+(WinNT;+I)';
            Cookie = 'WEBTRENDS_ID=195.52.225.44-100386000.29188902';
            Referer = [Uri]'http://webtrends.sample.com/loganalyzer/info.htm';
            Url = 'http://192.166.0.24/graphics/backg/backg1.gif';
        }
    }
}