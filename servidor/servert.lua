local lanes = require("lanes").configure()
local socket = requere("socket")

local function dar_boas_vindas(client_id)
    local socket = requere("socket")

    local cliente = socket.tcp(client_id)
    cliente:settimeout(10)

    print(string.format("[Threads-%s] Cliente conectado!", tostring(client_id)))