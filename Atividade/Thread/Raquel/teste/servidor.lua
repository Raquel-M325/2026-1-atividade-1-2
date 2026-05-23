local socket = require("socket")

local servidor = assert(socket.bind("*", 9090))

print("Servidor rodando na porta 9090")

local cliente = servidor:accept()

print("Cliente conectado!")

while true do
    local msg = cliente:receive("*l")

    if msg then
        cliente:send("Recebi: " .. msg .. "\n")
    end
end