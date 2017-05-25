;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2016/2017
;;--------------------------------------------------------------
; Imprime valor da tecla numa posição do ecran na posição linha,coluna
;--------------------------------------------------------------
;	Programa de demostração de Leitura e Escrita em ficheiro de dados 
;	Lê a primeira linha do ficheito "TEXT.TXT"
;	Escreve essa linha de texto no novo ficheiro "LINHA1.TXT"
;	Imprime tambem a linha no ecran 
;
;--------------------------------------------------------------



.8086
.model small
.stack 2048h

dseg    segment para public 'data'

      Erro_Open		db	'Erro ao tentar abrir o ficheiro$'
	Erro_Ler_Msg	db	'Erro ao tentar ler do ficheiro$'
      Erro_Close		db	'Erro ao tentar fechar o ficheiro$'	
	fbuffer		db	199 dup (32)	
      Fich 			db	'ABC.TXT',0
      HandleFich		dw	0
      car_fich		db	?
	contador		dw	5
	
	fnamed		db	'linha1.txt',0
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"	
dseg	ends

cseg	segment para public 'code'
	assume  cs:cseg, ds:dseg

Main	Proc
	mov     ax,dseg
	mov     ds,ax
		
;abre ficheiro
	mov     ah,3dh
	mov     al,0
	lea     dx,Fich
	int     21h				; Chama a rotina de abertura de ficheiro (AX fica com Handle)
	jc      erro_abrir
	mov     HandleFich,ax
	xor	    si,si			; indice da matriz dado1 inicia a zero
	jmp     ler_ciclo1

erro_abrir:
	mov     ah,09h
	lea     dx,Erro_Open
	int     21h
	jmp     sai

		
ler_ciclo1:					; faz a leitura da primeira linha do ficheiro
      mov     	ah, 3fh
      mov     	bx, HandleFich
      mov     	cx, 1			; vai ler apenas um byte de cada vez
      lea     	dx, car_fich	; DX fica a apontar para o caracter lido
      int     	21h			; lê um caracter do ficheiro
	jc		erro_ler
	cmp		ax, 0			; verifica se já chegou o fim de ficheiro EOF? 
	je		fecha_ficheiro	; se chegou ao fim do ficheiro fecha e sai
	cmp		car_fich, 13	; verifica se já chegou ao fim da linha do ficheiro
	je		fecha_ficheiro		; terminou de ler a primeira linha 
		
      mov     	ah, 02h		; escreve o caracter no ecran
	mov		dl, car_fich
	mov 		fbuffer[si], dl	; e tambem guarda na matriz dado1
	inc		contador
	inc		si		
	int		21h			; escreve no ecran
	jmp		ler_ciclo1		; vai ler o próximo caracter
	
	
erro_ler:
	mov     ah,09h
	lea     dx,Erro_Ler_Msg
	int     21h
	jmp 	sai
	  
	  
fecha_ficheiro:
	mov     ah,3eh
	mov     bx,HandleFich
	int     21h
	jnc     Cria_ficheiro

	mov     ah,09h
	lea     dx,Erro_Close
	Int     21h
		
; ############################################################
; ############################################################

Cria_ficheiro:	
	mov		ah, 3ch		; Abrir o ficheiro para escrita
	mov		cx, 00H		; Define o tipo de ficheiro ??
	lea		dx, fnamed		; DX aponta para o nome do ficheiro 
	int		21h			; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
	jnc		escreve		; Se não existir erro escreve no ficheiro
	
	mov		ah, 09h
	lea		dx, msgErrorCreate
	int		21h
	
	jmp		sai

escreve:
	mov		bx, ax		; Coloca em BX o Handle
	mov		ah, 40h		; indica que é para escrever
    	
	lea		dx, fbuffer		; DX aponta para a infromação a escrever
	mov		cx, contador	; CX fica com o numero de bytes a escrever
	int		21h			; Chama a rotina de escrita
	jnc		close			; Se não existir erro na escrita fecha o ficheiro
	
	mov		ah, 09h
	lea		dx, msgErrorWrite
	int		21h
close:
	mov		ah,3eh		; fecha o ficheiro
	int		21h
	jnc		sai
	
	mov		ah, 09h
	lea		dx, msgErrorClose
	int		21h
sai:
	mov     ah,4ch
	int     21h
Main	endp
cseg	ends
end	Main           

