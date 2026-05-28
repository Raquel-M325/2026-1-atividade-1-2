local socket = require("socket") --importa biblioteca de sockets do lua

local cliente = socket.tcp() --cria socket tpc

--pega o resultado da conexao direto do connect em vez do cliente_id
local ok, err = cliente:connect("127.0.0.1", 6742) --cliente vai conectar no servidor na porta 8080

if not ok then --se der erro na conexao, entao
    print("Erro:", err) --printa o erro
    os.exit() --fecha o programa
end

print("Cliente conectado ao servidor!") --printa

local boas_vindas = cliente:receive() --espera receber a primeira mensagem do servidor antes do loop
print("Servidor:", boas_vindas) --printa a mensagem de boas vindas

while true do -- enquanto for verdade, faça

    io.write("Escreva uma mensagem: ") --mostra texto na tela sem quebrar linha
    local msg = io.read() -- le algo digitado pelo usuario no teclado

    cliente:send(msg .. "\n") --envia dados para o servidor

    local resposta = cliente:receive() --espera receber dados do servidor

    print("Servidor:", resposta) --printa a resposta
    
    if msg == "sair" then -- se a mensagem for "sair", entao (movido para o final do loop)
        break -- parar
    end 
end

cliente:close() --fecha o cliente