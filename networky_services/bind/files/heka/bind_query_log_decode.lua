--[[BIND query log Lua decoder script

BIND DNS query log decoder script for the Heka stream processor:

http://hekad.readthedocs.org/en/latest/

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

27-May-2015 21:06:49.246 queries: info: client 127.0.0.1#33182 (webserver.company.com): query: webserver.company.com IN A +E (127.0.0.1)

--]]

require "table"
require "string"

local syslog   = require "syslog"
local formats  = read_config("formats")
--The config for the SandboxDecoder plugin should have the type set to 'bindquerylog'
local msg_type = read_config("type")

local dt = require "date_time"

local msg = {
  Timestamp   = nil,
  Type        = msg_type,
  Hostname    = nil,
  Payload     = nil,
  Pid         = nil,
  Severity    = nil,
  Fields      = nil
}

function process_message ()
  
  local query_log_line = read_message("Payload")
  local fields = grammar:match(log)
  if not fields then return -1 end


  --Set the time in the message we're generating and set it to nil in the original
  --log line:
  msg.Timestamp = fields.time
  fields.time = nil

  msg.Fields = fields
  inject_message(msg)

  return 0
end

function timer_event(ns)
end