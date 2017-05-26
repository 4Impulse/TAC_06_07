;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2016/2017
;--------------------------------------------------------------
;
;	Programa de demostração de criação dum ficheiro de texto  
;
;--------------------------------------------------------------


.8086
.MODEL SMALL
.STACK 2048

DADOS SEGMENT
	fname	db	'ABC.TXT',0
	fhandle dw	0
	buffer	db	'Definicoes de informatica por Murphy:',13,10
		db 	'+--------------------------------------------------------------------------+',13,10
		db 	' ABCDEFGH: partes do sistema informatico que nao funcionam.                 ',13,10
		db	' Perifericos: partes do sistema informatico que sao incompativeis com este. ',13,10 
		db 	' Cabo: parte do sistema informatico que e sempre demasiado curta.           ',13,10
		db	' Copia de seguranca: uma operacao que nunca e feita a tempo.                ',13,10
		db	' Memoria: parte do sistema informatico que e insuficiente.                  ',13,10
		db	' Ficheiro: parte do sistema informatico que nunca pode ser encontrada.      ',13,10
		db	' Processador: parte do sistema informatico que esta sempre obsoleta.        ',13,10
		db	'+--------------------------------------------------------------------------+',13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
		db	78 dup ('_'),13,10
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"
DADOS ENDS


CODIGO	SEGMENT	para	public	'code'
	ASSUME	CS:CODIGO, DS:DADOS
Main proc
	MOV	AX, DADOS
	MOV	DS, AX
	
	mov	ah, 3ch			; abrir ficheiro para escrita 
	mov	cx, 00H			; tipo de ficheiro
	lea	dx, fname			; dx contem endereco do nome do ficheiro 
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro 
	jnc	escreve			; se não acontecer erro vai vamos escrever
	
	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, msgErrorCreate
	int	21h
	
	jmp	fim

escreve:
	mov	bx, ax			; para escrever BX deve conter o Handle 
	mov	ah, 40h			; indica que vamos escrever 
    	
	lea	dx, buffer			; Vamos escrever o que estiver no endereço DX
	mov	cx, 1300			; vamos escrever multiplos bytes duma vez só
	int	21h				; faz a escrita 
	jnc	close				; se não acontecer erro fecha o ficheiro 
	
	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h
close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	fim				; se não acontecer erro termina
	
	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h
fim:
	MOV	AH,4CH
	INT	21H
main	endp
	CODIGO	ENDS
END	main


