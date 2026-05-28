local Cliente = require("cliente")

local cliente_id = Cliente:new("127.0.0.1", 9090)

local ok, err = cliente_id:procura_servidor()

if not ok then
    print("Erro:", err)
    os.exit()
end

print("Conectado!")

while true do

    local entrada = io.read()

    if entrada == "sair" then
        cliente_id:fechar()
        break
    end

    cliente_id:enviar(entrada)

    local resposta = cliente_id:recebe()

    if resposta then
        print("Servidor:", resposta)
    end
end