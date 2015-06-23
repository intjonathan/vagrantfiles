--[[ProcessInput filter script

http://hekad.readthedocs.org/en/latest/

Sample message in RestructuredText format:

:Timestamp: 2015-06-23 03:03:33.18044776 +0000 UTC
:Type: ProcessInput
:Hostname: dnsmaster1.local
:Pid: 10902
:Uuid: 6f8f1730-a72c-4dab-b3b4-a236c292eb77
:Logger: check_procs_critical
:Payload: PROCS WARNING: 98 processes | procs=98; 1:1 -c 2 -C sshd ;;0;

:EnvVersion:
:Severity: 7
:Fields:
    | name:"ProcessInputName" type:string value:"check_procs_critical.stdout"

Example use:

coming soon...

--]]

require "table"
require "string"
require "lpeg"
require "cjson"



function process_message ()

  local msg = {
    Timestamp = read_message('Timestamp'),
    Type = 'blah',
    Hostname = read_message('Hostname'),
    Pid = read_message('Pid'),
    Uuid = read_message('Uuid'),
    Logger = read_message('Logger'),
    Payload = read_message('Payload'),
    EnvVersion = read_message('EnvVersion'),
    Severity = read_message('Severity'),
    Fields     = {
      --
      ExitCode = nil,
      State  = nil, -- This will be either OK, WARNING, CRITICAL or UNKNOWN
    }
  }

--[[
  msg.Timestamp = read_message('Timestamp')
  msg.Type = 'blah'
  msg.Hostname = read_message('Hostname')
  msg.Pid = read_message('Pid')
  msg.Uuid = read_message('Uuid')
  msg.Logger = read_message('Logger')
  msg.Payload = read_message('Payload')
  msg.EnvVersion = read_message('EnvVersion')
  msg.Severity = read_message('Severity')
]]--

  local old_payload = read_message("Payload")

  msg.Payload = read_message('Payload')
  msg.Fields = read_message('Fields')

  inject_payload("json", msg.Logger, msg.Payload)
  return 0

end

function timer_event(ns)

end