#include "protheus.ch"
#include "fwmvcdef.ch"

user function MVC00()
    local aArea as array
    local oFwmbr as object

    dbselectarea("Z00")
    Z00->(dbsetorder(1))
    aArea := Z00->(getarea())

    oFwmbr := fwmbrowse():new()
    oFwmbr:setalias("Z00")
    oFwmbr:setdescription("Cadastro de clientes")
    oFwmbr:disabledetails()
    oFwmbr:setonlyfields({"Z00_CPF", "Z00_RG", "Z00_EMIL", "Z00_NOME", "Z00_NCEL", "Z00_DTNASC"})
    oFwmbr:setmenudef("MVC00")
    oFwmbr:activate()

    Z00->(restarea(aArea))
    Z00->(dbclosearea())
return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC00" operation 1 access 0
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC00" operation 2 access 0
    add option aRotinas title "Incluir" action "VIEWDEF.MVC00" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC00" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC00" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC00" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC00" operation 9 access 0
return aRotinas

static function viewdef() as object
    local oModel as object
    local oStr1 as object
    local oStr2 as object
    local oView as object

    oModel := fwloadmodel("MVC00")

    oStr1 := fwformstruct(2, "Z00")
    oStr2 := fwformstruct(2, "Z01")
    
    oStr1:removefield("Z00_ENDR")
    oStr2:removefield("Z01_CPF")
    oStr2:setproperty("Z01_TIPO", MVC_VIEW_COMBOBOX, {"RES", "COM"})

    oView := fwformview():new()
    oView:setmodel(oModel)

    oView:addfield("ViewZ00", oStr1, "Z00Master")
    oView:addgrid("ViewZ01", oStr2, "Z01Detail")

    oView:createhorizontalbox("Superior", 60)
    oView:createhorizontalbox("Inferior", 40)
    
    oView:setownerview("ViewZ00", "Superior")
    oView:setownerview("ViewZ01", "Inferior")

    oView:enabletitleview("ViewZ00", "Cliente")
    oView:enabletitleview("ViewZ01", "Endereços")
return oView

static function modeldef() as object
    local oModel as object
    local oStr1 as object
    local oStr2 as object
    
    oStr1 := fwformstruct(1, "Z00")
    oStr2 := fwformstruct(1, "Z01")
    
    oStr1:removefield("Z00_ENDR")
    oStr1:setproperty("Z00_CPF", MODEL_FIELD_NOUPD, .T.)
    oStr2:setproperty("Z01_TIPO", MODEL_FIELD_VALUES, {"RES", "COM"})

    oModel := mpformmodel():new("MVC00M",, {|oModel| u_pos_val(oModel)})

    oModel:addfields("Z00Master",, oStr1)
    oModel:addgrid("Z01Detail", "Z00Master", oStr2)
    oModel:setprimarykey({"Z00_FILIAL", "Z00_CPF"})

    oModel:setrelation("Z01Detail", {{"Z01_FILIAL", 'xFilial("Z00")'}, {"Z01_CPF", "Z00_CPF"}}, Z01->(indexkey(1)))

    oModel:setdescription("Dados de cadastro do cliente")
    oModel:getmodel("Z00Master"):setdescription("Dados de cadastro do cliente")
    oModel:getmodel("Z01Detail"):setdescription("Informações do(s) endereço(s) do cliente")
    oModel:getmodel("Z01Detail"):setoptional(.T.)
return oModel

user function pos_val(oModel as object) as logical
    local lIns as logical
    local cCPF as character
    local cEmil as character
    local cTipo as character
    local cEndr as character
    local cData as character
    local dData as date
    local nI as numeric
    local oModel2 as object

    lIns := .T.

    cCPF := oModel:getvalue("Z00Master", "Z00_CPF")
    cEmil := oModel:getvalue("Z00Master", "Z00_EMIL")
    cData := oModel:getvalue("Z00Master", "Z00_DTNASC")

    if !cgc(alltrim(cCPF))
        lIns := .F.
    endif

    if !isemail(alltrim(cEmil))
        lIns := .F.
    endif

    dData := ctod(cData)

    if (dData<ctod("01/01/1900") .or. dData>date())
        lIns := .F.
    endif

    oModel2 := oModel:getmodel("Z01Detail")

    for nI := 1 to len(oModel2:alineschanged)
        oModel2:goline(oModel2:alineschanged[nI])
        if !oModel2:isdeleted()
            cTipo := alltrim(oModel2:getvalue("Z01_TIPO"))
            cEndr := alltrim(oModel2:getvalue("Z01_ENDR"))
            if((cTipo!="" .and. cEndr=="") .or. (cTipo=="" .and. cEndr!=""))
                lIns := .F.
            endif
        endif
    next nI
return lIns
