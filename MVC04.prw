#include "protheus.ch"
#include "fwmvcdef.ch"

user function MVC04()
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
    local oDlgPrinc as object

    aCoor := fwgetdialogsize(oMainWnd)
    
    oDlgPrinc := msdialog():new(aCoor[1], aCoor[2], aCoor[3], aCoor[4], "Distribuição",,,,,,,,, .T.,,,)

    oFWLayer := fwlayer():new()
    oFWLayer:init(oDlgPrinc, .T.)
    oFWLayer:addline("U", 33, .F.)
    oFWLayer:addline("D", 67, .F.)
    oFWLayer:addcollumn("A", 100, .T., "U")
    oFWLayer:addcollumn("L", 50, .T., "D")
    oFWLayer:addcollumn("R", 50, .T., "D")

    oPanelU := oFWLayer:getcolpanel("A", "U")
    oPanelL := oFWLayer:getcolpanel("L", "D")
    oPanelR := oFWLayer:getcolpanel("R", "D")

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

    oRelacZ4 := fwbrwrelation():new()
    oRelacZ4:addrelation(oBrowseU, oBrowseL, {{"Z04_FILIAL", 'xFilial("Z03")'}, {"Z04_CODC", "Z03_COD"}})
    oRelacZ4:activate()

    oRelacZ3 := fwbrwrelation():new()
    oRelacZ3:addrelation(oBrowseL, oBrowseR, {{"Z02_FILIAL", 'xFilial("Z04")'}, {"Z02_COD", "Z04_CODP"}})
    oRelacZ3:activate()

    oDlgPrinc:activate(,,, .T.,,,,,)
return nil

static function menudef()
return fwloadmenudef("MVC01")

static function modeldef()
return fwloadmodel("MVC01")

static function viewdef()
return fwloadview("MVC01")
