// Programa que exibe os clientes adicionados atrav�s de um browse.
// Permite adicionar clientes ao executar a fun��o de cadastro de 'cadastro.prw'.

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function browse() // fun��o principal
    
    local oDlg as object
    local aArea as array // vari�veis locais
    private aRot as array // vari�vel que cont�m as rotinas do programa, a fim de exibir os bot�es correspondentes

    aRot := menudef() // menu com os bot�es

    dbselectarea("Z00")
    aArea := Z00->(getarea()) // seleciona a tabela e salva o cursor
    
    oDlg := fwmbrowse():new() // cria um browse
    oDlg:setalias("Z00") // seleciona a tabela que ser� usada
    oDlg:setdescription("Clientes") // define a descri��o do browse
    oDlg:setmenudef("browse") // define o menu de bot�es usado
    oDlg:activate() // ativa o browse
    
    Z00->(restarea(aArea))
    Z00->(dbclosearea()) // restaura o cursor e fecha a tabela

return nil

static function menudef() as array // defini��o do menu de bot�es e a a��o de cada um destes
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
