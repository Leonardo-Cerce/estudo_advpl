#include "protheus.ch"
#include "fwmvcdef.ch"

user function MVC01()
    local aArea as array
    local oFwmbr as object

    dbselectarea("Z02")
    Z02->(dbsetorder(1))
    aArea := Z02->(getarea())

    oFwmbr := fwmbrowse():new()
    oFwmbr:setalias("Z02")
    oFwmbr:setdescription("Cadastro de produtos")
    oFwmbr:disabledetails()
    oFwmbr:setmenudef("MVC01")
    oFwmbr:activate()

    Z02->(restarea(aArea))
    Z02->(dbclosearea())
return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC01" operation 1 access 0
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC01" operation 2 access 0
    add option aRotinas title "Incluir" action "VIEWDEF.MVC01" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC01" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC01" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC01" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC01" operation 9 access 0
return aRotinas

static function viewdef() as object
    local oModel as object
    local oStr as object
    local oView as object

    oModel := fwloadmodel("MVC01")

    oStr := fwformstruct(2, "Z02")

    oView := fwformview():new()
    oView:setmodel(oModel)
    oView:addfield("ViewZ02", oStr, "Z02Master")
    oView:createhorizontalbox("Tela", 100)
    oView:setownerview("ViewZ02", "Tela")
    oView:enabletitleview("ViewZ02", "Produtos")
return oView

static function modeldef() as object
    local oModel as object
    local oStr as object
    
    oStr := fwformstruct(1, "Z02")
    
    oModel := mpformmodel():new("MVC01M")
    oModel:addfields("Z02Master",, oStr)
    oModel:setprimarykey({"Z02_FILIAL", "Z02_COD"})
    oModel:setdescription("Dados de cadastro de produtos")
    oModel:getmodel("Z02Master"):setdescription("Dados de cadastro de produtos")
return oModel
