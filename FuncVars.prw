#include "protheus.ch" // macros, constantes etc

User Function FuncVars() // As Numeric - definir o tipo de dado que a função retorna
// Local - escopo função
// Private - escopo arquivo
// Tipos básicos de dados:
Local cTexto As Character
Local nNum As Numeric
Local lLogic As Logical
Local aArray As Array
Local oObjeto As Object
Local jJson As Json
Local bBlock As Codeblock
Local nI As Numeric
Local dData As Date
Local dData2 As Date

cTexto := "Hello World!"

nNum := 1.0 // real ou inteiro

lLogic := .T. // ou .F.

aArray := {cTexto, nNum, lLogic}

oObjeto := tSay():New()// classes

jJson := jsonObject():New() // utilizar construtor
jJson["Nome"] := "Leonardo"
jJson["Idade"] := 22

bBlock := {|Nome, Endereco| qout(Nome), qout(Endereco)}
eval(bBlock, "Leonardo", "Rua Paraná")

dData := CToD("25/03/22") // 2022 ou 22
dData2 := Date()

dData := dData2 + 10

Aadd(aArray, "Rua_Paraná")

For nI := 1 To len(aArray) // array inicia em 1
    qout(cValtoChar(aArray[nI])) // qout somente string
Next nI

if jJson["Idade"] > 22
    qout("Maior")
elseif jJson["Idade"] < 22
    qout("Menor")
else
    qout("Igual")
endif

while nI < jJson["Idade"]
    qout(CValToChar(nI))
    nI++ // nI+=valor
enddo

qout(cValToChar(Teste1(20)))
// para chamar outra user function utilizar U_nome da função
return NIL

Static Function Teste1(Idade As Numeric) As Numeric//- visível somente pelo arquivo
    // Local ou private
    // chamar funções normalmente
return Idade
