;------------------------------------------------------------------------
;------------------------------------------------------------------------
;
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2016/2017
;------------------------------------------------------------------------
; 								MACROS
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
; 							FIM DAS MACROS
;------------------------------------------------------------------------


.8086
.model	small
.stack	2048

;------------------------------------------------------------------------
;								VARS
;------------------------------------------------------------------------

dseg   	segment para public 'data'

	;					VARIAVEIS PARA O RELOGIO E DATA
	STR12	 		DB 		"            "	; String para 12 digitos	
	NUMERO			DB		"                    $" 	; String destinada a guardar o número lido
	POSy			db	10	; a linha pode ir de [1 .. 25]
	POSx			db	40	; POSx pode ir [1..80]	
	NUMDIG			db	0	; controla o numero de digitos do numero lido
	MAXDIG			db	1	; Constante que define o numero MAXIMO de digitos a ser aceite					
	NUM_SP			db		"                    $" 	; PAra apagar zona de ecran
	
	;				ESCREVER FICHEIRO / LER FICHEIRO
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich         	db      'TOP10.txt$'
    HandleFich      dw      0
    car_fich        db      ?

    ;				MOSTRAR PARA VOLTAR AO MENU
    Volta_Menu		db 		'Para voltar ao menu Prima "5" $'


	;						MENU	
	menu_str		db	'         ___  ___  ___   ______ _____  ______  _   _  _   _  _____ ______     ',13,10
					db	'         |  \/  | / _ \ |___  /|  ___| | ___ \| | | || \ | ||  ___|| ___ \     ',13,10
					db	'         | .  . |/ /_\ \   / / | |__   | |_/ /| | | ||  \| || |__  | |_/ /     ',13,10
					db	'         | |\/| ||  _  |  / /  |  __|  |    / | | | || . ` ||  __| |    /      ',13,10
					db	'         | |  | || | | |./ /___| |___  | |\ \ | |_| || |\  || |___ | |\ \      ',13,10
					db	'         \_|  |_/\_| |_/\_____/\____/  \_| \_| \___/ \_| \_/\____/ \_| \_|     ',13,10
					db	'                                                                               ',13,10	
					db	'                                                                               ',13,10
					db	'                                                                               ',13,10
					db	'                                                                               ',13,10						
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


LOAD_SCORE endp

;------------------------------------------------------------------------
;								MAIN
;------------------------------------------------------------------------

main	proc
		mov     ax, dseg
		mov     ds, ax
		mov		ax,0B800h 		; memoria de video
		mov		es,ax
		
		GOTO_XY 0,5
		call	apaga_ecran
		MOSTRA 	menu_str
		GOTO_XY 80,25

;#############################################################  __  __                   #######################################################
;############################################################# |  \/  |                  #######################################################
;############################################################# | \  / | ___ _ __  _   _  #######################################################
;############################################################# | |\/| |/ _ \ '_ \| | | | #######################################################
;############################################################# | |  | |  __/ | | | |_| | #######################################################
;############################################################# |_|  |_|\___|_| |_|\__,_| #######################################################

menu:	call 	LE_TECLA

		um:		cmp 	al, '1'			; TECLA UM
				je 		fim
		dois:	CMP 	AL, '2'			; TECLA DOIS
				je 		abre_ficheiro
		tres:	CMP 	al, '3'			; TECLA TRES
				JE 		fim
		quatro: CMP 	AL, '4'			; TECLA QUATRO
				JE		FIM
		jmp menu 						; nao leu nenhuma das opçoes retorna ao inicio do menu


menu_volta:	call LE_TECLA
		
		cinco:	cmp 	al, '5'			; TECLA cinco para voltar ao menu
				je 		voltar_menu

		jmp menu_volta

;##################################### _          _ _                         _         ______ _      _          _           #######################################
;#####################################| |        (_) |                       | |       |  ____(_)    | |        (_)          #######################################
;#####################################| |     ___ _| |_ _   _ _ __ __ _    __| | ___   | |__   _  ___| |__   ___ _ _ __ ___  #######################################
;#####################################| |    / _ \ | __| | | | '__/ _` |  / _` |/ _ \  |  __| | |/ __| '_ \ / _ \ | '__/ _ \ #######################################
;#####################################| |___|  __/ | |_| |_| | | | (_| | | (_| | (_) | | |    | | (__| | | |  __/ | | | (_) |#######################################
;#####################################|______\___|_|\__|\__,_|_|  \__,_|  \__,_|\___/  |_|    |_|\___|_| |_|\___|_|_|  \___/ #######################################



voltar_menu:
		GOTO_XY 0,5
		call	apaga_ecran
		MOSTRA 	menu_str
		GOTO_XY 80,25
		call 	menu

termina_fich:
	GOTO_XY 80,25
	call menu_volta

fim:
	GOTO_XY 24,0
	call	apaga_ecran	
	mov		ah,4CH
	INT		21H
		
main		endp
cseg    	ends
end     	Main