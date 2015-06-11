--[[BIND query log Lua decoder script

BIND DNS query log decoder script for the Heka stream processor:

http://hekad.readthedocs.org/en/latest/

Adapted from: https://github.com/mozilla-services/heka/wiki/How-to-convert-a-PayloadRegex-MultiDecoder-to-a-SandboxDecoder-using-an-LPeg-Grammar

Built with the help of: http://lpeg.trink.com/

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
all set to 'yes':

27-May-2015 21:06:49.246 queries: info: client 10.0.1.70#41242 (webserver.company.com): query: webserver.company.com IN A +E (10.0.1.71)

The things we want out of it are:

* The client IP
* The name that was queried
* The domain of the name that was queried
* The record type (A, MX, PTR, etc.)
* The address of the interface that BIND used for the reply

--]]

require "table"
require "string"
require "lpeg"
local date_time = require "date_time"
local ip = require "ip_address"
l.locale(l)

local syslog   = require "syslog"
local formats  = read_config("formats")
--The config for the SandboxDecoder plugin should have the type set to 'bindquerylog'
local msg_type = read_config("type")

local space = l.space
local timestamp = l.Cg(date_time.build_strftime_grammar("%Y/%m/%d %H:%M:%S") / date_time.time_to_ns, "Timestamp")
local remoteaddr = l.P"remoteaddr=" * l.Cg(l.Ct(l.Cg(ip.v4, "value") * l.Cg(l.Cc"ipv4", "representation")), "Remoteaddr")
local headers = l.Cg(l.P(1)^0, "Headers")
local bind_query = date * space * timestamp * space * 'queries:' * 'info:' * 'client' * space * client_ip * space * '(' * query * '):' * space * 'query:' * space * query * space * 'IN' * record_type * space '+E' * space * '(' * reply_address * ')' 

--Individual pieces I need to create patterns for:
--date
--timestamp
--client_ip
--query
--record_type
--reply_address

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