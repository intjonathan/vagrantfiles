--[[BIND query log Lua decoder script

BIND DNS query log decoder script for the Heka stream processor:

http://hekad.readthedocs.org/en/latest/

Adapted from: https://github.com/mozilla-services/heka/wiki/How-to-convert-a-PayloadRegex-MultiDecoder-to-a-SandboxDecoder-using-an-LPeg-Grammar

Built with the help of: http://lpeg.trink.com/

Reference for LPEG functions and uses: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html

Example use:

[bind_query_logs]
type = "LogstreamerInput"
decoder = "bind_query_log_decoder"
file_match = 'named_query.log'
log_directory = "/var/log/named"

[bind_query_log_decoder]
type = "SandboxDecoder"
filename = "lua_decoders/bind_query_log_decoder.lua"
  [bind_query_log_decoder.config]
  log_format = ''
  type = "bind.query"

Sample BIND query log message, with the print-category, print-severity and print-time options
all set to 'yes' in the logging channel options in named.conf:

27-May-2015 21:06:49.246 queries: info: client 10.0.1.70#41242 (webserver.company.com): query: webserver.company.com IN A +E (10.0.1.71)

The things we want out of it are:

* The client IP
* The name that was queried
* The domain of the name that was queried
* The record type (A, MX, PTR, etc.)
* The address of the interface that BIND used for the reply

--]]


local l = require 'lpeg'
local math = require 'math'
local string = require 'string'
local date_time = require 'date_time'
local ip = require 'ip_address'
local table = require 'table'
local syslog   = require "syslog"
l.locale(l)


local formats  = read_config("formats")
--The config for the SandboxDecoder plugin should have the type set to 'bindquerylog'
local msg_type = read_config("type")

--[[ Generic patterns --]]
--Patterns for the literals in the log lines that don't change from query to query
local space = l.space
-- ':'
local colon_literal = l.P":"
-- 'queries'
local queries_literal = l.P"queries:"
-- '#'
local pound_literal = l.P"#" 
-- 'info'
local info_literal = l.P"info:"
-- 'client'
local client_literal = l.P"client"
-- '('
local open_paren_literal = l.P"("
-- ')'
local close_paren_literal = l.P")"
-- 'query'
local query_literal = l.P"query:"
-- 'IN' literal string; 
local in_literal = l.P"IN"
-- '+' literal character; + indicates that recursion was requested.
local plus_literal = l.P"+"
-- '-' literal character; - indicates that recursion was not requested.
local plus_literal = l.P"-"
-- 'E' literal character; E indicates that extended DNS was used
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
-- More about EDNS: https://en.wikipedia.org/wiki/Extension_mechanisms_for_DNS
local e_literal = l.P"E"
-- 'S' literal character; s indicates that the query was signed
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local s_literal = l.P"S"
--'D' literal character; if DNSSEC Ok was set
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local d_literal = l.P"D"
--'T' literal character; if TCP was used
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local t_literal = l.P"T"
--'C' literal character; if checking disabled was set
-- Source: http://ftp.isc.org/isc/bind9/cur/9.9/doc/arm/Bv9ARM.ch06.html#id2575001
local c_literal = l.P"C"


--[[ More complicated patterns for things that do change from line to line: --]]

--The below pattern matches date/timestamps in the following format:
-- 27-May-2015 21:06:49.246
-- The milliseconds (the .246) are discarded by the `l.P"." * l.P(3)` at the end:
--Source: https://github.com/mozilla-services/lua_sandbox/blob/dev/modules/date_time.lua
local timestamp = l.Cg(date_time.build_strftime_grammar("%d-%B-%Y %H:%M:%S") / date_time.time_to_ns, "Timestamp") * l.P"." * l.P(3)
local x4            = l.xdigit * l.xdigit * l.xdigit * l.xdigit

--The below pattern matches IPv4 addresses from BIND query logs like the following:
-- 10.0.1.70#41242
-- The # and ephemeral port number are discarded by the `pound_literal * l.P(5)` at the end:
local client_address = l.Cg(l.Ct(l.Cg(ip.v4, "value") * l.Cg(l.Cc"ipv4", "representation")), "ClientAddress") * pound_literal * l.P(5)

--[[DNS query record types:

Create a capture group that will match the DNS record type.

The + signs mean to select A or CNAME or MX or PTR and so on.

The ', "record_type"' part sets the name of the capture's entry in the table of
matches that gets built.

--]]

--A capture group for various DNS record types.
-- Source: https://en.wikipedia.org/wiki/List_of_DNS_record_types
dns_record_type = l.Cg(
      l.P"A" /"A"
    + l.P"AAAA" /"AAAA"
    + l.P"AFSDB" /"AFSDB"
    + l.P"APL" /"APL"
    + l.P"AXFR" /"AXFR"
    + l.P"CAA" /"CAA"
    + l.P"CDNSKEY" /"CDNSKEY"
    + l.P"CDS" /"CDS"
    + l.P"CERT" /"CERT"
    + l.P"CNAME" /"CNAME"
    + l.P"DHCID" /"DHCID"
    + l.P"DLV" /"DLV"
    + l.P"DNAME" /"DNAME"
    + l.P"DS" /"DS"
    + l.P"HIP" /"HIP"
    + l.P"IPSECKEY" /"IPSECKEY"
    + l.P"IXFR" /"IXFR"
    + l.P"KEY" /"KEY"
    + l.P"KX" /"KX"
    + l.P"LOC" /"LOC"
    + l.P"MX" /"MX"
    + l.P"NAPTR" /"NAPTR"
    + l.P"NS" /"NS"
    + l.P"NSEC" /"NSEC"
    + l.P"NSEC3" /"NSEC3"
    + l.P"NSEC3PARAM" /"NSEC3PARAM"
    + l.P"OPT" /"OPT"
    + l.P"PTR" /"PTR"
    + l.P"RRSIG" /"RRSIG"
    + l.P"RP" /"RP"
    + l.P"SIG" /"SIG"
    + l.P"SOA" /"SOA"
    + l.P"SRV" /"SRV"
    + l.P"SSHFP" /"SSHFP"
    + l.P"TA" /"TA"
    + l.P"TKEY" /"TKEY"
    + l.P"TLSA" /"TLSA"
    + l.P"TSIG" /"TSIG"
    + l.P"TXT" /"TXT"
    + l.P"*" /"*"
    , "RecordType")

--[[Hostname and domain name patterns

Hostnames and domain names are broken up into fragments that are called 
"labels", which are the parts between the dots.

Source: https://en.wikipedia.org/wiki/Hostname#Restrictions_on_valid_host_names

For instance, webserver.company.com has the labels "webserver", "company" and 
"com"

The pattern below uses the upper, lower and digit shortcuts from the main LPEG 
library and combines them with the hyphen (-) character to match anything that's
part of a valid hostname label. The ^1 means match one or more instances of it.
--]]
local hostname_fragment = (l.upper + l.lower + l.digit +  "-")^1

--The pattern below matches one or more hostname_fragments, followed by a . 
--and followed by one more hostname_fragment, indicating the end of a complete
--hostname. The open and close parens and colon are to match the decorations
--BIND puts around the name: 
-- (webserver.company.com):
local enclosed_query = "(" * l.Cg((hostname_fragment * ".")^1 * hostname_fragment, "Query") * "):"

-- 27-May-2015 21:06:49.246 queries: info: client 10.0.1.70#41242 (webserver.company.com): query: webserver.company.com IN A +E (10.0.1.71)

local bind_query = timestamp * space * queries_literal * space * info_literal * space * client_literal * space * client_address * space * enclosed_query


grammar = l.Ct(bind_query)
local msg = {
  Type        = msg_type,
  Payload     = nil,
  Pid         = nil,
  Severity    = nil,
  Fields      = {
    -- If the query was for webserver.company.com, the fields would get filled in as follows:
    -- webserver
    Query       = nil, -- webserber
    QueryDomain = nil, -- company.com
    RecordType  = nil, -- A, MX, PTR, etc.
    ClientIP    = nil
  }
}

function process_message ()

  local query_log_line = read_message("Payload")
  if not fields then return -1 end
  --Set the time in the message we're generating and set it to nil in the original log line:
  msg.Timestamp = fields.time
  fields.time = nil

  msg.Fields = fields
  inject_message(msg)

  return 0

end