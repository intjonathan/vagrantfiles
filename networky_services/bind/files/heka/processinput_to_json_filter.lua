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
    Type = read_message('Type'),
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

  msg.Payload = read_message('Payload')
  msg.Fields = read_message('Fields')
  msg.Logger = read_message('Logger')

  -- The inject_payload function below injects new Heka messages with the input message encoded
  -- into JSON as the payload.
  -- "json"- sets the extension of the file that gets written out and that the dashboard will serve
  -- msg.Logger - sets the endpoint that the dashboard serves JSON at. A msg.Logger value of
  -- 'check_procs_ok' will set the endpoint to 'http://hekaserver:4352/data/process_input_filter.check_procs_ok.json',
  -- for instance.
  -- cjson.encode(msg) - encodes the Heka message given to this Lua script as JSON; since this is the 3rd argument,
  inject_payload("json", msg.Logger, cjson.encode(msg))
  return 0

end

function timer_event(ns)

end