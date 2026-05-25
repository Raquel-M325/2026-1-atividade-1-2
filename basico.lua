--print
print("Hello World")
print("O nosso trabalho é: KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK")

-- Variaveis
nome = "Gustavo"
idade = 20

print(nome)
print(idade)

--If
idade1 = 18

if idade >= 18 then -- then é então
    print("Maior de idade")
else -- senao
    print("Menor de idade")
end -- fim termina

--laços loop while

indice = 1

while indice <= 5 do -- enquando o indice for menor ou igual a 5 faça
    print(indice) --printar o indice
    indice = indice + 1 -- incrementa o indice 
end -- finaliza

-- laços for

for indice = 1, 5 do --vai printar do 1 ao 5
    print(indice)
end

--funçoes

function somar(a,b)
    return a + b
end

resultado = somar(10, 5) --somar 10 + 5
print(resultado) --vai mostrar 15 soma

--TABELAS

frutas = {"maçã", "banana" , "uva"}

print(frutas[1]) --printa o elemento de indice 1