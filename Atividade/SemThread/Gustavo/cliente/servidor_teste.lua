 --apenas um exemplo de server para teste pra ver se ta funcionando a conexão ok  sem threads
local socket = require("socket")

local servidor = assert(socket.bind("*", 8080))

print("Servidor esperando conexão...")

local cliente = servidor:accept()

print("Cliente conectado!")

while true do
    local msg = cliente:receive()

    if not msg then
        break
    end

    print("Cliente disse:", msg)

    cliente:send("Recebi: " .. msg .. "\n")
end

cliente:close()
servidor:close()