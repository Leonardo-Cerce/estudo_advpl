// Programa semelhante a 'browse.prw', mas que tamb�m permite altera��o e exclus�o de registros.
// Executa uma fun��o gen�rica inicialmente para determinar qual a opera��o.

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function telat1() // fun��o principal
    local aArea as array
    private aRot as array // vari�veis

    aRot := menudef() // defini��o do menu de op��es

    dbselectarea("Z00")
    Z00->(dbsetorder(1)) // carrega a tabela, define a ordena��o e salva o cursor
    aArea := Z00->(getarea())
    
    oDlg := fwmbrowse():new() // cria um browse
    oDlg:setalias("Z00") // define a tabela do browse
    oDlg:setdescription("Clientes") // define a descri��o do browse
    oDlg:setmenudef("telat1") // define o menu utilizado
    oDlg:activate() // ativa o browse
    
    Z00->(restarea(aArea))
    Z00->(dbclosearea()) // restaura o cursor e fecha o browse
return nil

static function menudef() as array // defini��o do menu de bot�es
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title 'Pesquisar' action '' operation 1 access 0
    add option aRotinas title 'Visualizar' action '' operation 2 access 0
    add option aRotinas title 'Incluir' action 'u_telaini' operation 3 access 0 // fun��o gen�rica para definir a opera��o
    add option aRotinas title 'Alterar' action 'u_telaini' operation 4 access 0
    add option aRotinas title 'Excluir' action 'u_del_reg' operation 5 access 0 // fun��o que deleta o registro atual
return aRotinas

static function conf(oDlg as object) // fun��o que realiza as verifica��es de validade e exist�ncia de um CPF no BD
    oDlg:end()
    
    if !(cgc(cCPF)) // se o CPF � inv�lido, retorna o c�digo de erro e interrompe
        nRes := -1
        return nil
    endif

    if Z00->(dbseek(xfilial("Z00")+alltrim(cCPF))) // se o CPF j� existe no BD, retorna que ser� altera��o
        nRes := 4
        return nil
    endif

    nRes := 3 // se o CPF � v�lido e n�o existe no BD, retorna que ser� inclus�o
return nil

static function bOk(oDlg as object, lOk as logical) // fun��o que inclui / altera um registro
    local nErr as numeric
    local lIns as logical // vari�veis
    local aMsg as array

    aMsg := {"Email invalido.", "Dados incluidos / alterados com sucesso."} // inicializa��o das vari�veis
    lIns := .T.
    oDlg:end() // fecha a janela principal

    if !(isemail(M->Z00_EMIL)) // verifica se o email � v�lido
        nErr := 1
        lIns := .F. // se n�o �, define que n�o ser� inserido / modificado
    endif

    if lIns // se for para inserir / modificar
        reclock("Z00", lOk) // se inser��o, cria novo registro, e se modifica��o, aloca o atual para alterar
        Z00->Z00_FILIAL := xfilial("Z00")
        Z00->Z00_NOME := M->Z00_NOME
        Z00->Z00_ENDR := M->Z00_ENDR
        Z00->Z00_EMIL := M->Z00_EMIL
        Z00->Z00_DTNASC := M->Z00_DTNASC
        Z00->Z00_CPF := M->Z00_CPF
        Z00->Z00_RG := M->Z00_RG
        Z00->Z00_NCEL := M->Z00_NCEL // salva os dados que est�o em mem�ria
        Z00->(msunlock()) // desbloqueia / salva o registro
        nErr := 2
    endif
msgalert(aMsg[nErr], "ALERTA") // imprime a mensagem correspondente
return nil

static function inc_edt(cAlias, nReg, nOpc)
    local oDlg as object
    local oMsmget as object
    local oEncbar as object
    local aPos as array
    local aTitle as array // vari�veis
    private aTela[0][0]
    private aGets[0]

    aPos := {30, 0, 400, 800}
    aTitle := {"INCLUIR", "ALTERAR"} // inicializa��o das vari�veis

    oDlg := msdialog():new(0, 0, 300, 300, aTitle[nRes-2],,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,, .F.) // janela principal
    oDlg:lmaximized := .T.

    regtomemory("Z00", if(nRes==3, .T., .F.)) // se inclus�o, cria vari�veis de mem�ria vazias; se altera��o, carrega da mem�ria os valores atuais

    if nRes == 3
        M->Z00_CPF := alltrim(cCPF) // se inclus�o, trata a string do CPF inserido
    endif

    // cria��o de uma barra de bot�es e das caixas de texto de inser��o/altera��o de dados
    oEncbar := enchoicebar(oDlg, {||iif(!obrigatorio(aGets, aTela), msgalert("Os campos obrigatorios nao foram preenchidos!", "ALERTA"), bOk(oDlg, if(nRes==3, .T., .F.)))}, {||oDlg:end()})
    oMsmget := msmget():new(cAlias,, nRes,,,,, aPos, {"Z00_NOME", "Z00_ENDR", "Z00_DTNASC", "Z00_RG", "Z00_EMIL", "Z00_NCEL"},,,,, oDlg,, if(nRes==3, .F., .T.),,,,,,,,,,)
    oDlg:activate(,,, .T.,,,,,) // ativa a janela principal
    Z00->(dbgotop()) // move o cursor para cima
return nil

user function telaini(cAlias, nReg, nOpc) // fun��o que determina a opera��o a ser realizada
    local oDlg as object
    local oTget as object
    local oBot as object
    private cCPF as character // vari�veis
    private nRes as numeric

    cCPF := space(11)
    
    oDlg := msdialog():new(0, 0, 300, 300, "INFORME O CPF",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,, .F.) // janela principal
    oDlg:lmaximized := .T.

    // caixa de texto para obter o CPF e bot�es para confirmar e cancelar a opera��o
    oTget := tget():new(5, 5, {|u| if(pcount()>0, cCPF := u, cCPF)}, oDlg, 50, 20, "@R 999.999.999-99",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cCPF",,,,.F.,.T.,,"CPF:",2,,1,,.T.,.T.)
    oBot := tbutton():new(5, 75, "CONFIRMAR", oDlg, {||conf(oDlg)}, 40, 20,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(5, 120, "CANCELAR", oDlg, {||oDlg:end(), nRes := -2}, 40, 20,,,.T.,.T.,.F.,,.F.,,,.F.)
    oDlg:activate(,,, .T.,,,,,) // ativa a janela principal

    if(nRes == -1)
        msgalert("CPF invalido.", "ALERTA") // se CPF � inv�lido, retorna essa mensagem e interrompe
        Z00->(dbgotop())
        return nil
    endif

    if(nRes == -2) // se a opera��o foi cancelada, somente interrompe
        Z00->(dbgotop())
        return nil
    endif

    inc_edt(cAlias, nReg, nOpc) // chama a fun��o de inclus�o / edi��o
return nil

user function del_reg(cAlias, nReg, nOpc) // fun��o que deleta o registro atual
    if msgnoyes("Deseja excluir o registro?", "ALERTA")
        reclock(cAlias, .F.)
        Z00->(dbdelete())
        Z00->(msunlock())
    endif
    Z00->(dbgotop())
return nil
