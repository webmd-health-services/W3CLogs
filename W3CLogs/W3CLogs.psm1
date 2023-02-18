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

$srcPath = Join-Path -Path $script:moduleRoot -ChildPath 'src' -Resolve

Add-Type -Path (Get-ChildItem -Path $srcPath -Filter '*.cs').FullName `
         -ReferencedAssemblies 'System.Net.Http','System.Net','System.Net.Primitives'

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
