Quadrilatero = {}
Quadrilatero.__index = Quadrilatero

function Quadrilatero:el_pepe(longetude, latitude)
    local obj = {base = longetude, altura = latitude}
    setmetatable(obj, Quadrilatero)
    return obj
end

function Quadrilatero:area()
    return self.base * self.altura
end

function Quadrilatero:base()
    return self.base
end

function Quadrilatero:altura()
    return self.altura
end

numb = tonumber(io.read())
numb2 = tonumber(io.read())

resposta = Quadrilatero:el_pepe(numb, numb2)

print(resposta:area())