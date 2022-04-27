// Programa que cria um relatório a partir de duas tabelas do BD
// Relatório de duas seções: para cada cesta são impressos os itens e o preço total.

#include "protheus.ch"
#include "topconn.ch" // includes

user function REL01() // função principal
    local oReport as object
    oReport := reportdef() // definição do relatório
    oReport:printdialog() // diálogo para impressão
return nil

static function reportdef() as object // função de definição do relatório
    local oRep as object
    local oSec1 as object
    local oSec2 as object // variáveis: duas seções e o relatório

    oRep := treport():new("REL01", "Cestas e Produtos",,{|oRep| printrep(oRep)}, "Este relatorio ira exibir as cestas e o produtos que estao nelas.")
    oRep:setportrait()
    oRep:hideparampage() // orientação retrato, com página de parâmetros escondida e descrição do relatório

    oSec1 := trsection():new(oRep, "Cestas", {"Z03"},, .F., .T.) // criação da seção
    trcell():new(oSec1, "COD",, "CÓDIGO DA CESTA",, 6)
    trcell():new(oSec1, "DESC",, "DESCRIÇÃO DA CESTA",, 100)
    trcell():new(oSec1, "TOT",, "TOTAL DOS PRODUTOS NA CESTA" ,, 5) // definição das células da seção
    oSec1:setlinestyle(.F.) // impressão em colunas

    oSec2 := trsection():new(oRep, "Produtos", {"Z04"},, .F., .T.) // criação da seção
    trcell():new(oSec2, "CODP",, "CÓDIGO DO PRODUTO",, 6)
    trcell():new(oSec2, "PDESC",, "DESCRIÇÃO DO PRODUTO",, 100)
    trcell():new(oSec2, "QUANT",, "QUANTIDADE",, 2)
    trcell():new(oSec2, "TOTAL",, "TOTAL PARCIAL",, 5) // definição das células da seção
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
    cQuery1 := "SELECT Z03_COD, Z03_DESC FROM Z03990 WHERE D_E_L_E_T_=' ' ORDER BY Z03_COD"
    cQuery2 := "SELECT Z04_CODC, Z04_CODP, Z04_PDESC, Z04_QUANT, Z04_TOTAL FROM Z04990 WHERE D_E_L_E_T_=' ' ORDER BY Z04_CODC, Z04_CODP"

    if select("Cesta") != 0
        dbselectarea("Cesta")
        Cesta->(dbclosearea()) // verifica se a query foi aberta, e fecha (caso estiver) para evitar erros
    endif

    if select("Prods") != 0
        dbselectarea("Prods") // mesmo propósito
        Prods->(dbclosearea())
    endif

    tcquery cQuery1 new alias "Cesta"
    tcquery cQuery2 new alias "Prods" // definição de novos nomes para a query

    dbselectarea("Cesta")
    dbselectarea("Prods") // as querys são executadas
    Cesta->(dbgotop())
    Prods->(dbgotop()) // cursores posicionados no primeiro registro

    oRep:setmeter(Cesta->(lastrec())) // limite da régua é o número de registros

    while !Cesta->(eof()) // enquanto não chega ao fim da tabela
        if oRep:cancel()
            exit // se cancelar, sair
        endif

        oSec1:init() // início da seção

        oRep:incmeter() // incrementa a régua

        oSec1:cell("COD"):setvalue(Cesta->Z03_COD)
        oSec1:cell("DESC"):setvalue(Cesta->Z03_DESC)
        oSec1:cell("TOT"):setvalue(ContTot(Cesta->Z03_COD))
        oSec1:printline() // define os valores e os insere no relatório

        oSec2:init() // início da seção

        while Prods->Z04_CODC == Cesta->Z03_COD // enquanto o código da cesta for o mesmo
            oRep:incmeter() // incrementa a régua
            oSec2:cell("CODP"):setvalue(Prods->Z04_CODP)
            oSec2:cell("PDESC"):setvalue(Prods->Z04_PDESC)
            oSec2:cell("QUANT"):setvalue(Prods->Z04_QUANT)
            oSec2:cell("TOTAL"):setvalue(Prods->Z04_TOTAL)
            oSec2:printline() // define os valores e os insere no relatório
            Prods->(dbskip()) // vai para o próximo endereço
        enddo

        oSec2:finish() // finaliza a seção
        
        oRep:thinline() // cria uma linha para separar diferentes cestas

        oSec1:finish() // finaliza a seção

        Cesta->(dbskip()) // vai para o próximo registro
    enddo

Cesta->(dbclosearea())
Prods->(dbclosearea()) // fecha as tabelas
return nil

static function ContTot(cCodc as character) as numeric // contabiliza o total dos produtos em cada cesta
    local nTot as numeric
    nTot := 0
    while alltrim(Prods->Z04_CODC) == cCodc // enquanto o produto pertencer à cesta atual, soma no total
        nTot += Prods->Z04_TOTAL
        Prods->(dbskip())
    enddo
    Prods->(dbgotop()) // voltar ao primeiro registro
return nTot
