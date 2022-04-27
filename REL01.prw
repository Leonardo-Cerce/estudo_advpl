// Programa que cria um relat�rio a partir de duas tabelas do BD
// Relat�rio de duas se��es: para cada cesta s�o impressos os itens e o pre�o total.

#include "protheus.ch"
#include "topconn.ch" // includes

user function REL01() // fun��o principal
    local oReport as object
    oReport := reportdef() // defini��o do relat�rio
    oReport:printdialog() // di�logo para impress�o
return nil

static function reportdef() as object // fun��o de defini��o do relat�rio
    local oRep as object
    local oSec1 as object
    local oSec2 as object // vari�veis: duas se��es e o relat�rio

    oRep := treport():new("REL01", "Cestas e Produtos",,{|oRep| printrep(oRep)}, "Este relatorio ira exibir as cestas e o produtos que estao nelas.")
    oRep:setportrait()
    oRep:hideparampage() // orienta��o retrato, com p�gina de par�metros escondida e descri��o do relat�rio

    oSec1 := trsection():new(oRep, "Cestas", {"Z03"},, .F., .T.) // cria��o da se��o
    trcell():new(oSec1, "COD",, "C�DIGO DA CESTA",, 6)
    trcell():new(oSec1, "DESC",, "DESCRI��O DA CESTA",, 100)
    trcell():new(oSec1, "TOT",, "TOTAL DOS PRODUTOS NA CESTA" ,, 5) // defini��o das c�lulas da se��o
    oSec1:setlinestyle(.F.) // impress�o em colunas

    oSec2 := trsection():new(oRep, "Produtos", {"Z04"},, .F., .T.) // cria��o da se��o
    trcell():new(oSec2, "CODP",, "C�DIGO DO PRODUTO",, 6)
    trcell():new(oSec2, "PDESC",, "DESCRI��O DO PRODUTO",, 100)
    trcell():new(oSec2, "QUANT",, "QUANTIDADE",, 2)
    trcell():new(oSec2, "TOTAL",, "TOTAL PARCIAL",, 5) // defini��o das c�lulas da se��o
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
    cQuery1 := "SELECT Z03_COD, Z03_DESC FROM Z03990 WHERE D_E_L_E_T_=' ' ORDER BY Z03_COD"
    cQuery2 := "SELECT Z04_CODC, Z04_CODP, Z04_PDESC, Z04_QUANT, Z04_TOTAL FROM Z04990 WHERE D_E_L_E_T_=' ' ORDER BY Z04_CODC, Z04_CODP"

    if select("Cesta") != 0
        dbselectarea("Cesta")
        Cesta->(dbclosearea()) // verifica se a query foi aberta, e fecha (caso estiver) para evitar erros
    endif

    if select("Prods") != 0
        dbselectarea("Prods") // mesmo prop�sito
        Prods->(dbclosearea())
    endif

    tcquery cQuery1 new alias "Cesta"
    tcquery cQuery2 new alias "Prods" // defini��o de novos nomes para a query

    dbselectarea("Cesta")
    dbselectarea("Prods") // as querys s�o executadas
    Cesta->(dbgotop())
    Prods->(dbgotop()) // cursores posicionados no primeiro registro

    oRep:setmeter(Cesta->(lastrec())) // limite da r�gua � o n�mero de registros

    while !Cesta->(eof()) // enquanto n�o chega ao fim da tabela
        if oRep:cancel()
            exit // se cancelar, sair
        endif

        oSec1:init() // in�cio da se��o

        oRep:incmeter() // incrementa a r�gua

        oSec1:cell("COD"):setvalue(Cesta->Z03_COD)
        oSec1:cell("DESC"):setvalue(Cesta->Z03_DESC)
        oSec1:cell("TOT"):setvalue(ContTot(Cesta->Z03_COD))
        oSec1:printline() // define os valores e os insere no relat�rio

        oSec2:init() // in�cio da se��o

        while Prods->Z04_CODC == Cesta->Z03_COD // enquanto o c�digo da cesta for o mesmo
            oRep:incmeter() // incrementa a r�gua
            oSec2:cell("CODP"):setvalue(Prods->Z04_CODP)
            oSec2:cell("PDESC"):setvalue(Prods->Z04_PDESC)
            oSec2:cell("QUANT"):setvalue(Prods->Z04_QUANT)
            oSec2:cell("TOTAL"):setvalue(Prods->Z04_TOTAL)
            oSec2:printline() // define os valores e os insere no relat�rio
            Prods->(dbskip()) // vai para o pr�ximo endere�o
        enddo

        oSec2:finish() // finaliza a se��o
        
        oRep:thinline() // cria uma linha para separar diferentes cestas

        oSec1:finish() // finaliza a se��o

        Cesta->(dbskip()) // vai para o pr�ximo registro
    enddo

Cesta->(dbclosearea())
Prods->(dbclosearea()) // fecha as tabelas
return nil

static function ContTot(cCodc as character) as numeric // contabiliza o total dos produtos em cada cesta
    local nTot as numeric
    nTot := 0
    while alltrim(Prods->Z04_CODC) == cCodc // enquanto o produto pertencer � cesta atual, soma no total
        nTot += Prods->Z04_TOTAL
        Prods->(dbskip())
    enddo
    Prods->(dbgotop()) // voltar ao primeiro registro
return nTot
