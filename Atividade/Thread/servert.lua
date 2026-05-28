local lanes = require("lanes").configure()
local socket = require("socket")

local function escutar_conexoes()
    local socket = require("socket")
    local servidor = assert(socket.tcp())
    servidor:setoption("reuseaddr", true)
    servidor:setoption("reuseport", true)
    
    assert(servidor:bind("127.0.0.1", 9090))
    servidor:listen()
    servidor:settimeout(0) -- Torna o servidor não-bloqueante

    -- Tabela para guardar os clientes específicos DESTA thread
    local clientes = {}

    while true do
        -- Monta a lista de sockets que esta thread vai monitorar
        local leitores = { servidor }
        for _, c in ipairs(clientes) do
            table.insert(leitores, c)
        end

        -- Espera até que algum socket receba dados (timeout de 1 segundo para não travar a CPU)
        local prontos, _, erro = socket.select(leitores, nil, 1)

        if prontos then
            for _, skt in ipairs(prontos) do
                
                if skt == servidor then
                    -- É um NOVO cliente chegando nesta thread
                    local novo_cliente = servidor:accept()
                    if novo_cliente then
                        novo_cliente:settimeout(0) -- Não deixa o cliente travar a thread
                        table.insert(clientes, novo_cliente)
                        
                        local ip, porta = novo_cliente:getpeername()
                        print(string.format("[Thread] Novo cliente aceito nesta thread: %s:%d", tostring(ip), porta))
                        novo_cliente:send("Digite algo (ou 'sair' para encerrar):\n")
                    end
                else
                    -- É um cliente ANTIGO enviando dados
                    local linha, err = skt:receive("*l")
                    local ip, porta = skt:getpeername()

                    if err then
                        -- Cliente desconectou ou deu erro
                        print(string.format("[Thread] Conexão perdida com %s: %s", tostring(ip), tostring(err)))
                        skt:close()
                        for i, c in ipairs(clientes) do
                            if c == skt then table.remove(clientes, i); break end
                        end
                    else
                        print(string.format("[Servidor] Recebido de %s: %s", tostring(ip), tostring(linha)))
                        
                        if linha == "sair" then
                            skt:send("Até logo!!!\n")
                            skt:close()
                            for i, c in ipairs(clientes) do
                                if c == skt then table.remove(clientes, i); break end
                            end
                        else
                            skt:send("Muito bem, você disse: " .. linha .. "\n")
                        end
                    end
                end

            end
        end
    end
end

local function iniciar_server()
    print("[SERVIDOR] Inicializando Pool de Threads na porta 9090...")
    local criar_thread = lanes.gen("*", escutar_conexoes)
    
    local num_threads = 10
    local threads = {}
    
    for i = 1, num_threads do
        threads[i] = criar_thread()
    end

    print(string.format("[SERVIDOR] %d threads paralelas rodando em Background.", num_threads))
    
    for i = 1, num_threads do
        threads[i]:join()
    end
end

iniciar_server()


-- local lanes = require("lanes").configure()
-- local socket = require("socket")

-- -- Esta função rodará em paralelo dentro de cada Thread (Lane)
-- local function escutar_conexoes()
--     -- Dentro da lane, precisamos importar o módulo socket
--     local socket = require("socket")
    
--     -- Cada thread cria seu próprio socket apontando para a mesma porta
--     local servidor = assert(socket.tcp())
--     servidor:setoption("reuseaddr", true)
--     servidor:setoption("reuseport", true) -- Permite que múltiplas threads dividam a mesma porta
    
--     assert(servidor:bind("127.0.0.1", 9090))
--     servidor:listen()

--     while true do
--         -- O próprio SO escolhe uma thread em paralelo para aceitar o cliente
--         local cliente = servidor:accept()
--         cliente:settimeout(60)

--         local ip, porta = cliente:getpeername()
--         print(string.format("[Thread] Cliente conectado de %s:%d", tostring(ip), porta))

--         cliente:send("Digite algo (ou 'sair' para encerrar):\n")

--         while true do
--             local linha, erro = cliente:receive("*l")

--             if erro then
--                 print(string.format("[Thread] Conexão perdida com %s: %s", tostring(ip), tostring(erro)))
--                 break
--             end

--             print(string.format("[Servidor] O cliente %s enviou: %s", tostring(ip), tostring(linha)))

--             if linha == "sair" then
--                 cliente:send("Até logo!!!\n")
--                 break
--             end

--             cliente:send("Muito bem, você disse: " .. linha .. "\n")
--         end

--         cliente:close()
--         print(string.format("[Thread] Conexão com %s encerrada.", tostring(ip)))
--     end
-- end

-- local function iniciar_server()
--     print("[SERVIDOR] Inicializando Pool de Threads na porta 9090...")

--     local criar_thread = lanes.gen("*", escutar_conexoes)
    
--     -- Definimos quantas threads reais vão rodar em paralelo (ex: 4 threads)
--     local num_threads = 10
--     local threads = {}
    
--     for i = 1, num_threads do
--         threads[i] = criar_thread()
--     end

--     print(string.format("[SERVIDOR] %d threads disparadas e prontas para receber clientes.", num_threads))
    
--     -- Mantém a thread principal do arquivo viva enquanto as outras trabalham
--     for i = 1, num_threads do
--         threads[i]:join()
--     end
-- end

-- iniciar_server()


-- local lanes = require("lanes").configure()
-- local socket = require("socket")

-- -- Esta função rodará dentro de cada Thread (Lane)
-- local function dar_boas_vindas(cliente)
--     -- Importante: Dentro da lane, precisamos reimportar módulos se necessário,
--     -- mas o objeto 'cliente' passado já mantém sua estrutura de socket.
    
--     cliente:settimeout(10)

--     -- Corrigido: getpeername (com 'e') e usando `:`
--     local ip, porta = cliente:getpeername()
--     print(string.format("[Thread] Cliente conectado de %s:%d", tostring(ip), porta))

--     cliente:send("Digite algo (ou 'sair' para encerrar):\n")

--     while true do
--         local linha, erro = cliente:receive("*l")

--         if erro then
--             print(string.format("[Thread] Conexão perdida com %s: %s", tostring(ip), tostring(erro)))
--             break
--         end

--         -- Corrigido: Uso do string.format para o print
--         print(string.format("[Servidor] O cliente %s enviou: %s", tostring(ip), tostring(linha)))

--         if linha == "sair" then
--             cliente:send("Até logo!!!\n")
--             break
--         end

--         -- Adicionado um \n no final para que o cliente receba a quebra de linha
--         cliente:send("Muito bem, você disse: " .. linha .. "\n")
--     end

--     cliente:close()
--     print(string.format("[Thread] Conexão com %s encerrada.", tostring(ip)))
-- end

-- local function iniciar_server()
--     local servidor = assert(socket.bind("127.0.0.1", 9090))
--     -- Corrigido: Uso de `:` em getsockname()
--     local ip, porta = servidor:getsockname()

--     print(string.format("[SERVIDOR] Rodando em %s na porta %d", ip, porta))

--     -- Corrigido: Passado o nome correto da função (dar_boas_vindas)
--     local criar_thread_cliente = lanes.gen("*", dar_boas_vindas)

--     while true do
--         local cliente = servidor:accept()

--         -- Passamos o objeto cliente INTEIRO para a thread.
--         -- O LuaLanes se encarrega de mover o socket para a nova thread de forma segura.
--         criar_thread_cliente(cliente)

--         -- IMPORTANTE: NÃO feche o cliente aqui! 
--         -- Se fechar aqui, o socket morre antes da thread conseguir ler/escrever nele.
--     end
-- end

-- iniciar_server()