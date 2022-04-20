#include "protheus.ch"
#include "fwmvcdef.ch"

user function telat1()
    local aArea as array
    private aRot as array

    aRot := menudef()

    dbselectarea("Z00")
    Z00->(dbsetorder(1))
    aArea := Z00->(getarea())
    
    oDlg := fwmbrowse():new()
    oDlg:setalias("Z00")
    oDlg:setdescription("Clientes")
    oDlg:setmenudef("telat1")
    oDlg:activate()
    
    Z00->(restarea(aArea))
    Z00->(dbclosearea())
return nil

static function menudef() as array
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title 'Pesquisar' action '' operation 1 access 0
    add option aRotinas title 'Visualizar' action '' operation 2 access 0
    add option aRotinas title 'Incluir' action 'u_telaini' operation 3 access 0
    add option aRotinas title 'Alterar' action 'u_telaini' operation 4 access 0
    add option aRotinas title 'Excluir' action 'u_del_reg' operation 5 access 0
return aRotinas

static function conf(oDlg as object)
    oDlg:end()
    
    if !(cgc(cCPF))
        nRes := -1
        return nil
    endif

    if Z00->(dbseek(xfilial("Z00")+alltrim(cCPF)))
        nRes := 4
        return nil
    endif

    nRes := 3
return nil

static function bOk(oDlg as object, lOk as logical)
    local nErr as numeric
    local lIns as logical
    local aMsg as array

    aMsg := {"Email invalido.", "Dados incluidos / alterados com sucesso."}
    lIns := .T.
    oDlg:end()

    if !(isemail(M->Z00_EMIL))
        nErr := 1
        lIns := .F.
    endif

    if lIns
        reclock("Z00", lOk)
        Z00->Z00_FILIAL := xfilial("Z00")
        Z00->Z00_NOME := M->Z00_NOME
        Z00->Z00_ENDR := M->Z00_ENDR
        Z00->Z00_EMIL := M->Z00_EMIL
        Z00->Z00_DTNASC := M->Z00_DTNASC
        Z00->Z00_CPF := M->Z00_CPF
        Z00->Z00_RG := M->Z00_RG
        Z00->Z00_NCEL := M->Z00_NCEL
        Z00->(msunlock())
        nErr := 2
    endif
msgalert(aMsg[nErr], "ALERTA")
return nil

static function inc_edt(cAlias, nReg, nOpc)
    local oDlg as object
    local oMsmget as object
    local oEncbar as object
    local aPos as array
    local aTitle as array
    private aTela[0][0]
    private aGets[0]

    aPos := {30, 0, 400, 800}
    aTitle := {"INCLUIR", "ALTERAR"}

    oDlg := msdialog():new(0, 0, 300, 300, aTitle[nRes-2],,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,, .F.)
    oDlg:lmaximized := .T.

    regtomemory("Z00", if(nRes==3, .T., .F.))

    if nRes == 3
        M->Z00_CPF := alltrim(cCPF)
    endif

    oEncbar := enchoicebar(oDlg, {||iif(!obrigatorio(aGets, aTela), msgalert("Os campos obrigatorios nao foram preenchidos!", "ALERTA"), bOk(oDlg, if(nRes==3, .T., .F.)))}, {||oDlg:end()})
    oMsmget := msmget():new(cAlias,, nRes,,,,, aPos, {"Z00_NOME", "Z00_ENDR", "Z00_DTNASC", "Z00_RG", "Z00_EMIL", "Z00_NCEL"},,,,, oDlg,, if(nRes==3, .F., .T.),,,,,,,,,,)
    oDlg:activate(,,, .T.,,,,,)
    Z00->(dbgotop())
return nil

user function telaini(cAlias, nReg, nOpc)
    local oDlg as object
    local oTget as object
    local oBot as object
    private cCPF as character
    private nRes as numeric

    cCPF := space(11)
    
    oDlg := msdialog():new(0, 0, 300, 300, "INFORME O CPF",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,, .F.)
    oDlg:lmaximized := .T.

    oTget := tget():new(5, 5, {|u| if(pcount()>0, cCPF := u, cCPF)}, oDlg, 50, 20, "@R 999.999.999-99",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cCPF",,,,.F.,.T.,,"CPF:",2,,1,,.T.,.T.)
    oBot := tbutton():new(5, 75, "CONFIRMAR", oDlg, {||conf(oDlg)}, 40, 20,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(5, 120, "CANCELAR", oDlg, {||oDlg:end(), nRes := -2}, 40, 20,,,.T.,.T.,.F.,,.F.,,,.F.)
    oDlg:activate(,,, .T.,,,,,)

    if(nRes == -1)
        msgalert("CPF invalido.", "ALERTA")
        Z00->(dbgotop())
        return nil
    endif

    if(nRes == -2)
        Z00->(dbgotop())
        return nil
    endif

    inc_edt(cAlias, nReg, nOpc)
return nil

user function del_reg(cAlias, nReg, nOpc)
    if msgnoyes("Deseja excluir o registro?", "ALERTA")
        reclock(cAlias, .F.)
        Z00->(dbdelete())
        Z00->(msunlock())
    endif
    Z00->(dbgotop())
return nil
