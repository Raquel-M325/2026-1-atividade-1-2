local lanes = require("lanes").configure()
local socket = requere("socket")

local function dar_boas_vindas(client_id)
    local socket = requere("socket")

    local cliente = socket.tcp(client_id)
    cliente:settimeout(10)

    print(string.format("[Threads-%s] Cliente conectado!", tostring(client_id)))

    cliente:send("Digite algo para sair do server")

    while true do
        local linha, erro = cliente:recive()

        if erro then
            print(string.format("Conexão perdida", client_id, erro))
            break
        end

        print("A pessoinha enviou %s", client_id, linha)

        if linha == "sair" then
            cliente:send("Até logo!!!")
            break
        end