// Programa simples que abre uma janela e permite a inser��o de texto
// Primeiro programa escrito na linguagem AdvPL

#include "protheus.ch" // includes

User Function Janela() // programa principal

    Local oDlg As Object
    Local oBut As Object
    Local oTget As Object
    Local cTxt As Character // vari�veis locais

    cTxt := Space(50) // inicializa��o da vari�vel

    oDlg := MSDialog():New(100, 100, 580, 740, "Janela de Teste",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,,.F.) // janela principal
    
    oBut := TButton():New(120, 160, "Bot�o", oDlg, {||Fechar(oDlg)}, 40, 10,,,.T.,.T.,.F.,,.F.,,,.F.) // bot�o para fechar a janela

    // caixas de texto
    oTget := TGet():New(100, 160, {|u| if(Pcount()>0, cTxt := u, cTxt)}, oDlg, 50, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,cTxt,,,,.F.,.T.,,"Digite algo:",2,,1,,.T.,.T.)
    oTget := TGet():New(80, 160, {|u| if(Pcount()>0, cTxt := u, cTxt)}, oDlg, 50, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"var",,,,.F.,.T.,,"Digite algo:",2,,1,,.T.,.T.)
    
    oDlg:Activate(,,, .T.,,,,,) // ativa��o da janela principal
return NIL

// fun��o executada ao clicar no bot�o de "Fechar"
Static Function Fechar(oDlg As Object)
    if MsgNoYes("Deseja fechar a janela?", "Aten��o")
        oDlg:End() // se sim, fecha a janela principal
    endif
Return NIL
