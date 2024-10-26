/*****************************************************************************
*  Programa .....: exapi001.p                                
*  Data .........: 26 de Outubro de 2024                                     
*  Projeto ......: EXEMPLOS APIS                                        
*  Programador ..: Luan C. Arend
*  Objetivo .....: Exemplo de api para envio de e-mail com libs da TOTVS
*****************************************************************************/
{utp/utapi019.i1}

def  input param c-titulo   as char no-undo.
def  input param c-msg      as char no-undo.
def  input param c-destinat as char no-undo.
def output param c-retorno  as char no-undo.

def var h-utapi019  as handle   no-undo.

if ( trim(c-destinat)   = "" or
     trim(c-titulo)     = "" or
     trim(c-msg)        = "" )
then do:
    assign c-retorno = "Ausência de parâmetros. Preencha-o antes para enviar o e-mail!".
    return "nok".
end.

run utp/utapi019.p persistent set h-utapi019.

find first param_email no-lock no-error.

if not avail ( param_email )
then do: 
    assign c-retorno = "Não foi localizado parâmetros para envio email.".
    return "nok".
end.

empty temp-table tt-envio2. 
empty temp-table tt-mensagem. 
empty temp-table tt-erros. 
empty temp-table tt-paramEmail.      

create tt-envio2. 
assign tt-envio2.versao-integracao = 1                                            
       tt-envio2.servidor          = param_email.cod_servid_e_mail                
       tt-envio2.porta             = param_email.num_porta                        
       tt-envio2.exchange          = param_email.log_servid_exchange                                                 
       tt-envio2.remetente         = param_email.cod_usuar_email
       tt-envio2.destino           = c-destinat
       tt-envio2.assunto           = c-titulo                                    
       tt-envio2.mensagem          = c-msg                                                                              
       tt-envio2.importancia       = 2                                            
       tt-envio2.formato           = "TEXTO"                                      
       tt-envio2.acomp             = no.

if can-find ( first tt-envio2 ) 
then do:

    create tt-mensagem. 
    assign tt-mensagem.seq-mensagem = 1 
           tt-mensagem.mensagem     = tt-envio2.mensagem.

    create tt-paramEmail.
    assign tt-paramEmail.caminhoEmail = 5.       

    run pi-execute3 in h-utapi019 ( input table tt-envio2,
                                    input table tt-mensagem,
                                    input table tt-paramEmail,
                                   output table tt-erros ).
end.   

if ( return-value = "nok" )
then do:
    for each tt-erros:
        assign c-retorno = c-retorno + string(tt-erros.cod-erro) + ' - ' + tt-erros.desc-erro + chr(10).
    end.

    assign c-retorno = "Email não enviado: " + c-retorno.
    return "nok".
end.

if valid-handle(h-utapi019)
then delete procedure h-utapi019.

return "ok".

