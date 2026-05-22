local lanes = require("lanes").configure() --é o padrao para que funcione a biblioteca lanes, é necessário configurar antes de usar as threads como foi abaixo

local Cliente = {}
Cliente.__index = Cliente

local thread = lanes.gen("*", function(ip, porta, linda) --é a função que roda em uma thread separada para lidar com a conexão do cliente, sendo uma configuração de lane que permite comunicação entre threads usando uma linda 

    local socket = require("socket")
    local tcp = assert(socket.tcp())
    local ok, err = tcp:connect(ip, porta)
    if not ok then
        return linda:send("erro", err)
    end

    -- avisa que conectou
    linda:send("conectado", true)

    tcp:settimeout(0) --evita bloqueio na leitura
    while true do --quando começou ficar conectado, começa o loop infinito até que o cliente feche a conexão ou ocorra um erro
        
        local _, fechar = linda:receive(0, "fechar") --vendo a mensagem fechar e fazer comparação
        if fechar then
            return tcp:close() --fecha a conexão e sai da thread, garante que o socket foi fechado
        end
    
        local msg = tcp:receive("*l") --lê uma linha completa do servidor
        if msg then
            linda:send("chat", msg)
        end

        local _, enviar = linda:receive(0, "enviar") --vendo a mensagem enviar e fazer comparação 
        if enviar then
            tcp:send(enviar .. "\n")
        end

        socket.sleep(0.1)
    end
end)


function Cliente:new(_ip, _porta) --construtor da classe cliente, recebe ip e porta do servidor
    local obj = {ip = _ip, porta = _porta, conexao = false, linda = lanes.linda(), thread_comeca = nil}
    return setmetatable(obj, Cliente)
end


function Cliente:erro()
    local _, err = self.linda:receive(0, "erro")
    return err
end


function Cliente:procura_servidor()

    self.thread_comeca = thread(self.ip, self.porta, self.linda)
    local _, conectado = self.linda:receive(3, "conectado")

    if not conectado then
        local _, err = self.linda:receive(0, "erro")
        return false, err
    end

    self.conexao = true
    return true
end


function Cliente:enviar(msg)
    if not self.conexao then
        return false, self:erro()
    end

    self.linda:send("enviar", msg)
    return true
end


function Cliente:recebe()
    if not self.conexao then
        return false, self:erro()
    end

    local _, msg = self.linda:receive(0, "chat")
    return msg
end


function Cliente:fechar()
    if self.thread_comeca then
        self.linda:send("fechar", true)
        self.thread_comeca = nil
    end

    self.conexao = false
    return true
end

return Cliente