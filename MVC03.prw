// Programa simples de cadastro de produtos em cestas de compra usando o modelo MVC
// Programa criado para facilitar a adição de dados no BD
// Pouca mudança em relação ao MVC01
// Verificar MVC01 para comentários acerca da implementação

#include "protheus.ch"
#include "fwmvcdef.ch"

user function MVC03()
    local aArea as array
    local oFwmbr as object

    dbselectarea("Z04")
    Z04->(dbsetorder(1))
    aArea := Z04->(getarea())

    oFwmbr := fwmbrowse():new()
    oFwmbr:setalias("Z04")
    oFwmbr:setdescription("Cadastro de produtos em cestas")
    oFwmbr:disabledetails()
    oFwmbr:setmenudef("MVC03")
    oFwmbr:activate()

    Z04->(restarea(aArea))
    Z04->(dbclosearea())
return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC03" operation 1 access 0
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC03" operation 2 access 0
    add option aRotinas title "Incluir" action "VIEWDEF.MVC03" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC03" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC03" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC03" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC03" operation 9 access 0
return aRotinas

static function viewdef() as object
    local oModel as object
    local oStr as object
    local oView as object

    oModel := fwloadmodel("MVC03")

    oStr := fwformstruct(2, "Z04")

    oView := fwformview():new()
    oView:setmodel(oModel)
    oView:addfield("ViewZ04", oStr, "Z04Master")
    oView:createhorizontalbox("Tela", 100)
    oView:setownerview("ViewZ04", "Tela")
    oView:enabletitleview("ViewZ04", "Produtos em Cestas")
return oView

static function modeldef() as object
    local oModel as object
    local oStr as object
    
    oStr := fwformstruct(1, "Z04")
    
    oModel := mpformmodel():new("MVC03M")
    oModel:addfields("Z04Master",, oStr)
    oModel:setprimarykey({"Z04_FILIAL", "Z04_CODC"})
    oModel:setdescription("Cadastro de produtos em cestas")
    oModel:getmodel("Z04Master"):setdescription("Cadastro de produtos em cestas")
return oModel
