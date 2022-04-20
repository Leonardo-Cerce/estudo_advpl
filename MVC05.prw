#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include "prconst.ch"

user function MVC05()
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
    private lRun as logical

    lRun := .F.
    lUpdt := .T.

    nTotal := 0

    aCoor := fwgetdialogsize(oMainWnd)

    oDlgPrinc := msdialog():new(aCoor[2], aCoor[1], aCoor[3], aCoor[4], "Interface de Compras",,,,,,,,, .T.,,,)

    oPanelL := tpanel():new(,,, oDlgPrinc,,,,,, aCoor[4]/4, aCoor[3]/2)
    oPanelL:align := CONTROL_ALIGN_LEFT

    oPanelR := tpanel():new(,,, oDlgPrinc,,,,,, aCoor[4]/4, aCoor[3]/2)
    oPanelR:align := CONTROL_ALIGN_LEFT

    oLayer1 := fwlayer():new()
    oLayer1:init(oPanelL, .F.)
    oLayer1:addcollumn("Esq", 100)
    oLayer1:addwindow("Esq", "WinEsq", "Produtos", 97, .F., .T.)
    
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
    oLayer2:addwindow("Fim", "WinBx", "Valor total", 80, .F., .T.,, "L3")

    oPanelEsq := oLayer1:getwinpanel("Esq", "WinEsq")
    oPanelDTp := oLayer2:getwinpanel("Topo", "WinTp", "L1")
    oPanelDMd := oLayer2:getwinpanel("Meio", "WinMd", "L2")
    oPanelDBx := oLayer2:getwinpanel("Fim", "WinBx", "L3")

    oBrowseP :=  tcbrowse():new(,, aCoor[4]/4, aCoor[3]/2,,,, oPanelEsq,,,, /*bChange*/, {|| DBClickP()}, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)
    oBrowseC :=  tcbrowse():new(,, aCoor[4]/4, aCoor[3]/5,,,, oPanelDTp,,,, {|| BChange()}, /*bDouble*/, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)
    oBrowseCP := tcbrowse():new(,, aCoor[4]/4, aCoor[3]/5,,,, oPanelDMd,,,, /*bChange*/, {|| DBClickCP()}, /*bRight*/,,,,,,,, .T.,,,, .T., .T.)

    if select("Cesta") != 0
        dbselectarea("Cesta")
        Cesta->(dbclosearea())
    endif

    cQuery := "SELECT * FROM Z03990 WHERE D_E_L_E_T_=' '"
    tcquery cQuery new alias Cesta
    dbselectarea("Cesta")

    Cesta->(dbgotop())
    aBrowseC := {}
    while !Cesta->(eof())
        aAux := {}
        aadd(aAux, Cesta->Z03_FILIAL)
        aadd(aAux, Cesta->Z03_COD)
        aadd(aAux, Cesta->Z03_DESC)
        aadd(aBrowseC, aAux)
        Cesta->(dbskip())
    enddo

    oBrowseC:addcolumn(tccolumn():new("Filial", {||aBrowseC[oBrowseC:nAt, 1]}))
    oBrowseC:addcolumn(tccolumn():new("Código", {||aBrowseC[oBrowseC:nAt, 2]}))
    oBrowseC:addcolumn(tccolumn():new("Descrição", {||aBrowseC[oBrowseC:nAt, 3]}))
    oBrowseC:setarray(aBrowseC)

    if select("Prod") != 0
        dbselectarea("Prod")
        Prod->(dbclosearea())
    endif

    cQuery := "SELECT * FROM Z02990 WHERE D_E_L_E_T_=' '"
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

    oBrowseP:addcolumn(tccolumn():new("Filial", {||aBrowseP[oBrowseP:nAt, 1]}))
    oBrowseP:addcolumn(tccolumn():new("Código", {||aBrowseP[oBrowseP:nAt, 2]}))
    oBrowseP:addcolumn(tccolumn():new("Descrição", {||aBrowseP[oBrowseP:nAt, 3]}))
    oBrowseP:addcolumn(tccolumn():new("Estoque", {||aBrowseP[oBrowseP:nAt, 4]}))
    oBrowseP:addcolumn(tccolumn():new("Preço", {||transform(aBrowseP[oBrowseP:nAt, 5], "@E 99.99")}))
    oBrowseP:setarray(aBrowseP)

    cQuery := "SELECT * FROM Z04990 WHERE D_E_L_E_T_=' '"
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

    PemC->(dbclosearea())

    if len(aBrowseCP) == 0
        aAux := {"", "", "", "", NIL, NIL}
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

    oTget := tget():new(,, {|| nTotal}, oPanelDBx, 30, 15, "@E 99.99",,,,,,,.T.,,,,,,,.T.,.F.,,/*"nTotal"*/,,,,.F.,.T.,,"Preço total da cesta:", 2,, 1,,,)

    aBrowseCPA := aclone(aBrowseCP)

    if lUpdt
        Updt_Est()
        Updt_Brw(aBrowseC[oBrowseC:nat, 2])
    endif

    oDlgPrinc:activate(,,, .T.)

    Cesta->(dbclosearea())
    Prod->(dbclosearea())
return nil

static function DBClickP()
    local aAux as array
    local nI as numeric
    local nJ as numeric
    local nAux as numeric
    local nAux2 as numeric
    local cCodc as character
    local cCodp as character

    cCodc := alltrim(aBrowseC[oBrowseC:nat, 2])
    cCodp := alltrim(aBrowseP[oBrowseP:nat, 2])

    dbselectarea("Z04")
    Z04->(dbgotop())

    nJ := 0

    while (alltrim(Z04->Z04_CODC) != cCodc .or. alltrim(Z04->Z04_CODP) != cCodp .or. Z04->(deleted())) .and. Z04->(lastrec()) > nJ
        Z04->(dbskip())
        nJ++
    enddo
    
    aBrowseCP := aclone(aBrowseCPA)
    nI = PesqCP(cCodc, cCodp)

    if nI
        nAux := aBrowseP[oBrowseP:nat, 4]

        if nAux > 0
            nAux -= 1
            aBrowseP[oBrowseP:nat, 4] := nAux
        else
            msgalert("Estoque insuficiente", "Alerta")
            return nil
        endif

        nAux := aBrowseCP[nI, 5]
        nAux += 1
        aBrowseCP[nI, 5] := nAux

        reclock("Z04", .F.)
        Z04->Z04_QUANT := nAux

        nAux2 := aBrowseP[oBrowseP:nat, 5]
        nAux2 := nAux2 * nAux
        aBrowseCP[nI, 6] := nAux2

        Z04->Z04_TOTAL := nAux2
        
        Z04->(msunlock())
        Z04->(dbgotop())
    else
        nAux := aBrowseP[oBrowseP:nat, 4]

        if nAux > 0
            nAux -= 1
            aBrowseP[oBrowseP:nat, 4] := nAux
        else
            msgalert("Estoque insuficiente", "Alerta")
            return nil
        endif

        aAux := {}
        aadd(aAux, aBrowseC[oBrowseC:nat, 1])
        aadd(aAux, aBrowseC[oBrowseC:nat, 2])
        aadd(aAux, aBrowseP[oBrowseP:nat, 2])
        aadd(aAux, aBrowseP[oBrowseP:nat, 3])
        aadd(aAux, 1)
        aadd(aAux, aBrowseP[oBrowseP:nat, 5])
        aadd(aBrowseCP, aAux)

        reclock("Z04", .T.)
        Z04->Z04_FILIAL := xFilial("Z04")
        Z04->Z04_CODC := aBrowseC[oBrowseC:nat, 2]
        Z04->Z04_CODP := aBrowseP[oBrowseP:nat, 2]
        Z04->Z04_PDESC := aBrowseP[oBrowseP:nat, 3]
        Z04->Z04_QUANT := 1
        Z04->Z04_TOTAL := aBrowseP[oBrowseP:nat, 5]
        Z04->(msunlock())

        Z04->(dbgotop())
        Z04->(dbclosearea())
        DelNulo()
    endif

    aBrowseCPA := aclone(aBrowseCP)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2])

    Updt_Brw(aBrowseC[oBrowseC:nat, 2])

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh()
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
    Z04->(dbgotop())

    while alltrim(Z04->Z04_CODC) != cCodc .or. alltrim(Z04->Z04_CODP) != cCodp .or. Z04->(deleted())
        Z04->(dbskip())
    enddo

    aBrowseCP := aclone(aBrowseCPA)
    nI = PesqP(aBrowseCP[nJ, 3])

    if nI
        nAux := aBrowseCP[nJ, 5]

        if nAux == 1
            nAux2 := aBrowseP[nI, 4]
            nAux2 += 1
            aBrowseP[nI, 4] := nAux2

            adel(aBrowseCP, nJ)
            asize(aBrowseCP, len(aBrowseCP)-1)

            if(len(aBrowseCP) == 0)
                aadd(aBrowseCP, {"", "", "", "", NIL, NIL})
            endif

            reclock("Z04", .F.)
            Z04->(dbdelete())
            Z04->(msunlock())
            Z04->(dbgotop())
        else
            nAux2 := aBrowseP[nI, 4]
            nAux2 += 1
            aBrowseP[nI, 4] := nAux2

            nAux -= 1
            aBrowseCP[nJ, 5] := nAux

            reclock("Z04", .F.)
            Z04->Z04_QUANT := nAux

            nAux2 := aBrowseP[nI, 5]
            aBrowseCP[nJ, 6] := nAux2 * nAux

            Z04->Z04_TOTAL := nAux2 * nAux

            Z04->(msunlock())
            Z04->(dbgotop())
        endif
    endif

    Z04->(dbclosearea())
    aBrowseCPA := aclone(aBrowseCP)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2])

    Updt_Brw(aBrowseC[oBrowseC:nat, 2])

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh()
return nil

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

static function DelNulo()
    if aBrowseCP[1, 1] == ""
        adel(aBrowseCP, 1)
        asize(aBrowseCP, len(aBrowseCP)-1)
    endif
return nil

static function Total(cod_c as character) as numeric
    local tot as numeric
    local nI as numeric
    
    tot := 0
    nI := 1

    while nI <= len(aBrowseCP)
        if alltrim(cod_c) == alltrim(aBrowseCP[nI, 2])
            tot += aBrowseCP[nI, 6]
        endif
        nI++
    enddo

    if tot == NIL
        tot := 0
    endif
return tot

static function BChange()
    aBrowseCP := aclone(aBrowseCPA)
    nTotal := Total(aBrowseC[oBrowseC:nat, 2])

    Updt_Brw(aBrowseC[oBrowseC:nat, 2])

    oBrowseCP:setarray(aBrowseCP)
    oBrowseCP:refresh()
    oBrowseP:refresh()
    oTget:ctrlrefresh()
return nil

static function Updt_Brw(cod_c as character)
    local nI as numeric
    local lDel as logical

    lDel := .F.

    if lRun
        nI := 1
        aBrowseCP := aclone(aBrowseCPA)
        
        while nI <= len(aBrowseCP)
            if alltrim(cod_c) != alltrim(aBrowseCP[nI, 2])
                adel(aBrowseCP, nI)
                asize(aBrowseCP, (len(aBrowseCP)-1))
                lDel := .T.
            endif

            if lDel
                nI := 1
                lDel := .F.
            else
                nI++
            endif
        enddo

        if len(aBrowseCP) == 0
            aadd(aBrowseCP, {"", "", "", "", NIL, NIL})
        endif
    endif
    lRun := .T.
return nil

static function Updt_Est()
    local nI as numeric
    local nJ as numeric
    local aAux as numeric
    local aAux2 as numeric

    nI := 1
    while nI <= len(aBrowseCP)
        aAux := aBrowseCP[nI, 5]
        nJ := PesqP(aBrowseCP[nI, 3])
        aAux2 := aBrowseP[nJ, 4]
        aAux2 := aAux2 - aAux
        aBrowseP[nJ, 4] := aAux2
        nI++
    enddo
return nil
