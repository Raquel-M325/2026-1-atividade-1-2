local lanes = require("lanes").configure()
local socket = require("socket")

-- Esta função rodará dentro de cada Thread (Lane)
local function dar_boas_vindas(cliente)
    -- Importante: Dentro da lane, precisamos reimportar módulos se necessário,
    -- mas o objeto 'cliente' passado já mantém sua estrutura de socket.
    
    cliente:settimeout(10)

    -- Corrigido: getpeername (com 'e') e usando `:`
    local ip, porta = cliente:getpeername()
    print(string.format("[Thread] Cliente conectado de %s:%d", tostring(ip), porta))

    cliente:send("Digite algo (ou 'sair' para encerrar):\n")

    while true do
        local linha, erro = cliente:receive("*l")

        if erro then
            print(string.format("[Thread] Conexão perdida com %s: %s", tostring(ip), tostring(erro)))
            break
        end

        -- Corrigido: Uso do string.format para o print
        print(string.format("[Servidor] O cliente %s enviou: %s", tostring(ip), tostring(linha)))

        if linha == "sair" then
            cliente:send("Até logo!!!\n")
            break
        end

        -- Adicionado um \n no final para que o cliente receba a quebra de linha
        cliente:send("Muito bem, você disse: " .. linha .. "\n")
    end

    cliente:close()
    print(string.format("[Thread] Conexão com %s encerrada.", tostring(ip)))
end

local function iniciar_server()
    local servidor = assert(socket.bind("127.0.0.1", 9090))
    -- Corrigido: Uso de `:` em getsockname()
    local ip, porta = servidor:getsockname()

    print(string.format("[SERVIDOR] Rodando em %s na porta %d", ip, porta))

    -- Corrigido: Passado o nome correto da função (dar_boas_vindas)
    local criar_thread_cliente = lanes.gen("*", dar_boas_vindas)

    while true do
        local cliente = servidor:accept()

        -- Passamos o objeto cliente INTEIRO para a thread.
        -- O LuaLanes se encarrega de mover o socket para a nova thread de forma segura.
        criar_thread_cliente(cliente)

        -- IMPORTANTE: NÃO feche o cliente aqui! 
        -- Se fechar aqui, o socket morre antes da thread conseguir ler/escrever nele.
    end
end

iniciar_server()