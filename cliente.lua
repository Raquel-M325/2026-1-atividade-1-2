local socket = require("socket")

local Cliente = {}
Cliente.__index = Cliente

function Cliente:new(ip, porta)

    return setmetatable({
        ip = ip,
        porta = porta,
        conexao = false,
        tcp = assert(socket.tcp()),
        lanes = require("lanes").configure()
    }, Cliente)
end

function Cliente:procura_servidor()

    local ok, err = self.tcp:connect(self.ip, self.porta)

    if ok then
        self.conexao = true
        return true
    end

    return false, err
end

function Cliente:recebe()

    if not self.conexao then
        return false
    end

    return self.tcp:receive("*l")
end

function Cliente:enviar(msg)

    if not self.conexao then
        return false
    end

    return self.tcp:send(msg .. "\n")
end

function Cliente:fechar()

    if self.conexao then
        self.tcp:close()
        self.conexao = false
        return true
    end

    return false
end

return Cliente