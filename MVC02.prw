#include "protheus.ch"
#include "fwmvcdef.ch"

user function MVC02()
    local aArea as array
    local oFwmbr as object

    dbselectarea("Z03")
    Z03->(dbsetorder(1))
    aArea := Z03->(getarea())

    oFwmbr := fwmbrowse():new()
    oFwmbr:setalias("Z03")
    oFwmbr:setdescription("Cadastro de cestas")
    oFwmbr:disabledetails()
    oFwmbr:setmenudef("MVC02")
    oFwmbr:activate()

    Z03->(restarea(aArea))
    Z03->(dbclosearea())
return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC02" operation 1 access 0
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC02" operation 2 access 0
    add option aRotinas title "Incluir" action "VIEWDEF.MVC02" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC02" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC02" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC02" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC02" operation 9 access 0
return aRotinas

static function viewdef() as object
    local oModel as object
    local oStr as object
    local oView as object

    oModel := fwloadmodel("MVC02")

    oStr := fwformstruct(2, "Z03")

    oView := fwformview():new()
    oView:setmodel(oModel)
    oView:addfield("ViewZ03", oStr, "Z03Master")
    oView:createhorizontalbox("Tela", 100)
    oView:setownerview("ViewZ03", "Tela")
    oView:enabletitleview("ViewZ03", "Cestas")
return oView

static function modeldef() as object
    local oModel as object
    local oStr as object
    
    oStr := fwformstruct(1, "Z03")
    
    oModel := mpformmodel():new("MVC02M")
    oModel:addfields("Z03Master",, oStr)
    oModel:setprimarykey({"Z03_FILIAL", "Z03_COD"})
    oModel:setdescription("Dados de cadastro de cestas")
    oModel:getmodel("Z03Master"):setdescription("Dados de cadastro de cestas")
return oModel
