local lanes = require("lanes").configure()

local Cliente = {}
Cliente.__index = Cliente

local thread = lanes.gen("*", function(ip, porta, linda)

    local socket = require("socket")

    local tcp = assert(socket.tcp())

    local ok, err = tcp:connect(ip, porta)

    if not ok then
        return linda:send("erro", err)
    end

    linda:send("conectado", true)

    tcp:settimeout(0)

    while true do

        local _, sair = linda:receive(0, "sair")

        if sair then
            tcp:close()
            return
        end

        local msg = tcp:receive("*l")

        if msg then
            linda:send("chat", msg)
        end

        local _, enviar = linda:receive(0, "enviar")

        if enviar then
            tcp:send(enviar .. "\n")
        end

        socket.sleep(0.1)
    end
end)

function Cliente:new(_ip, _porta)

    local obj = {
        ip = _ip,
        porta = _porta,
        conexao = false,
        linda = lanes.linda(),
        thread_comeca = nil
    }

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

    if msg == "" then
        return false
    end

    self.linda:send("enviar", msg)

    return true
end

function Cliente:recebe()

    if not self.conexao then
        return false, self:erro()
    end

    local _, msg = self.linda:receive(1, "chat")

    return msg
end

function Cliente:fechar()

    if self.thread_comeca then
        self.linda:send("sair", true)
        self.thread_comeca = nil
    end

    self.conexao = false

    return true
end

function Cliente:rodar()

    local ok, err = self:procura_servidor()

    if not ok then
        return false, err
    end

    while true do

        local entrada = io.read()

        if entrada == "sair" then
            self:fechar()
            return true
        end

        self:enviar(entrada)

        local msg = self:recebe()

        if msg then
            return msg
        end
    end
end

return Cliente