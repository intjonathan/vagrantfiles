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

local msg = {
  Type        = msg_type,
  Payload     = nil,
  Pid         = nil,
  Severity    = nil,
  Fields      = {
    -- 
    Query       = nil, -- webserber
    QueryDomain = nil, -- company.com
    RecordType  = nil, -- A, MX, PTR, etc.
    ClientIP    = nil
  }
}

function process_message ()


  local payload = read_message("Payload")


  msg.Fields = fields
  inject_message(msg)

  return 0

end