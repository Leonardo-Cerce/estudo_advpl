// Programa simples de cadastro de produtos usando o modelo MVC

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function MVC01()
    local aArea as array
    local oFwmbr as object // vari�veis

    dbselectarea("Z02")
    Z02->(dbsetorder(1))
    aArea := Z02->(getarea()) // abre a tabela, define a ordena��o e salva o cursor

    oFwmbr := fwmbrowse():new() // cria o browse
    oFwmbr:setalias("Z02") // define a tabela do browse
    oFwmbr:setdescription("Cadastro de produtos") // define a descri��o do browse
    oFwmbr:disabledetails() // desabilita a aba de detalhes do browse
    oFwmbr:setmenudef("MVC01") // define o menu de bot�es usados no browse
    oFwmbr:activate() // ativa o browse

    Z02->(restarea(aArea))
    Z02->(dbclosearea()) // restaura o cursor e fecha a tabela
return nil

static function menudef() as array // define o menu de bot�es e as a��es de cada um deles
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC01" operation 1 access 0 // a��es definidas pelo modeldef e pelo viewdef
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC01" operation 2 access 0
    add option aRotinas title "Incluir" action "VIEWDEF.MVC01" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC01" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC01" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC01" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC01" operation 9 access 0
return aRotinas

static function viewdef() as object // define o viewdef do MVC
    local oModel as object
    local oStr as object
    local oView as object // vari�veis

    oModel := fwloadmodel("MVC01") // carrega o model do arquivo 'mvc01'

    oStr := fwformstruct(2, "Z02") // cria a estrutura a partir dos dados da tabela

    oView := fwformview():new() // cria a view
    oView:setmodel(oModel) // define o modelo da view
    oView:addfield("ViewZ02", oStr, "Z02Master") // adiciona a estrutura na view
    oView:createhorizontalbox("Tela", 100) // cria uma caixa horizontal
    oView:setownerview("ViewZ02", "Tela") // define o dono da caixa criada
    oView:enabletitleview("ViewZ02", "Produtos") // habilita a visualiza��o
return oView

static function modeldef() as object // define o modeldef do MVC
    local oModel as object
    local oStr as object // vari�veis
    
    oStr := fwformstruct(1, "Z02") // cria a estrutura a partir dos dados da tabela
    
    oModel := mpformmodel():new("MVC01M") // cria o model
    oModel:addfields("Z02Master",, oStr) // adiciona a estrutura no model
    oModel:setprimarykey({"Z02_FILIAL", "Z02_COD"}) // define a chave prim�ria
    oModel:setdescription("Dados de cadastro de produtos") // define a descri��o do model geral
    oModel:getmodel("Z02Master"):setdescription("Dados de cadastro de produtos") // define a descri��o do model master
return oModel
