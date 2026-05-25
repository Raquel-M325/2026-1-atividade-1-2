local socket = require("socket") --importa biblioteca de sockets do lua

local cliente = socket.tcp() --cria socket tpc

cliente:connect("127.0.0.1", 8080) --cliente vai conectar no servidor na porta 8080

print("Cliente conectado ao servidor!") --printa

while true do -- enquanto for verdade, faça

    io.write("Escrever algo: ") --mostra texto na tela sem quebrar linha
    local msg = io.read() -- le algo digitado pelo usuario no teclado

    if msg == "sair" then -- se a mensagem for "sair", entao
        break -- parar
    end 

    cliente:send(msg .. "\n") --envia dados para o servidor

    local resposta = cliente:receive() --espera receber dados do servidor

    print("Servidor:", resposta)
end

cliente:close() --fecha o cliente