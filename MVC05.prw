// Programa que simula uma interface de montagem de cestas básicas.
// No browse da direita estão os produtos, no da esquerda superior, as cestas, e no da esquerda central, os produtos em determinada cesta.
// Na esquerda inferior, mostra-se o valor total dos produtos da cesta selecionada.
// É possível clicar duas vezes sobre um produto para adicioná-lo em uma cesta, e clicar duas vezes nos produtos da cesta para removê-los.
// Ao adicionar ou remover um produto da cesta, o estoque deste produto é atualizado de forma correspondente.

#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include "prconst.ch" // includes

user function MVC05() // função principal
    local aCoor as array
    local oDlgPrinc as object
    local oLayer1 as object
    local oLayer2 as object
    local oPanelL as object
    local oPanelR as object
    local oPanelEsq as object
    local oPanelDTp as object
    local oPanelDMd as object
    local oPanelDBx as object
    local cQuery as character
    local aAux as array
    local lUpdt as logical
    private aBrowseP as array
    private aBrowseC as array
    private aBrowseCP as array
    private aBrowseCPA as array
    private oBrowseP as object
    private oBrowseC as object
    private oBrowseCP as object
    private oTget as object
    private nTotal as numeric
    private lRun as logical // variáveis

    lRun := .F.
    lUpdt := .T.
    nTotal := 0
    aCoor := fwgetdialogsize(oMainWnd) // inicialização de variáveis

    oDlgPrinc := msdialog():new(aCoor[2], aCoor[1], aCoor[3], aCoor[4], "Interface de Compras",,,,,,,,, .T.,,,) // janela principal

    oPanelL := tpanel():new(,,, oDlgPrinc,,,,,, aCoor[4]/4, aCoor[3]/2) // painel da esquerda da janela principal
    oPanelL:align := CONTROL_ALIGN_LEFT

    oPanelR := tpanel():new(,,, oDlgPrinc,,,,,, aCoor[4]/4, aCoor[3]/2) // painel da direita da janela principal
    oPanelR:align := CONTROL_ALIGN_LEFT

    oLayer1 := fwlayer():new()
    oLayer1:init(oPanelL, .F.)
    oLayer1:addcollumn("Esq", 100)
    oLayer1:addwindow("Esq", "WinEsq", "Produtos", 97, .F., .T.) // primeiro layer, relacionado ao painel da esquerda, não dividido
    
    oLayer2 := fwlayer():new()
    oLayer2:init(oPanelR, .F.)
    oLayer2:addline("L1", 42)
    oLayer2:addline("L2", 42)
    oLayer2:addline("L3", 16)
    oLayer2:addcollumn("Topo", 100,, "L1")
    oLayer2:addcollumn("Meio", 100,, "L2")
    oLayer2:addcollumn("Fim", 100,, "L3")
    oLayer2:addwindow("Topo", "WinTp", "Cestas", 100, .F., .T.,, "L1")
    oLayer2:addwindow("Meio", "WinMd", "Produtos na cesta", 100, .F., .T.,, "L2")
    oLayer2:addwindow("Fim", "WinBx", "Valor total", 80, .F., .T.,, "L3") // segundo layer, relacionado ao painel da direita, dividido em três linhas

    oPanelEsq := oLayer1:getwinpanel("Esq", "WinEsq")
    oPanelDTp := oLayer2:getwinpanel("Topo", "WinTp", "L1")
    oPanelDMd := oLayer2:getwinpanel("Meio", "WinMd", "L2")
    oPanelDBx := oLayer2:getwinpanel("Fim", "WinBx", "L3") // obtenção dos panels dos layers

    // criação dos browses e ações correspondentes a troca de linha no de cesta, e de clique duplo no de produtos e de produtos em cestas
    oBrowseP :=  tcbrowse():new(,, aCoor[4]/4, aCoor[3]/2,,,, oPanelEsq,,,, /*bChange*/, {|| DBClickP()}, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)
    oBrowseC :=  tcbrowse():new(,, aCoor[4]/4, aCoor[3]/5,,,, oPanelDTp,,,, {|| BChange()}, /*bDouble*/, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)
    oBrowseCP := tcbrowse():new(,, aCoor[4]/4, aCoor[3]/5,,,, oPanelDMd,,,, /*bChange*/, {|| DBClickCP()}, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)

    if select("Cesta") != 0
        dbselectarea("Cesta") // se a query estiver aberta, é fechada para evitar erros
        Cesta->(dbclosearea())
    endif

    cQuery := "SELECT * FROM Z03990 WHERE D_E_L_E_T_=' '" // faz uma query na tabela de cestas e a abre
    tcquery cQuery new alias Cesta
    dbselectarea("Cesta")

    Cesta->(dbgotop()) // percorre a tabela de cestas, fazendo um vetor de vetores com os valores encontrados
    aBrowseC := {}
    while !Cesta->(eof())
        aAux := {}
        aadd(aAux, Cesta->Z03_FILIAL)
        aadd(aAux, Cesta->Z03_COD)
        aadd(aAux, Cesta->Z03_DESC)
        aadd(aBrowseC, aAux)
        Cesta->(dbskip())
    enddo

    Cesta->(dbclosearea()) // query é finalizada

    oBrowseC:addcolumn(tccolumn():new("Filial", {||aBrowseC[oBrowseC:nAt, 1]}))
    oBrowseC:addcolumn(tccolumn():new("Código", {||aBrowseC[oBrowseC:nAt, 2]}))
    oBrowseC:addcolumn(tccolumn():new("Descrição", {||aBrowseC[oBrowseC:nAt, 3]}))
    oBrowseC:setarray(aBrowseC) // criam-se colunas no browse, e seleciona-se qual informação ficará em cada uma, e define-se o array de dados

    if select("Prod") != 0
        dbselectarea("Prod")
        Prod->(dbclosearea())
    endif

    cQuery := "SELECT * FROM Z02990 WHERE D_E_L_E_T_=' '" // o mesmo procedimento é repetido para a tabela de produtos
    tcquery cQuery new alias Prod
    dbselectarea("Prod")

    Prod->(dbgotop())
    aBrowseP := {}
    while !Prod->(eof())
        aAux := {}
        aadd(aAux, Prod->Z02_FILIAL)
        aadd(aAux, Prod->Z02_COD)
        aadd(aAux, Prod->Z02_DESC)
        aadd(aAux, Prod->Z02_EST)
        aadd(aAux, Prod->Z02_PR)
        aadd(aBrowseP, aAux)
        Prod->(dbskip())
    enddo

    Prod->(dbclosearea()) // query é finalizada

    oBrowseP:addcolumn(tccolumn():new("Filial", {||aBrowseP[oBrowseP:nAt, 1]}))
    oBrowseP:addcolumn(tccolumn():new("Código", {||aBrowseP[oBrowseP:nAt, 2]}))
    oBrowseP:addcolumn(tccolumn():new("Descrição", {||aBrowseP[oBrowseP:nAt, 3]}))
    oBrowseP:addcolumn(tccolumn():new("Estoque", {||aBrowseP[oBrowseP:nAt, 4]}))
    oBrowseP:addcolumn(tccolumn():new("Preço", {||transform(aBrowseP[oBrowseP:nAt, 5], "@E 99.99")}))
    oBrowseP:setarray(aBrowseP)

    cQuery := "SELECT * FROM Z04990 WHERE D_E_L_E_T_=' '" // o mesmo procedimento é realizado para a tabela de produtos em cestas
    tcquery cQuery new alias PemC
    dbselectarea("PemC")

    PemC->(dbgotop())
    aBrowseCP := {}
    while !PemC->(eof())
        aAux := {}
        aadd(aAux, PemC->Z04_FILIAL)
        aadd(aAux, PemC->Z04_CODC)
        aadd(aAux, PemC->Z04_CODP)
        aadd(aAux, PemC->Z04_PDESC)
        aadd(aAux, PemC->Z04_QUANT)
        aadd(aAux, PemC->Z04_TOTAL)
        aadd(aBrowseCP, aAux)
        PemC->(dbskip())
    enddo

    PemC->(dbclosearea()) // query é finalizada

    if len(aBrowseCP) == 0
        aAux := {"", "", "", "", NIL, NIL} // se não houver produtos em cestas, adiciona-se uma string "vazia"
        aadd(aBrowseCP, aAux)
        lUpdt := .F.
    endif
    
    oBrowseCP:addcolumn(tccolumn():new("Filial", {||aBrowseCP[oBrowseCP:nAt, 1]}))
    oBrowseCP:addcolumn(tccolumn():new("Código Cesta", {||aBrowseCP[oBrowseCP:nAt, 2]}))
    oBrowseCP:addcolumn(tccolumn():new("Código Produto", {||aBrowseCP[oBrowseCP:nAt, 3]}))
    oBrowseCP:addcolumn(tccolumn():new("Descrição Produto", {||aBrowseCP[oBrowseCP:nAt, 4]}))
    oBrowseCP:addcolumn(tccolumn():new("Quantidade", {||aBrowseCP[oBrowseCP:nAt, 5]}))
    oBrowseCP:addcolumn(tccolumn():new("Preço", {||transform(aBrowseCP[oBrowseCP:nAt, 6], "@E 99.99")}))
    oBrowseCP:setarray(aBrowseCP)

    // caixa de texto que exibirá o valor total de cada cesta
    oTget := tget():new(,, {|| nTotal}, oPanelDBx, 30, 15, "@E 99.99",,,,,,,.T.,,,,,,,.T.,.F.,,/*"nTotal"*/,,,,.F.,.T.,,"Preço total da cesta:", 2,, 1,,,)

    aBrowseCPA := aclone(aBrowseCP) // clonar a lista de produtos em cesta para não perder dados

    if lUpdt // se houver produtos em cestas
        Updt_Brw(aBrowseC[oBrowseC:nat, 2]) // atualizar o browse para exibir somente produtos que estão na cesta selecionada
    endif

    oDlgPrinc:activate(,,, .T.) // ativar janela principal
return nil

static function DBClickP() // função executada ao clicar duas vezes em um produto da lista de produtos
    local aAux as array
    local nI as numeric
    local nJ as numeric
    local nAux as numeric
    local nAux2 as numeric
    local cCodc as character
    local cCodp as character // variáveis

    cCodc := alltrim(aBrowseC[oBrowseC:nat, 2]) // código da cesta atual
    cCodp := alltrim(aBrowseP[oBrowseP:nat, 2]) // código do produto atual

    dbselectarea("Z04")
    dbselectarea("Z02")
    Z04->(dbgotop()) // abrir a tabela de produtos em cestas
    Z02->(dbgotop()) // abrir a tabela de produtos

    nJ := 0

    while (alltrim(Z04->Z04_CODC) != cCodc .or. alltrim(Z04->Z04_CODP) != cCodp .or. Z04->(deleted())) .and. Z04->(lastrec()) > nJ
        Z04->(dbskip()) // posicionar o cursor em um produto de mesmo código e cesta
        nJ++ // se este produto não existir, nJ é inválido
    enddo

    while (alltrim(Z02->Z02_COD) != cCodp .or. Z02->(deleted())) // posicionar o cursor no produto selecionado
        Z02->(dbskip())
    enddo
    
    aBrowseCP := aclone(aBrowseCPA)
    nI = PesqCP(cCodc, cCodp) // procura o produto pela lista de produtos na cesta

    if nI // se encontrou
        nAux := aBrowseP[oBrowseP:nat, 4] // estoque atual

        if nAux > 0 // se o estoque for maior que zero, subtrai uma unidade; se não, avisa que o estoque é insuficiente
            nAux -= 1

            reclock("Z02", .F.)
            Z02->Z02_EST := nAux // salva o novo estoque de produto e fecha a tabela
            Z02->(msunlock())
            Z02->(dbclosearea())

            aBrowseP[oBrowseP:nat, 4] := nAux
        else
            msgalert("Estoque insuficiente", "Alerta")
            Z04->(dbclosearea())
            Z02->(dbclosearea()) // fecha as tabelas
            return nil
        endif

        nAux := aBrowseCP[nI, 5]
        nAux += 1
        aBrowseCP[nI, 5] := nAux // aumenta o número daquele tipo de produto da cesta correspondente em um

        reclock("Z04", .F.)
        Z04->Z04_QUANT := nAux // atualiza a quantidade no BD

        nAux2 := aBrowseP[oBrowseP:nat, 5]
        nAux2 := nAux2 * nAux
        aBrowseCP[nI, 6] := nAux2 // calcula e atualiza o preço total do registro

        Z04->Z04_TOTAL := nAux2 // atualiza o preço total do registro no BD
        
        Z04->(msunlock())
        Z04->(dbclosearea()) // libera o registro e fecha a tabela
    else // se não existe o produto na cesta
        nAux := aBrowseP[oBrowseP:nat, 4]

        if nAux > 0 // verifica o estoque
            nAux -= 1

            reclock("Z02", .F.)
            Z02->Z02_EST := nAux // salva o novo estoque de produto e fecha a tabela
            Z02->(msunlock())
            Z02->(dbclosearea())

            aBrowseP[oBrowseP:nat, 4] := nAux
        else
            msgalert("Estoque insuficiente", "Alerta")
            Z04->(dbclosearea())
            Z02->(dbclosearea()) // fecha as tabelas
            return nil
        endif

        aAux := {}
        aadd(aAux, aBrowseC[oBrowseC:nat, 1])
        aadd(aAux, aBrowseC[oBrowseC:nat, 2])
        aadd(aAux, aBrowseP[oBrowseP:nat, 2])
        aadd(aAux, aBrowseP[oBrowseP:nat, 3])
        aadd(aAux, 1)
        aadd(aAux, aBrowseP[oBrowseP:nat, 5])
        aadd(aBrowseCP, aAux) // adiciona o produto na cesta

        reclock("Z04", .T.)
        Z04->Z04_FILIAL := xFilial("Z04")
        Z04->Z04_CODC := aBrowseC[oBrowseC:nat, 2]
        Z04->Z04_CODP := aBrowseP[oBrowseP:nat, 2]
        Z04->Z04_PDESC := aBrowseP[oBrowseP:nat, 3]
        Z04->Z04_QUANT := 1
        Z04->Z04_TOTAL := aBrowseP[oBrowseP:nat, 5]
        
        Z04->(msunlock()) // adiciona o produto no BD
        Z04->(dbclosearea())
        DelNulo() // exclui, se houver, o registro com valores nulos que é adicionado se não houver produtos em cestas
    endif

    aBrowseCPA := aclone(aBrowseCP)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2]) // calcula o preço total da cesta

    Updt_Brw(aBrowseC[oBrowseC:nat, 2]) // atualiza o browse para mostrar todos os produtos daquela cesta

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh() // atualiza os browses e o preço
return nil

static function PesqCP(codc as character, codp as character) as numeric
    local nI as numeric
    nI := 1
    
    while nI <= len(aBrowseCP)
        if (alltrim(aBrowseCP[nI, 2]) == codc .and. alltrim(aBrowseCP[nI, 3]) == codp)
            return nI
        endif
        nI++
    enddo
return 0

// função executada quando ocorre clique duplo em produtos que estão em uma cesta
// é basicamente a função DBClickP só que invertida: aumenta o estoque e diminui os produtos da cesta, atualiza o BD correspondentemente
// e apaga o registro se todas as unidades de determinado produto forem removidas; dessa forma, esta função não será tão comentada.
static function DBClickCP()
    local nI as numeric
    local nJ as numeric
    local nAux as numeric
    local nAux2 as numeric
    local cCodc as character
    local cCodp as character

    cCodc := alltrim(aBrowseCP[oBrowseCP:nat, 2])
    cCodp := alltrim(aBrowseCP[oBrowseCP:nat, 3])
    nJ := 1

    while (cCodc != alltrim(aBrowseCPA[nJ, 2]) .or. cCodp != alltrim(aBrowseCPA[nJ, 3]))
        nJ++
    enddo

    dbselectarea("Z04")
    dbselectarea("Z02")
    Z04->(dbgotop())
    Z02->(dbgotop())

    while alltrim(Z04->Z04_CODC) != cCodc .or. alltrim(Z04->Z04_CODP) != cCodp .or. Z04->(deleted())
        Z04->(dbskip())
    enddo

    while (alltrim(Z02->Z02_COD) != cCodp .or. Z02->(deleted()))
        Z02->(dbskip())
    enddo

    aBrowseCP := aclone(aBrowseCPA)
    nI = PesqP(aBrowseCP[nJ, 3])

    if nI
        nAux := aBrowseCP[nJ, 5]

        if nAux == 1 // somente um produto de determinado tipo
            nAux2 := aBrowseP[nI, 4]
            nAux2 += 1
            aBrowseP[nI, 4] := nAux2 // incrementa o estoque

            reclock("Z02", .F.)
            Z02->Z02_EST := nAux2
            Z02->(msunlock())
            Z02->(dbclosearea())

            adel(aBrowseCP, nJ)
            asize(aBrowseCP, len(aBrowseCP)-1) // apaga o registro

            if(len(aBrowseCP) == 0)
                aadd(aBrowseCP, {"", "", "", "", NIL, NIL}) // se não há registros, adicionar um "vazio"
            endif

            reclock("Z04", .F.)
            Z04->(dbdelete())
            Z04->(msunlock()) // apaga o registro do BD
        else // existe mais de um produto de determinado tipo
            nAux2 := aBrowseP[nI, 4]
            nAux2 += 1
            aBrowseP[nI, 4] := nAux2 // incrementa o estoque

            reclock("Z02", .F.)
            Z02->Z02_EST := nAux2
            Z02->(msunlock())
            Z02->(dbclosearea())

            nAux -= 1
            aBrowseCP[nJ, 5] := nAux // decrementa a quantidade de produtos da cesta

            reclock("Z04", .F.)
            Z04->Z04_QUANT := nAux // atualiza o BD

            nAux2 := aBrowseP[nI, 5]
            aBrowseCP[nJ, 6] := nAux2 * nAux // atualiza o preço total do registro

            Z04->Z04_TOTAL := nAux2 * nAux // atualiza o preço total do registro no BD

            Z04->(msunlock())
            Z04->(dbgotop()) // desbloqueia o registro e movimenta o cursor para o topo
        endif
    endif

    Z04->(dbclosearea())
    aBrowseCPA := aclone(aBrowseCP)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2]) // fecha a tabela, faz "backup" e atualiza o preço total

    Updt_Brw(aBrowseC[oBrowseC:nat, 2]) // atualiza o browse dos produtos da cesta selecionada

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh() // atualiza o browse e total
return nil

// pesquisa no array de produtos por determinado código, retornando zero se não encontrar e a posição do produto, se encontrar
// varre o array até encontrar (ou não)
static function PesqP(codp as character) as numeric
    local nI as numeric
    nI := 1

    while nI <= len(aBrowseP)
        if (alltrim(aBrowseP[nI, 2]) == alltrim(codp))
            return nI
        endif
        nI++
    enddo
return 0

// remove o registro "nulo" adicionado quando não há produtos na cesta
// testa se o registro no topo é vazio, e se o é, remove
static function DelNulo()
    if aBrowseCP[1, 1] == ""
        adel(aBrowseCP, 1)
        asize(aBrowseCP, len(aBrowseCP)-1)
    endif
return nil

// calcula o total dos produtos da cesta, através da soma do total de cada registro
static function Total(cod_c as character) as numeric
    local tot as numeric
    local nI as numeric
    
    tot := 0
    nI := 1
    
    while nI <= len(aBrowseCP)
        if alltrim(cod_c) == alltrim(aBrowseCP[nI, 2]) // soma o total de cada registro
            tot += aBrowseCP[nI, 6]
        endif
        nI++
    enddo

    if tot == NIL
        tot := 0 // se o total for nulo, retorna zero
    endif
return tot

static function BChange() // função executada ao mudar de linha no browse de cestas
    aBrowseCP := aclone(aBrowseCPA)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2]) // atualiza o total para refletir à nova cesta

    Updt_Brw(aBrowseC[oBrowseC:nat, 2]) // atualiza para mostrar os produtos da nova cesta

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh() // atualiza os browses e total
return nil

static function Updt_Brw(cod_c as character) // atualiza o browse para exibir os produtos da cesta correspondente
    local nI as numeric
    local lDel as logical

    lDel := .F. // não entra na primeira vez

    if lRun
        nI := 1
        aBrowseCP := aclone(aBrowseCPA)
        
        while nI <= len(aBrowseCP)
            if alltrim(cod_c) != alltrim(aBrowseCP[nI, 2]) // apaga os registros cujo código de cesta é diferente do código da cesta atual
                adel(aBrowseCP, nI)
                asize(aBrowseCP, (len(aBrowseCP)-1))
                lDel := .T.
            endif

            if lDel
                nI := 1
                lDel := .F. // se deletou, volta ao início para evitar pular registros
            else
                nI++
            endif
        enddo

        if len(aBrowseCP) == 0
            aadd(aBrowseCP, {"", "", "", "", NIL, NIL}) // se o browse estiver vazio, adiciona um vetor "vazio"
        endif
    endif
    lRun := .T.
return nil
