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

	;					VARIAVEIS PARA O RELOGIO E DATA
	STR12	 		DB 		"            "	; String para 12 digitos	
	NUMERO			DB		"                    $" 	; String destinada a guardar o número lido
	POSy			db	10	; a linha pode ir de [1 .. 25]
	POSx			db	40	; POSx pode ir [1..80]	
	NUMDIG			db	0	; controla o numero de digitos do numero lido
	MAXDIG			db	1	; Constante que define o numero MAXIMO de digitos a ser aceite					
	NUM_SP			db		"                    $" 	; PAra apagar zona de ecran
	
	;				ESCREVER FICHEIRO / LER FICHEIRO
	fname			db	'ABC.TXT',0
	fhandle 		dw	0
	
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"


	;						MENU	
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
					db	'                                1. Escolher Labirinto                          ',13,10
					db	'                                2. Voltar atras                                ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	menu2_str		db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Listar TOP 10                               ',13,10
					db	'                                2. Voltar atras                                ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	menu3_str		db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Carregar Labirinto                          ',13,10
					db	'                                2. Voltar atras                                ',13,10
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
GOTO_XY 0,5

		call	apaga_ecran
		MOSTRA 	menu1_str

		GOTO_XY 79,24
		call 	LE_TECLA
	voltar1_0: CMP 	AL, 50			; TECLA dois
	je menu_0
jmp menu_1
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MENU 2 - MENU DO SCORES
;-------------------------------------------------------------------------------
menu_2:
GOTO_XY 0,5

		call	apaga_ecran
		MOSTRA 	menu2_str

		GOTO_XY 79,24
		call 	LE_TECLA
	voltar2_0: CMP 	AL, 50			; TECLA dois
	je menu_0
jmp menu_2
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
	voltar3_0: CMP 	AL, 50			; TECLA dois
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