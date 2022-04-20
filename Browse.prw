#include "protheus.ch"
#include "fwmvcdef.ch"

user function browse()
    
    local oDlg as object
    local aArea as array
    private aRot as array

    aRot := menudef()

    dbselectarea("Z00")
    aArea := Z00->(getarea())
    
    oDlg := fwmbrowse():new()
    oDlg:setalias("Z00")
    oDlg:setdescription("Clientes")
    oDlg:setmenudef("browse")
    oDlg:activate()
    
    Z00->(restarea(aArea))
    Z00->(dbclosearea())

return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    //add option aRotinas title 'Pesquisar' action  operation 1 access 0
    //add option aRotinas title 'Visualizar' action  operation 2 access 0
    add option aRotinas title 'Incluir' action 'u_cadastro()' operation 3 access 0
    //add option aRotinas title 'Alterar' action  operation 4 access 0
    //add option aRotinas title 'Excluir' action  operation 5 access 0
    //add option aRotinas title 'Imprimir' action  operation 8 access 0
    //add option aRotinas title 'Copiar' action  operation 9 access 0
return aRotinas
