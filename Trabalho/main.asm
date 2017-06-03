;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2016/2017
;	Filipe Alves && Emanuel Alves

;------------------------------------------------------------------------
; 								MACROS
;------------------------------------------------------------------------

;------------------------------------------------------------------------
;MACRO GOTO_XY
;------------------------------------------------------------------------
; COLOCA O CURSOR NA POSIÇÃO POSX,POSY
;	POSX -> COLUNA
;	POSY -> LINHA
; 	REGISTOS USADOS
;		AH, BH, DL,DH (DX)
;------------------------------------------------------------------------
GOTO_XY		MACRO	POSX,POSY
			MOV	AH,02H
			MOV	BH,0
			MOV	DL,POSX
			MOV	DH,POSY
			INT	10H
ENDM
;------------------------------------------------------------------------

;------------------------------------------------------------------------
; MOSTRA - Faz o display de uma string terminada em $
;---------------------------------------------------------------------------
MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM
;------------------------------------------------------------------------


.8086
.model	small
.stack	2048

;------------------------------------------------------------------------
;								VARS
;------------------------------------------------------------------------

dseg   	segment para public 'data'

	;				VARIAVEIS PARA O RELOGIO E DATA
	;------------------------------------------------------------------------
	STR12	 		DB 		"            "				; String para 12 digitos	
	NUMERO			DB		"                    $" 	; String destinada a guardar o número lido
	NUMDIG			db		0							; controla o numero de digitos do numero lido
	MAXDIG			db		1							; Constante que define o numero MAXIMO de digitos a ser aceite					
	NUM_SP			db		"                    $" 	; PAra apagar zona de ecran
	
	;				ESCREVER FICHEIRO / LER FICHEIRO
	;------------------------------------------------------------------------
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich         	db      'TOP10.txt$',0
    HandleFich      dw      0
    car_fich        db      ?

    ; 				Ficheiros Labirinto
    Erro_Campo		db		'Campo com formato incorrecto$'
    defaultFile     db      'field.TXT$',0
    HandleFile      dw      0

    ;				MOSTRAR PARA VOLTAR AO MENU
    Volta_Menu		db 		'Para voltar ao menu Prima "5" $',0

    ;				VARIAVEIS PARA O LABIRINTO E AVATAR
    pos_Ix			db 		0
    pos_Iy			db 		0
    flagI			db 		0

    pos_Fx			db 		0
    pos_Fy			db 		0
    flagF			db 		0

    lido_X			db 		0
    lido_Y			db 		0

   	char			db		32							; Guarda um caracter do Ecran 
	Cor				db		7							; Guarda os atributos de cor do caracter
	POSy			db		0							; a linha pode ir de [1 .. 25]
	POSx			db		0							; POSx pode ir [1..80]	
	POSya			db		0							; Posição anterior de y
	POSxa			db		40							; Posição anterior de x


	;				MENU
	;------------------------------------------------------------------------	
	menu0_str		db	'         ___  ___  ___   ______ _____  ______  _   _  _   _  _____ ______     ',13,10
					db	'         |  \/  | / _ \ |___  /|  ___| | ___ \| | | || \ | ||  ___|| ___ \     ',13,10
					db	'         | .  . |/ /_\ \   / / | |__   | |_/ /| | | ||  \| || |__  | |_/ /     ',13,10
					db	'         | |\/| ||  _  |  / /  |  __|  |    / | | | || . ` ||  __| |    /      ',13,10
					db	'         | |  | || | | |./ /___| |___  | |\ \ | |_| || |\  || |___ | |\ \      ',13,10
					db	'         \_|  |_/\_| |_/\_____/\____/  \_| \_| \___/ \_| \_/\____/ \_| \_|     ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Jogar                                       ',13,10
					db	'                                2. TOP 10                                      ',13,10
					db	'                                3. Configurar labirinto                        ',13,10
					db	'                                4. Sair                                        ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10	
					db	'                                                                               ',13,10
					db	'                                                                               ',13,10
					db	'                                                                               ',13,10
					db  '$'
	menu1_str		db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Voltar atras                                ',13,10
					db	'                                2. Escolher Labirinto                          ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	menu2_str		db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Voltar atras                                ',13,10
					db	'                                2. Mostrar Top10                               ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	menu3_str		db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Voltar atras                                ',13,10
					db	'                                2. Carregar Labirinto                          ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'


dseg    	ends

;------------------------------------------------------------------------
;								CODE segment
;------------------------------------------------------------------------

cseg		segment para public 'code'
	assume  cs:cseg, ds:dseg

;------------------------------------------------------------------------
; APAGA_ECRAN - CLS....
;------------------------------------------------------------------------
apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80
		
apaga:			mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
apaga_ecran	endp

;------------------------------------------------------------------------
; LE_TECLA - apenas le a tecla lida e OUTPUT em AH, nao imprime ou espera ok
;------------------------------------------------------------------------
LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

;------------------------------------------------------------------------
; LOAD_SCORE - Carrega score Emma
;------------------------------------------------------------------------
LOAD_SCORE PROC

abre_ficheiro:
		call	apaga_ecran
		GOTO_XY	0,0
		MOSTRA 	Volta_Menu
		GOTO_XY 0,4
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich			; nome do ficheiro
        int     21h				; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     termina_fich

ler_ciclo:
		mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
	  	jc	    erro_ler		; se carry é porque aconteceu um erro
	  	cmp	    ax,0			; EOF?	verifica se já estamos no fim do ficheiro 
	  	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  	mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	  	int	    21h				; imprime no ecran
	  	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     termina_fich

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h

termina_fich:

		call 	LE_TECLA
		CMP 	AL, 53
		JNE termina_fich
		;ret


LOAD_SCORE endp

;------------------------------------------------------------------------
; LOAD_MAZE - Carrega Labirinto para o ecra Return (AH=0) Ok (AH=1) ERRO
;------------------------------------------------------------------------
LOAD_MAZE PROC
	call apaga_ecran
	GOTO_XY 0,0

	mov pos_Ix, 0
    mov pos_Iy, 0
    mov flagI,  0

    mov pos_Fx, 0
    mov pos_Fy, 0
    mov flagF,  0

    mov lido_X, 0
    mov lido_Y, 0

	clc
	mov 	HandleFile, 0
    mov     ah,3dh			; vamos abrir ficheiro para leitura 
    mov     al,0			; tipo de ficheiro	
    lea     dx,defaultFile	; nome do ficheiro
    int     21h				; abre para leitura 
    jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
    mov     HandleFile,ax	; ax devolve o Handle para o ficheiro 
    jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
	GOTO_XY 0, 0
    mov     ah,09h
    lea     dx,Erro_Open
    int     21h
    call 	LE_TECLA
	cmp 	AL, 13			;enter
	je 		sai_erro
    jmp     erro_abrir

ler_ciclo:
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
	mov     bx,HandleFile	; bx deve conter o Handle do ficheiro previamente aberto 
	mov     cx,1			; numero de bytes a ler 
	lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
	int     21h				; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro
	cmp car_fich, 13		;mudou de linha 
	je aumenta_Y			;logo tem de reniciar o X e inc o Y
	inc lido_X				;inc X
back:
	cmp lido_X, 41			;ve se esta dentro dos parametros do mapa 40x20 (aqui so valida X)
	jb imprime				; x < 41 
	jmp	ler_ciclo			; continua a ler o ficheiro

aumenta_Y:
 	inc lido_Y 				;mudou de linha logo Y incrementa
 	mov lido_X, -1 			;visto o X ainda estar no "\n" começa a -1 para na primeira vez ler como 0
 	jmp back

imprime:
	cmp lido_y, 19			;ve se esta dentro dos parametros do mapa 40x20 (aqui so valida Y) 
	ja ler_ciclo			; y > 19
	cmp car_fich, 'I'		;Encontra a Pos Inicial
	je encontrou_I
	cmp car_fich, 'F'		;Encontra a Pos Final
	je encontrou_F
	cmp car_fich, '#'		;Encontra uma parede
	je encontrou_P
	mov     ah,02h			; Int21 para imprimir
	mov	    dl,car_fich		; Caracter que leu do ficheiro (senao for I F ou #)
	int	    21h				; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

encontrou_p:
	mov     ah,02h			
	mov	    dl, 219			
	int	    21h
	jmp ler_ciclo


encontrou_I:
	mov ah, lido_X			;Marca a PosI para o Avatar (em X)
	mov pos_Ix, ah

	mov ah, lido_Y 			;Marca a PosI para o Avatar (em Y)
	mov pos_Iy, ah

	inc flagI 				;Encontro X numeros de I
	mov ah,02h				
	mov	dl, ' '		
	int	21h
	jmp ler_ciclo

encontrou_F:
	mov ah, lido_X 			;Marca a PosF para o Avatar (em X)
	mov pos_Fx, ah

	mov ah, lido_Y 			;Marca a PosF para o Avatar (em Y)
	mov pos_Fy, ah

	inc flagF 				;Encontro X numeros de F
	mov     ah,02h			
	mov	    dl, 176			
	int	    21h
	jmp ler_ciclo

erro_ler:
	GOTO_XY 0, 0
    mov     ah,09h
    lea     dx,Erro_Ler_Msg
    int     21h
    call 	LE_TECLA
	;cmp 	AL, 13			;enter
	;je 	sai

fecha_ficheiro:				; vamos fechar o ficheiro 
    mov     ah,3eh
    mov     bx,HandleFile
    int     21h

    cmp 	flagI, 1		;Se nao detetou 1 e apenas 1 local Inicial algo esta incorrecto
	jne 	sai_erro
	cmp 	flagF, 1 		;Se nao detetou 1 e apenas 1 local Final algo esta incorrecto
	jne 	sai_erro
	jmp     sai

    jnc     sai

    mov     ah,09h			; o ficheiro pode não fechar correctamente
    lea     dx,Erro_Close
    Int     21h

sai_erro:
    mov     al, 1
    jmp return
sai:
    mov     al, 0
    jmp return

return:
	RET 
LOAD_MAZE endp

;------------------------------------------------------------------------
; JOGO
;------------------------------------------------------------------------
JOGO PROC
	mov ah, pos_Ix
	mov POSx, ah
	sub Posx, 1				;Esta linha é ilusao professor, ignore :)

	mov ah, pos_Iy
	mov POSy, ah

	goto_xy	POSx,POSy		; Vai para nova possição
	mov 	ah, 08h			; Guarda o Caracter que está na posição do Cursor
	mov		bh,0			; numero da página
	int		10h			
	mov		char, al		; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah			; Guarda a cor que está na posição do Cursor		
	

CICLO:	goto_xy	POSx,POSy	; Vai para nova possição
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		char, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah		; Guarda a cor que está na posição do Cursor

		cmp char,219		;Detetou parede!
		JE volta 			;Logo volta a Pos anterior
		cmp char,176
		jE  fim 
		cmp POSx, 40		;Passou o limite do mapa X > 40 ....yeah I know
		ja volta 			;Logo volta a Pos anterior
		cmp POSy, 19 		;Passou o limite do mapa Y > 19
		ja volta	 		;Logo volta a Pos anterior
	
IMPRIME:	
		goto_xy	POSx,POSy	; Vai para posição do cursor
		mov		ah, 02h
		mov		dl, 254		; Coloca AVATAR
		int		21H	
		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, char	; Repoe Caracter guardado 
		int		21H	
		goto_xy	POSx,POSy	; Vai para posição do cursor
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
LER_SETA:	call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 	AL, 27	; ESCAPE
		JE		fim
		jmp		LER_SETA
		
ESTEND:	cmp 		al,48h
		jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

BAIXO:	cmp		al,50h
		jne		ESQUERDA
		inc 		POSy	;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx		;Esquerda
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		inc		POSx		;Direita
		jmp		CICLO
Volta: 						;retorna a pos Anterior
		mov al,POSya
		mov POSy,al
		mov al, POSxa
		mov	POSx,al
		jmp LER_SETA
fim:	
		ret

JOGO endp

;------------------------------------------------------------------------
;								MAIN
;------------------------------------------------------------------------

main		proc
	mov     ax, dseg
	mov     ds, ax

	mov		ax,0B800h 		; memoria de video
	mov		es,ax
;-------------------------------------------------------------------------------
; MENU 0 - MENU INICIAL
;-------------------------------------------------------------------------------
menu_0:	
		mov al, 0
		GOTO_XY 0,5

		call	apaga_ecran
		MOSTRA 	menu0_str

		GOTO_XY 79,24
		call 	LE_TECLA
um: 	CMP 	AL, 49		; TECLA um
	   	je menu_1

dois: 	CMP 	AL, 50		; TECLA dois
	   	je menu_2

tres: 	CMP 	AL, 51		; TECLA tres
	   	je menu_3

quatro: CMP 	AL, 52		; TECLA quatro
		JE		FIM

jmp menu_0				; nao leu nenhuma das opçoes retorna ao inicio do menu
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MENU 1 - MENU DO JOGO
;-------------------------------------------------------------------------------
menu_1:
	call LOAD_MAZE
	cmp al, 1
	je c_erro
	cmp al, 0
	je s_erro
		c_erro:
		 goto_xy 0, 0
		 call apaga_ecran
		 MOSTRA Erro_Campo
		 call LE_TECLA
		 cmp AL, 13			;enter
		 je menu_0
		 jmp c_erro
		s_erro:
		 call jogo	
jmp menu_0
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MENU 2 - MENU DO SCORES
;-------------------------------------------------------------------------------
menu_2:
	call 	LOAD_SCORE
jmp menu_0
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MENU 3 - MENU DOS LABIRINTOS
;-------------------------------------------------------------------------------
menu_3:
GOTO_XY 0,5

		call	apaga_ecran
		MOSTRA 	menu3_str

		GOTO_XY 79,24
		call 	LE_TECLA
	voltar3_0: CMP 	AL, 49			; TECLA um
	je menu_0
jmp menu_3
;-------------------------------------------------------------------------------
fim:
	GOTO_XY 24,0
	call	apaga_ecran	
	mov		ah,4CH
	INT		21H
		
main		endp
cseg    	ends
end     	Main