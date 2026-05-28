local socket = require("socket")

local function escutar_conexoes()
    local servidor = assert(socket.tcp())
    
    -- Mantemos apenas o reuseaddr. O reuseport foi removido porque
    -- agora temos apenas um processo ouvindo nesta porta.
    servidor:setoption("reuseaddr", true)
    
    assert(servidor:bind("127.0.0.1", 6742))
    servidor:listen(1)

    print("[SERVIDOR] Servidor sem threads rodando na porta 6742...")

    while true do
        local cliente = servidor:accept()
        
        if cliente then
            -- É um NOVO cliente chegando
            local ip, porta = cliente:getpeername()
            print(string.format("[Servidor] Novo cliente aceito: %s:%d", tostring(ip), porta))
            cliente:send("Digite algo (ou 'sair' para encerrar):\n")

            while true do
                -- É um cliente ANTIGO enviando dados
                local linha, err = cliente:receive("*l")

                if err then
                    -- Cliente desconectou ou deu erro
                    print(string.format("[Servidor] Conexão perdida com %s: %s", tostring(ip), tostring(err)))
                    break 
                else
                    print(string.format("[Servidor] Recebido de %s: %s", tostring(ip), tostring(linha)))
                    
                    if linha == "sair" then
                        cliente:send("Até logo!!!\n")
                        break 
                    else
                        cliente:send("Recebi a mensagem: " .. linha .. "\n")
                    end
                end
            end
            
            cliente:close()
        end
    end
end

-- Em vez de criar um pool de threads, nós simplesmente 
-- chamamos a função principal diretamente na nossa única thread (o próprio script).
escutar_conexoes()