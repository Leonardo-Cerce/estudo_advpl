// Programa com vários browses relacionados entre si
// A ideia inicialmente era permitir interação com o usuário (com cliques duplos nos registros para movimentar o produto para uma cesta)
// Não foi possível fazer isso com a classe FWMBrowse, mas sim com a classe TCBrowse (vide MVC05.prw)
// O funcionamento é como segue: no browse superior, existem as cestas. Ao selecionar a cesta, no browse inferior esquerdo aparecem os itens que estão nela.
// E no browse inferior direito, aparecem as informações específicas do produto selecionado.

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function MVC04() // função principal
    local aCoor as array
    local oPanelU as object
    local oFWLayer as object
    local oPanelL as object
    local oPanelR as object
    local oBrowseU as object
    local oBrowseL as object
    local oBrowseR as object
    local oRelacZ4 as object
    local oRelacZ3 as object
    local oDlgPrinc as object // variáveis

    aCoor := fwgetdialogsize(oMainWnd) // pegar as coordenadas máximas da janela principal
    
    oDlgPrinc := msdialog():new(aCoor[1], aCoor[2], aCoor[3], aCoor[4], "Distribuição",,,,,,,,, .T.,,,) // janela principal

    oFWLayer := fwlayer():new() // cria um layer e inicializa na janela principal
    oFWLayer:init(oDlgPrinc, .T.)
    oFWLayer:addline("U", 33, .F.)
    oFWLayer:addline("D", 67, .F.) // cria duas linhas, uma com 33% da tela e outra com 67%
    oFWLayer:addcollumn("A", 100, .T., "U")
    oFWLayer:addcollumn("L", 50, .T., "D")
    oFWLayer:addcollumn("R", 50, .T., "D") // cria três colunas: uma na primeira linha e duas na segunda

    oPanelU := oFWLayer:getcolpanel("A", "U")
    oPanelL := oFWLayer:getcolpanel("L", "D")
    oPanelR := oFWLayer:getcolpanel("R", "D") // pega os panels correspondentes a cada linha e coluna

    // cria os browses (para mais informações, vide 'mvc01')
    oBrowseU := fwmbrowse():new()
    oBrowseU:setowner(oPanelU)
    oBrowseU:setdescription("Cestas")
    oBrowseU:setalias("Z03")
    oBrowseU:setmenudef("MVC02")
    oBrowseU:setprofileid("1")
    oBrowseU:forcequitbutton()
    oBrowseU:disabledetails()
    oBrowseU:activate()

    oBrowseL := fwmbrowse():new()
    oBrowseL:setowner(oPanelL)
    oBrowseL:setdescription("Produtos na Cesta")
    oBrowseL:setalias("Z04")
    oBrowseL:setmenudef("MVC03")
    oBrowseL:setprofileid("2")
    oBrowseL:disabledetails()
    oBrowseL:setonlyfields({"Z04_CODP"})
    oBrowseL:activate()

    oBrowseR := fwmbrowse():new()
    oBrowseR:setowner(oPanelR)
    oBrowseR:setdescription("Produtos")
    oBrowseR:setalias("Z02")
    oBrowseR:setmenudef("MVC01")
    oBrowseR:setprofileid("3")
    oBrowseR:disabledetails()
    oBrowseR:setonlyfields({"Z02_DESC", "Z02_PR"})
    oBrowseR:activate()

    // cria as relações entre os browses
    oRelacZ4 := fwbrwrelation():new()
    oRelacZ4:addrelation(oBrowseU, oBrowseL, {{"Z04_FILIAL", 'xFilial("Z03")'}, {"Z04_CODC", "Z03_COD"}}) // cesta do browse de cima é a mesma do browse da esquerda
    oRelacZ4:activate()

    oRelacZ3 := fwbrwrelation():new()
    oRelacZ3:addrelation(oBrowseL, oBrowseR, {{"Z02_FILIAL", 'xFilial("Z04")'}, {"Z02_COD", "Z04_CODP"}}) // produto do browse da esquerda é o mesmo do browse da direita
    oRelacZ3:activate()

    oDlgPrinc:activate(,,, .T.,,,,,) // ativa a janela principal
return nil

static function menudef()
return fwloadmenudef("MVC01") // carrega o menudef do arquivo 'mvc01'

static function modeldef()
return fwloadmodel("MVC01") // carrega o modeldef do arquivo 'mvc01'

static function viewdef()
return fwloadview("MVC01") // carrega o viewdef do arquivo 'mvc01'
