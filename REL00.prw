// Programa que cria um relatório a partir de duas tabelas do BD
// Relatório de duas seções: para cada cliente são impressos os endereços cadastrados.

#include "protheus.ch"
#include "topconn.ch" // includes

user function REL00() // função principal
    local oReport as object
    oReport := reportdef() // definição do relatório
    oReport:printdialog() // diálogo para impressão
return nil

static function reportdef() as object // função de definição do relatório
    local oRep as object
    local oSec1 as object
    local oSec2 as object // variáveis: duas seções e o relatório

    oRep := treport():new("REL00", "Clientes e Enderecos",,{|oRep| printrep(oRep)}, "Este relatorio ira exibir os clientes e seus enderecos cadastrados")
    oRep:setportrait()
    oRep:hideparampage() // orientação retrato, com página de parâmetros escondida e descrição do relatório

    oSec1 := trsection():new(oRep, "Clientes", {"Z00"},, .F., .T.) // criação da seção de clientes
    trcell():new(oSec1, "NOME",, "NOME",, 50)
    trcell():new(oSec1, "CPF",, "CPF",, 14)
    trcell():new(oSec1, "RG",, "RG" ,, 12)
    trcell():new(oSec1, "EMIL",, "EMAIL",, 50)
    trcell():new(oSec1, "DTNASC",, "DATA NASCIMENTO",, 10) // definição das células da seção
    oSec1:setlinestyle(.F.) // impressão em colunas

    oSec2 := trsection():new(oRep, "Enderecos", {"Z01"},, .F., .T.) // criação da seção de endereços
    trcell():new(oSec2, "TIPO",, "TIPO",, 3)
    trcell():new(oSec2, "ENDR",, "ENDERECO",, 100) // definição das células da seção
    oSec2:setlinestyle(.F.) // impressão em colunas
return oRep

static function printrep(oRep as object) // função que insere os registros no relatório
    local oSec1 as object
    local oSec2 as object
    local cQuery1 as character
    local cQuery2 as character // variáveis para as seções e as querys

    oSec1 := oRep:section(1)
    oSec2 := oRep:section(2) // obtendo as seções

    // definição das querys
    cQuery1 := "SELECT Z00_CPF, Z00_NOME, Z00_EMIL, Z00_RG, Z00_NCEL, Z00_DTNASC FROM Z00990 WHERE D_E_L_E_T_=' ' ORDER BY Z00_CPF"
    cQuery2 := "SELECT Z01_CPF, Z01_TIPO, Z01_ENDR FROM Z01990 WHERE D_E_L_E_T_=' ' ORDER BY Z01_CPF"

    if select("cli") != 0
        dbselectarea("cli")
        cli->(dbclosearea()) // verifica se a query foi aberta, e fecha (caso estiver) para evitar erros
    endif

    if select("endr") != 0
        dbselectarea("endr") // mesmo propósito
        endr->(dbclosearea())
    endif

    tcquery cQuery1 new alias "cli"
    tcquery cQuery2 new alias "endr" // definição de novos nomes para a query

    dbselectarea("cli")
    dbselectarea("endr") // as querys são executadas
    cli->(dbgotop())
    endr->(dbgotop()) // cursores posicionados no primeiro registro

    oRep:setmeter(cli->(lastrec())) // limite da régua é o número de registros

    while !cli->(eof()) // enquanto não chega ao fim da tabela
        if oRep:cancel()
            exit // se cancelar, sair
        endif

        oSec1:init() // início da maior seção (dados dos clientes)

        oRep:incmeter() // incrementa a régua

        oSec1:cell("NOME"):setvalue(cli->Z00_NOME)
        oSec1:cell("CPF"):setvalue(transform(cli->Z00_CPF, "@R 999.999.999-99"))
        oSec1:cell("RG"):setvalue(transform(cli->Z00_RG, "@R 99.999.999-9"))
        oSec1:cell("DTNASC"):setvalue(cli->Z00_DTNASC)
        oSec1:cell("EMIL"):setvalue(cli->Z00_EMIL)
        oSec1:printline() // define os valores e os insere no relatório

        oSec2:init() // início da seção menor (endereços)

        while endr->Z01_CPF == cli->Z00_CPF // enquanto o CPF do endereço for igual ao do cliente
            oRep:incmeter() // incrementa a régua
            oSec2:cell("TIPO"):setvalue(endr->Z01_TIPO)
            oSec2:cell("ENDR"):setvalue(endr->Z01_ENDR)
            oSec2:printline() // define os valores e os insere no relatório
            endr->(dbskip()) // vai para o próximo endereço
        enddo

        oSec2:finish() // finaliza a seção de endereços
        
        oRep:thinline() // cria uma linha para separar diferentes clientes

        oSec1:finish() // finaliza a seção de clientes

        cli->(dbskip()) // vai para o próximo cliente
    enddo

cli->(dbclosearea())
endr->(dbclosearea()) // fecha as tabelas de endereço e de cliente
return nil
