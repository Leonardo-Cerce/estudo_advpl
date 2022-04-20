// Programa simples de cadastro de pessoa física.
// Feito sem o uso do modelo MVC para treinamento em componentes como botões, caixas de texto e de diálogo.

#include "protheus.ch" // includes

user function cadastro() // função principal

    local oDlg as object
    local oBot as object
    local oTget as object
    local cNome as character
    local cEndr as character
    local cEmil as character
    local cCel as character
    local cCPF  as character
    local cRG   as character
    local dDtNc as date
    local aDados as array
    local aMens as array // variáveis locais, usadas somente nesta função
    private lIns as logical
    private nErr as numeric // variáveis de controle

    cNome := space(50)
    cEndr := space(100) // inicialização das variáveis
    cEmil := space(50)
    cCPF  := space(11)
    cRG   := space(9)
    cCel  := space(11)
    dDtNc := date()
    aMens := {"Dados incompletos, tente novamente.", "Cliente já existe no banco de dados.", "E-mail inválido.", "CPF inválido."}
    lIns  := .F.

    oDlg := msdialog():new(0, 0, 340, 270, "CADASTRO",,,,, CLR_BLACK, CLR_WHITE,,, .T.,,,,.F.) // janela principal
    
    oBot := tbutton():new(130, 5, "CANCELAR CADASTRO", oDlg, {||cancelar(oDlg)}, 60, 30,,,.T.,.T.,.F.,,.F.,,,.F.) // botões para cancelar e incluir cadastro
    oBot := tbutton():new(130, 72, "CONFIRMAR", oDlg, {||confirmar(oDlg)}, 60, 30,,,.T.,.T.,.F.,,.F.,,,.F.)

    // caixas de texto, permitem a entrada de dados
    oTget := tget():new(5, 5, {|u| if(pcount()>0, cNome := u, cNome)}, oDlg, 100, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cNome",,,,.F.,.T.,,"NOME:",2,,1,,.T.,.T.)
    oTget := tget():new(25, 5, {|u| if(pcount()>0, cEndr := u, cEndr)}, oDlg, 100, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"CEndr",,,,.F.,.T.,,"ENDEREÇO:",2,,1,,.T.,.T.)
    oTget := tget():new(45, 5, {|u| if(pcount()>0, cEmil := u, cEmil)}, oDlg, 100, 15, "@!",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cEmil",,,,.F.,.T.,,"E-MAIL:",2,,1,,.T.,.T.)
    oTget := tget():new(65, 5, {|u| if(pcount()>0, dDtNc := u, dDtNc)}, oDlg, 50, 15, "@D",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"dDtNc",,,,.F.,.T.,,"DATA NASCIMENTO:",2,,1,,.T.,.T.)
    oTget := tget():new(85, 5, {|u| if(pcount()>0, cCPF := u, cCPF)}, oDlg, 50, 15, "@R 999.999.999-99",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cCPF",,,,.F.,.T.,,"CPF:",2,,1,,.T.,.T.)
    oTget := tget():new(85, 72, {|u| if(pcount()>0, cRG := u, cRG)}, oDlg, 50, 15, "@R 99.999.999-9",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cRG",,,,.F.,.T.,,"RG:",2,,1,,.T.,.T.)
    oTget := tget():new(105, 5, {|u| if(pcount()>0, cCel := u, cCel)}, oDlg, 50, 15, "@R (99) 99999-9999",,CLR_BLACK, CLR_WHITE,,,,.T.,,,,,,,.F.,.F.,,"cCel",,,,.F.,.T.,,"NÚMERO CELULAR:",2,,1,,.T.,.T.)

    oDlg:activate(,,, .T.,,,,,) // ativação da janela principal

    if(lIns) // se é para cadastrar
        
        aDados := {cNome, cEndr, cEmil, dtoc(dDtNc), cCPF, cRG, cCel} // cria um vetor com os dados

        aDados := clrVar(aDados) // remove espaços em branco dos dados
        
        if(salvarBD(aDados)) // tenta salvar
            msgalert("Dados salvos no BD!", "Sucesso")
        else
            msgalert(aMens[nErr], "Falha")
        endif
    endif
return nil

static function cancelar(oDlg as object) // função executada ao clicar no botão de "Cancelar Cadastro"
    if msgnoyes("Deseja cancelar o cadastro?", "Atenção")
        oDlg:end() // se cancelado, fecha a janela principal
    endif
return nil

static function confirmar(oDlg as object) // função executada ao clicar no botão de "Confirmar"
    if msgyesno("Adicionar ao banco de dados?", "Atenção")
        oDlg:end() // se aceito, fecha a janela principal
        lIns := .T. // é para inserir o registro
    endif
return nil

static function salvarBD(aDados as array) as logical // função que tenta salvar o cliente no BD
    local nI as numeric
    local aArea as array

    if(len(aDados) != 7) // se não há dados suficientes, retorna o código de erro e interrompe o processo
        nErr := 1
        return .F.
    endif
    
    for nI := 1 to len(aDados)
        if(len(aDados[nI])==0) // se há dados vazios, retorna o código de erro e interrompe o processo
            nErr := 1
            return .F.
        endif
    next nI

    if !(isemail(aDados[3])) // se o email digitado não é válido, retorna o código de erro e interrompe o processo
        nErr := 3
        return .F.
    endif

    if !(cgc(aDados[5])) // se o CPF digitado não é válido, retorna o código de erro e interrompe o processo
        nErr := 4
        return .F.
    endif

    dbselectarea("Z00")
    aArea := Z00->(getarea()) // seleciona a tabela do BD e salva o cursor

    Z00->(dbsetorder(1))
    if Z00->(dbseek(xfilial("Z00")+aDados[5])) // faz uma busca; se o CPF já existe, retorna o código de erro e interrompe o processo
        nErr := 2
        return .F.
    endif

    reclock("Z00", .T.) // cria um novo registro

    Z00->Z00_FILIAL := xfilial("Z00") // insere as informações no registro
    Z00->Z00_NOME := aDados[1]
    Z00->Z00_ENDR := aDados[2]
    Z00->Z00_EMIL := aDados[3]
    Z00->Z00_DTNASC := aDados[4]
    Z00->Z00_CPF := aDados[5]
    Z00->Z00_RG := aDados[6]
    Z00->Z00_NCEL := aDados[7]

    Z00->(msunlock()) // salva o registro, restaura o cursor, e fecha a tabela
    Z00->(restarea(aArea))
    Z00->(dbclosearea())
return .T. // conseguiu inserir com sucesso

static function clrVar(aDados as array) as array
    local nI
    for nI := 1 to len(aDados)
        aDados[nI] := alltrim(aDados[nI]) // remove os espaços em branco
    next nI
return aDados
