// Programa que cria um relat�rio a partir de duas tabelas do BD
// Relat�rio de duas se��es: para cada cliente s�o impressos os endere�os cadastrados.

#include "protheus.ch"
#include "topconn.ch" // includes

user function REL00() // fun��o principal
    local oReport as object
    oReport := reportdef() // defini��o do relat�rio
    oReport:printdialog() // di�logo para impress�o
return nil

static function reportdef() as object // fun��o de defini��o do relat�rio
    local oRep as object
    local oSec1 as object
    local oSec2 as object // vari�veis: duas se��es e o relat�rio

    oRep := treport():new("REL00", "Clientes e Enderecos",,{|oRep| printrep(oRep)}, "Este relatorio ira exibir os clientes e seus enderecos cadastrados")
    oRep:setportrait()
    oRep:hideparampage() // orienta��o retrato, com p�gina de par�metros escondida e descri��o do relat�rio

    oSec1 := trsection():new(oRep, "Clientes", {"Z00"},, .F., .T.) // cria��o da se��o de clientes
    trcell():new(oSec1, "NOME",, "NOME",, 50)
    trcell():new(oSec1, "CPF",, "CPF",, 14)
    trcell():new(oSec1, "RG",, "RG" ,, 12)
    trcell():new(oSec1, "EMIL",, "EMAIL",, 50)
    trcell():new(oSec1, "DTNASC",, "DATA NASCIMENTO",, 10) // defini��o das c�lulas da se��o
    oSec1:setlinestyle(.F.) // impress�o em colunas

    oSec2 := trsection():new(oRep, "Enderecos", {"Z01"},, .F., .T.) // cria��o da se��o de endere�os
    trcell():new(oSec2, "TIPO",, "TIPO",, 3)
    trcell():new(oSec2, "ENDR",, "ENDERECO",, 100) // defini��o das c�lulas da se��o
    oSec2:setlinestyle(.F.) // impress�o em colunas
return oRep

static function printrep(oRep as object) // fun��o que insere os registros no relat�rio
    local oSec1 as object
    local oSec2 as object
    local cQuery1 as character
    local cQuery2 as character // vari�veis para as se��es e as querys

    oSec1 := oRep:section(1)
    oSec2 := oRep:section(2) // obtendo as se��es

    // defini��o das querys
    cQuery1 := "SELECT Z00_CPF, Z00_NOME, Z00_EMIL, Z00_RG, Z00_NCEL, Z00_DTNASC FROM Z00990 WHERE D_E_L_E_T_=' ' ORDER BY Z00_CPF"
    cQuery2 := "SELECT Z01_CPF, Z01_TIPO, Z01_ENDR FROM Z01990 WHERE D_E_L_E_T_=' ' ORDER BY Z01_CPF"

    if select("cli") != 0
        dbselectarea("cli")
        cli->(dbclosearea()) // verifica se a query foi aberta, e fecha (caso estiver) para evitar erros
    endif

    if select("endr") != 0
        dbselectarea("endr") // mesmo prop�sito
        endr->(dbclosearea())
    endif

    tcquery cQuery1 new alias "cli"
    tcquery cQuery2 new alias "endr" // defini��o de novos nomes para a query

    dbselectarea("cli")
    dbselectarea("endr") // as querys s�o executadas
    cli->(dbgotop())
    endr->(dbgotop()) // cursores posicionados no primeiro registro

    oRep:setmeter(cli->(lastrec())) // limite da r�gua � o n�mero de registros

    while !cli->(eof()) // enquanto n�o chega ao fim da tabela
        if oRep:cancel()
            exit // se cancelar, sair
        endif

        oSec1:init() // in�cio da maior se��o (dados dos clientes)

        oRep:incmeter() // incrementa a r�gua

        oSec1:cell("NOME"):setvalue(cli->Z00_NOME)
        oSec1:cell("CPF"):setvalue(transform(cli->Z00_CPF, "@R 999.999.999-99"))
        oSec1:cell("RG"):setvalue(transform(cli->Z00_RG, "@R 99.999.999-9"))
        oSec1:cell("DTNASC"):setvalue(cli->Z00_DTNASC)
        oSec1:cell("EMIL"):setvalue(cli->Z00_EMIL)
        oSec1:printline() // define os valores e os insere no relat�rio

        oSec2:init() // in�cio da se��o menor (endere�os)

        while endr->Z01_CPF == cli->Z00_CPF // enquanto o CPF do endere�o for igual ao do cliente
            oRep:incmeter() // incrementa a r�gua
            oSec2:cell("TIPO"):setvalue(endr->Z01_TIPO)
            oSec2:cell("ENDR"):setvalue(endr->Z01_ENDR)
            oSec2:printline() // define os valores e os insere no relat�rio
            endr->(dbskip()) // vai para o pr�ximo endere�o
        enddo

        oSec2:finish() // finaliza a se��o de endere�os
        
        oRep:thinline() // cria uma linha para separar diferentes clientes

        oSec1:finish() // finaliza a se��o de clientes

        cli->(dbskip()) // vai para o pr�ximo cliente
    enddo

cli->(dbclosearea())
endr->(dbclosearea()) // fecha as tabelas de endere�o e de cliente
return nil
