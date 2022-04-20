#include "protheus.ch"

user function menu()

    local oDlg as object
    local oBot as object

    oDlg := msdialog():new(0, 0, 220, 175, "MENU",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,,.F.)

    oBot := tbutton():new(5, 5, "REALIZAR CADASTRO", oDlg, {||u_cadastro()}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(40, 5, "CONSULTAR CADASTRO", oDlg, {||msgalert("Consulta cadastro", "Consulta")}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)
    oBot := tbutton():new(40, 5, "SAIR", oDlg, {||oDlg:end()}, 80, 30,,,.T.,.T.,.F.,,.F.,,,.F.)

    oDlg:activate(,,, .T.,,,,,)

return nil
