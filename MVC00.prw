// Programa simples de cadastro de pessoas físicas utilizando o modelo MVC
// Primeiro programa utilizando MVC

#include "protheus.ch"
#include "fwmvcdef.ch" // includes

user function MVC00() // função principal
    local aArea as array
    local oFwmbr as object // variáveis

    dbselectarea("Z00")
    Z00->(dbsetorder(1))
    aArea := Z00->(getarea()) // carrega a tabela, define a ordenação e salva o cursor

    oFwmbr := fwmbrowse():new() // cria um browse
    oFwmbr:setalias("Z00") // define a tabela do browse
    oFwmbr:setdescription("Cadastro de clientes") // define a descrição do browse
    oFwmbr:disabledetails() // desabilita a aba de detalhes
    oFwmbr:setonlyfields({"Z00_CPF", "Z00_RG", "Z00_EMIL", "Z00_NOME", "Z00_NCEL", "Z00_DTNASC"}) // define quais campos serão exibidos
    oFwmbr:setmenudef("MVC00") // define o menu de botões a ser utilizado
    oFwmbr:activate() // ativa o browse

    Z00->(restarea(aArea))
    Z00->(dbclosearea()) // restaura o cursor e fecha a tabela
return nil

static function menudef() as array // função que define o menu de botões
    local aRotinas as array
    aRotinas := {}
    add option aRotinas title "Pesquisar" action "VIEWDEF.MVC00" operation 1 access 0 // as operações são criadas automaticamente
    add option aRotinas title "Visualizar" action "VIEWDEF.MVC00" operation 2 access 0 // a partir das relações definidas no viewdef e no modeldef
    add option aRotinas title "Incluir" action "VIEWDEF.MVC00" operation 3 access 0
    add option aRotinas title "Alterar" action "VIEWDEF.MVC00" operation 4 access 0
    add option aRotinas title "Excluir" action "VIEWDEF.MVC00" operation 5 access 0
    add option aRotinas title "Imprimir" action "VIEWDEF.MVC00" operation 8 access 0
    add option aRotinas title "Copiar" action "VIEWDEF.MVC00" operation 9 access 0
return aRotinas

static function viewdef() as object // definição do view do MVC
    local oModel as object
    local oStr1 as object
    local oStr2 as object
    local oView as object // variáveis

    oModel := fwloadmodel("MVC00") // carrega o model que foi definido neste arquivo

    oStr1 := fwformstruct(2, "Z00")
    oStr2 := fwformstruct(2, "Z01") // cria estruturas a partir das informações das tabelas
    
    oStr1:removefield("Z00_ENDR")
    oStr2:removefield("Z01_CPF") // remove alguns campos para melhorar a visualização
    oStr2:setproperty("Z01_TIPO", MVC_VIEW_COMBOBOX, {"RES", "COM"}) // cria uma caixa de opções com possíveis valores

    oView := fwformview():new() // cria a view e define o modelo usado
    oView:setmodel(oModel)

    oView:addfield("ViewZ00", oStr1, "Z00Master") // define a view como master/detail
    oView:addgrid("ViewZ01", oStr2, "Z01Detail")

    oView:createhorizontalbox("Superior", 60) // cria caixas para cada view
    oView:createhorizontalbox("Inferior", 40)
    
    oView:setownerview("ViewZ00", "Superior") // define os "donos" de cada caixa criada
    oView:setownerview("ViewZ01", "Inferior")

    oView:enabletitleview("ViewZ00", "Cliente") // habilita a visualização
    oView:enabletitleview("ViewZ01", "Endereços")
return oView

static function modeldef() as object // definição do model do MVC
    local oModel as object
    local oStr1 as object
    local oStr2 as object // variáveis
    
    oStr1 := fwformstruct(1, "Z00")
    oStr2 := fwformstruct(1, "Z01") // cria estruturas a partir das informações das tabelas
    
    oStr1:removefield("Z00_ENDR") // remove o campo do model
    oStr1:setproperty("Z00_CPF", MODEL_FIELD_NOUPD, .T.) // não permite que o campo seja modificado
    oStr2:setproperty("Z01_TIPO", MODEL_FIELD_VALUES, {"RES", "COM"}) // define os valores permitidos para o campo

    oModel := mpformmodel():new("MVC00M",, {|oModel| u_pos_val(oModel)}) // cria o model, e define uma função de pós-validação

    oModel:addfields("Z00Master",, oStr1)
    oModel:addgrid("Z01Detail", "Z00Master", oStr2) // define o model como master/detail
    oModel:setprimarykey({"Z00_FILIAL", "Z00_CPF"}) // define a chave primária

    // define a relação entre o master e o detail
    oModel:setrelation("Z01Detail", {{"Z01_FILIAL", 'xFilial("Z00")'}, {"Z01_CPF", "Z00_CPF"}}, Z01->(indexkey(1)))

    oModel:setdescription("Dados de cadastro do cliente") // define a descrição geral do modelo
    oModel:getmodel("Z00Master"):setdescription("Dados de cadastro do cliente") // define a descrição do master
    oModel:getmodel("Z01Detail"):setdescription("Informações do(s) endereço(s) do cliente") // define a descrição do detail
    oModel:getmodel("Z01Detail"):setoptional(.T.) // define que os endereços são opcionais
return oModel

user function pos_val(oModel as object) as logical // função de pós-validação
    local lIns as logical
    local cCPF as character
    local cEmil as character
    local cTipo as character
    local cEndr as character
    local cData as character
    local dData as date
    local nI as numeric
    local oModel2 as object // variáveis

    lIns := .T. // é para inserir

    cCPF := oModel:getvalue("Z00Master", "Z00_CPF")
    cEmil := oModel:getvalue("Z00Master", "Z00_EMIL")
    cData := oModel:getvalue("Z00Master", "Z00_DTNASC") // obtém os valores do model

    if !cgc(alltrim(cCPF))
        lIns := .F. // valida o CPF, e se não for válido, não insere
    endif

    if !isemail(alltrim(cEmil))
        lIns := .F. // valida o email, e se não for válido, não insere
    endif

    dData := ctod(cData)

    if (dData<ctod("01/01/1900") .or. dData>date()) // valida a data de nascimento, e se não for válida, não insere
        lIns := .F.
    endif

    oModel2 := oModel:getmodel("Z01Detail") // obtém o modelo de detail

    for nI := 1 to len(oModel2:alineschanged) // para cada linha modificada
        oModel2:goline(oModel2:alineschanged[nI])
        if !oModel2:isdeleted() // se não foi deletada
            cTipo := alltrim(oModel2:getvalue("Z01_TIPO"))
            cEndr := alltrim(oModel2:getvalue("Z01_ENDR"))
            if((cTipo!="" .and. cEndr=="") .or. (cTipo=="" .and. cEndr!=""))
                lIns := .F. // verifica os valores, e se algum estiver vazio, não insere
            endif
        endif
    next nI
return lIns
