# Copyright WebMD Health Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

# Functions should use $moduleRoot as the relative root from which to find
# things. A published module has its function appended to this file, while a 
# module in development has its functions in the Functions directory.
$script:moduleRoot = $PSScriptRoot

$script:fieldPropertyMap = @{
    'date' = 'Date';
    'time' = 'Time';
    's-ip' = 'ServerIP';
    'cs-method' = 'Method';
    'cs-uri-stem' = 'Stem';
    'cs-uri-query' = 'Query';
    's-port' = 'Port';
    'cs-username' = 'UserName';
    'c-ip' = 'ClientIP';
    'cs-version' = 'Version';
    'cs(User-Agent)' = 'UserAgent';
    'cs(Cookie)' = 'Cookie';
    'cs(Referer)' = 'Referer';
    'cs-host' = 'Host';
    'sc-status' = 'Status';
    'sc-bytes' = 'BytesSent';
    'cs-bytes' = 'BytesReceived';
    'time-taken' = 'TimeTaken';
    's-sitename' = 'SiteName';
    's-computername' = 'ComputerName';
    'sc-substatus' = 'Substatus';
    'sc-win32-status' = 'Win32Status';
}

$script:milliseconds = [Collections.Generic.Hashset[String]]::New()
[void]$script:milliseconds.Add('time-taken')

$script:httpMethods = [Collections.Generic.Hashset[String]]::New()
[void]$script:httpMethods.Add('sc-method')

Add-Type -ReferencedAssemblies 'System.Net.Http' -TypeDefinition @'
using System;
using System.Net;
using System.Net.Http;

namespace W3CLogs
{
    public sealed class LogEntry
    {
        public DateTime Date { get; set; }
        public TimeSpan Time { get; set; }
        public DateTime DateTime { get; set; }
        public IPAddress ClientIP { get; set; }
        public string UserName { get; set; }
        public string SiteName { get; set; }
        public string ComputerName { get; set; }
        public IPAddress ServerIP { get; set; }
        public ushort Port { get; set; }
        public HttpMethod Method { get; set; }
        public Uri Url { get; set; }
        public string Stem { get; set; }
        public string Query { get; set; }
        public HttpStatusCode Status { get; set; }
        public int Substatus { get; set; }
        public int Win32SStatus { get; set; }
        public ulong BytesSent { get; set; }
        public ulong BytesReceived { get; set; }
        public TimeSpan TimeTaken { get; set; }
        public string Version { get; set; }
        public string Host { get; set; }
        public string UserAgent { get; set; }
        public string Cookie { get; set; }
        public Uri Referer { get; set; }

        public override bool Equals(object obj)
        {
            var entry = obj as LogEntry;
            if (null == entry)
                return false;

            return this.Date == entry.Date &&
                   this.Time == entry.Time &&
                   this.ClientIP == entry.ClientIP &&
                   this.UserName == entry.UserName &&
                   this.SiteName == entry.SiteName &&
                   this.ComputerName == entry.ComputerName &&
                   this.ServerIP == entry.ServerIP &&
                   this.Port == entry.Port &&
                   this.Method == entry.Method &&
                   this.Stem == entry.Stem &&
                   this.Query == entry.Query &&
                   this.Status == entry.Status &&
                   this.Substatus == entry.Substatus &&
                   this.Win32SStatus == entry.Win32SStatus &&
                   this.BytesSent == entry.BytesSent &&
                   this.BytesReceived == entry.BytesReceived &&
                   this.TimeTaken == entry.TimeTaken &&
                   this.Version == entry.Version &&
                   this.Host == entry.Host &&
                   this.UserAgent == entry.UserAgent &&
                   this.Cookie == entry.Cookie &&
                   this.Referer == entry.Referer;
        }

        public override int GetHashCode()
        {
            throw new NotImplementedException();
        }
    }
}
'@

# Store each of your module's functions in its own file in the Functions 
# directory. On the build server, your module's functions will be appended to 
# this file, so only dot-source files that exist on the file system. This allows
# developers to work on a module without having to build it first. Grab all the
# functions that are in their own files.
$functionsPath = Join-Path -Path $moduleRoot -ChildPath 'Functions\*.ps1'
if( (Test-Path -Path $functionsPath) )
{
    foreach( $functionPath in (Get-Item $functionsPath) )
    {
        . $functionPath.FullName
    }
}
