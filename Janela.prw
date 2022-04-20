#include "protheus.ch"

User Function Janela()

    Local oDlg As Object
    Local oBut As Object
    Local oTget As Object
    Local cTxt As Character

    cTxt := Space(50)
    oDlg := MSDialog():New(100, 100, 580, 740, "Janela de Teste",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,,.F.)
    oBut := TButton():New(120, 160, "Botão", oDlg, {||Fechar(oDlg)}, 40, 10,,,.T.,.T.,.F.,,.F.,,,.F.)
    oTget := TGet():New(100, 160, {|u| if(Pcount()>0, cTxt := u, cTxt)}, oDlg, 50, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,cTxt,,,,.F.,.T.,,"Digite algo:",2,,1,,.T.,.T.)
    oTget := TGet():New(80, 160, {|u| if(Pcount()>0, cTxt := u, cTxt)}, oDlg, 50, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"var",,,,.F.,.T.,,"Digite algo:",2,,1,,.T.,.T.)
    oDlg:Activate(,,, .T.,,,,,)

return NIL

Static Function Fechar(oDlg As Object)
    if MsgNoYes("Deseja fechar a janela?", "Atenção")
        oDlg:End()
    endif
Return NIL
