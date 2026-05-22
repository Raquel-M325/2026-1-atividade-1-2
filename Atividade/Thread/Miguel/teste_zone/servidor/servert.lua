local lanes = require("lanes").configure()
local socket = require("socket")

local function dar_boas_vindas()
    local socket = require("socket")

    local cliente = socket.tcp()
    cliente:settimeout(10)

    local ip, porta = cliente:getpeername() --esse já pega o id do cliente em si
    print(string.format("[Threads-%s] Cliente conectado!", tostring(ip, porta)))

    cliente:send("Digite algo para sair do server")

    while true do
        local linha, erro = cliente:receive("*l")

        if erro then
            print(string.format("Conexão perdida", , erro))
            break
        end

        -- terá que analisar melhor sobre isso, tirei o cliente_id por nao precisar!
        print("A pessoinha enviou %s", , linha)

        if linha == "sair" then
            cliente:send("Até logo!!!")
            break
        end

        cliente:send("Muito bem, você disse" .. linha)

    end

    cliente:close()
end

local function iniciar_server()
    
    local servidor = assert(socket.bind("127.0.0.1", 8080))
    local ip , porta = servidor.getsockname()

    print(string.format("[SERVIDOR] Rodando em %s na porta %d   ", ip, porta))

    local criar_thread_cliente = lanes.gen("*", dar_boas_vindas())

    while true do

        local cliente = servidor:accept()

        criar_thread_cliente(cliente)

        cliente:close()
    end
end

iniciar_server()