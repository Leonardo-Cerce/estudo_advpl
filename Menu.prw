// Programa simples que cria uma janela de menu para o programa 'cadastro.prw'
// O objetivo era fazer um hub de todos os programas.

#include "protheus.ch" // includes

user function menu() // função principal
    local oDlg as object
    local oBot as object // variáveis locais

    oDlg := msdialog():new(0, 0, 220, 175, "MENU",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,,.F.) // janela principal

    // botões para as funções de cadastro, consulta e para sair
    oBot := tbutton():new(5, 5, "REALIZAR CADASTRO", oDlg, {||u_cadastro()}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(40, 5, "CONSULTAR CADASTRO", oDlg, {||msgalert("Consulta cadastro", "Consulta")}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(40, 5, "SAIR", oDlg, {||oDlg:end()}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)

    oDlg:activate(,,, .T.,,,,,) // ativa a janela principal
return nil
