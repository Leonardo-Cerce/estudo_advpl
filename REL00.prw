#include "protheus.ch"
#include "topconn.ch"

user function REL00()
    local oReport as object
    oReport := reportdef()
    oReport:printdialog()
return nil

static function reportdef() as object
    local oRep as object
    local oSec1 as object
    local oSec2 as object

    oRep := treport():new("REL00", "Clientes e Enderecos",,{|oRep| printrep(oRep)}, "Este relatorio ira exibir os clientes e seus enderecos cadastrados")
    oRep:setportrait()
    oRep:hideparampage()

    oSec1 := trsection():new(oRep, "Clientes", {"Z00"},, .F., .T.)
    trcell():new(oSec1, "NOME",, "NOME",, 50)
    trcell():new(oSec1, "CPF",, "CPF",, 14)
    trcell():new(oSec1, "RG",, "RG" ,, 12)
    trcell():new(oSec1, "EMIL",, "EMAIL",, 50)
    trcell():new(oSec1, "DTNASC",, "DATA NASCIMENTO",, 10)
    oSec1:setlinestyle(.F.)

    oSec2 := trsection():new(oRep, "Enderecos", {"Z01"},, .F., .T.)
    trcell():new(oSec2, "TIPO",, "TIPO",, 3)
    trcell():new(oSec2, "ENDR",, "ENDERECO",, 100)
    oSec2:setlinestyle(.F.)
return oRep

static function printrep(oRep as object)
    local oSec1 as object
    local oSec2 as object
    local cQuery1 as character
    local cQuery2 as character

    oSec1 := oRep:section(1)
    oSec2 := oRep:section(2)

    cQuery1 := "SELECT Z00_CPF, Z00_NOME, Z00_EMIL, Z00_RG, Z00_NCEL, Z00_DTNASC FROM Z00990 WHERE D_E_L_E_T_=' ' ORDER BY Z00_CPF"
    cQuery2 := "SELECT Z01_CPF, Z01_TIPO, Z01_ENDR FROM Z01990 WHERE D_E_L_E_T_=' ' ORDER BY Z01_CPF"

    if select("cli") != 0
        dbselectarea("cli")
        cli->(dbclosearea())
    endif

    if select("endr") != 0
        dbselectarea("endr")
        endr->(dbclosearea())
    endif

    tcquery cQuery1 new alias "cli"
    tcquery cQuery2 new alias "endr"

    dbselectarea("cli")
    dbselectarea("endr")
    cli->(dbgotop())
    endr->(dbgotop())

    oRep:setmeter(cli->(lastrec()))

    while !cli->(eof())
        if oRep:cancel()
            exit
        endif

        oSec1:init()

        oRep:incmeter()

        oSec1:cell("NOME"):setvalue(cli->Z00_NOME)
        oSec1:cell("CPF"):setvalue(transform(cli->Z00_CPF, "@R 999.999.999-99"))
        oSec1:cell("RG"):setvalue(transform(cli->Z00_RG, "@R 99.999.999-9"))
        oSec1:cell("DTNASC"):setvalue(cli->Z00_DTNASC)
        oSec1:cell("EMIL"):setvalue(cli->Z00_EMIL)
        oSec1:printline()

        oSec2:init()

        while endr->Z01_CPF == cli->Z00_CPF
            oRep:incmeter()
            oSec2:cell("TIPO"):setvalue(endr->Z01_TIPO)
            oSec2:cell("ENDR"):setvalue(endr->Z01_ENDR)
            oSec2:printline()
            endr->(dbskip())
        enddo

        oSec2:finish()
        
        oRep:thinline()

        oSec1:finish()

        cli->(dbskip())
    enddo

cli->(dbclosearea())
endr->(dbclosearea())
return nil
