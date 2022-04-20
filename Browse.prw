// Programa que exibe os clientes adicionados através de um browse.
// Permite adicionar clientes ao executar a função de cadastro de 'cadastro.prw'.

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function browse() // função principal
    
    local oDlg as object
    local aArea as array // variáveis locais
    private aRot as array // variável que contém as rotinas do programa, a fim de exibir os botões correspondentes

    aRot := menudef() // menu com os botões

    dbselectarea("Z00")
    aArea := Z00->(getarea()) // seleciona a tabela e salva o cursor
    
    oDlg := fwmbrowse():new() // cria um browse
    oDlg:setalias("Z00") // seleciona a tabela que será usada
    oDlg:setdescription("Clientes") // define a descrição do browse
    oDlg:setmenudef("browse") // define o menu de botões usado
    oDlg:activate() // ativa o browse
    
    Z00->(restarea(aArea))
    Z00->(dbclosearea()) // restaura o cursor e fecha a tabela

return nil

static function menudef() as array // definição do menu de botões e a ação de cada um destes
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
