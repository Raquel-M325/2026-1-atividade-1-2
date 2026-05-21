local socket = require("socket")

local server = assert(socket.bind("0.0.0.0", 8080))
print("Servidor rodando na porta 8080")

local client = server:accept()
print("Cliente conectado!")

client:send("ola cliente!\n")

local msg = client:receive("*l")
print("Recebido:", msg)

client:close()
server:close()