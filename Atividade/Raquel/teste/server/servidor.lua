local socket = require("socket")

local servidor = assert(socket.bind("*", 8080))

print("Servidor iniciado na porta 8080")

servidor:settimeout(0)

local clientes = {}

while true do

    -- aceita novos clientes
    local cliente = servidor:accept()

    if cliente then

        cliente:settimeout(0)

        table.insert(clientes, cliente)

        print("Novo cliente conectado")
    end

    -- percorre clientes conectados
    for i = #clientes, 1, -1 do

        local c = clientes[i]

        local msg, err = c:receive("*l")

        if msg then

            print("Cliente:", msg)

            -- envia resposta
            c:send("Servidor recebeu: " .. msg .. "\n")
        end

        -- cliente desconectou
        if err == "closed" then

            print("Cliente desconectado")

            c:close()

            table.remove(clientes, i)
        end
    end

    socket.sleep(0.1)
end