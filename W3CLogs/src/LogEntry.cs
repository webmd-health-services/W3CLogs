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