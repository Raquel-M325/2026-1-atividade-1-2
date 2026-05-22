local lanes = require("lanes").configure()
local socket = require("socket")

local function dar_boas_vindas(client_id)
    local socket = require("socket")

    local cliente = socket.tcp(client_id)
    cliente:settimeout(10)

    local client_id , porta = cliente:getpeernama()
    print(string.format("[Threads-%s] Cliente conectado!", tostring(client_id)))

    cliente:send("Digite algo para sair do server")

    while true do
        local linha, erro = cliente:receive("*l")

        if erro then
            print(string.format("Conexão perdida", client_id, erro))
            break
        end

        print("A pessoinha enviou %s", client_id, linha)

        if linha == "sair" then
            cliente:send("Até logo!!!")
            break
        end

        cliente:send("Muito bem, você disse" .. linha)

    end

    cliente:close()
end

local function inciar_server()
    
    local servidor = assert(socket.bind("127.0.0.1", 8080))
    local ip , porta = servidor.getsockname()

    print(string.format("[SERVIDOR] Rodando em %s na porta %d   ", ip, porta))

    local criar_thread_cliente = lanes.gen("*", gerenciar_cliente)

    while true do

        local cliente = servidor:accept()

        local cliente_id = cliente:getfd()

        criar_thread_cliente(client_id)

        cliente:close()
    end
end

inciar_server()