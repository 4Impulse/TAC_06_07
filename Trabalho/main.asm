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
	STR12	 	DB 		"            "	; String para 12 digitos	
	NUMERO		DB		"                    $", 	; String destinada a guardar o número lido
		
	
	NUM_SP		db		"                    $" 	; PAra apagar zona de ecran
	DDMMAAAA 	db		"                     "

	Horas		dw		0				; Vai guardar a HORA actual
	Minutos		dw		0				; Vai guardar os minutos actuais
	Segundos	dw		0				; Vai guardar os segundos actuais
	Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
				

	POSy	db	10	; a linha pode ir de [1 .. 25]
	POSx	db	40	; POSx pode ir [1..80]	
	NUMDIG	db	0	; controla o numero de digitos do numero lido
	MAXDIG	db	4	; Constante que define o numero MAXIMO de digitos a ser aceite

	;				ESCREVER FICHEIRO / LER FICHEIRO

	fname	db	'ABC.TXT',0
	fhandle dw	0
	
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"


	;						MENU
	
	menu	db	'    ___  ___  ___   ______ _____  ______  _   _  _   _  _____ ______      ',13,10
			db	'         |  \/  | / _ \ |___  /|  ___| | ___ \| | | || \ | ||  ___|| ___ \     ',13,10
			db	'         | .  . |/ /_\ \   / / | |__   | |_/ /| | | ||  \| || |__  | |_/ /     ',13,10
			db	'         | |\/| ||  _  |  / /  |  __|  |    / | | | || . ` ||  __| |    /      ',13,10
			db	'         | |  | || | | |./ /___| |___  | |\ \ | |_| || |\  || |___ | |\ \      ',13,10
			db	'         \_|  |_/\_| |_/\_____/\____/  \_| \_| \___/ \_| \_/\____/ \_| \_|                                                                         ',13,10
			db	'+-----------------------------------------------------------------------------+',13,10
			db	'                                1. Jogar                                       ',13,10
			db	'                                2. TOP 10                                      ',13,10
			db	'                                3. Configurar labirinto                        ',13,10
			db	'                                4. Sair                                        ',13,10
			db	'+-----------------------------------------------------------------------------+',13,10
			db	'                                                                               ',13,10
			db	'Opcao:                                                                         ',13,10
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
;								MAIN
;------------------------------------------------------------------------


;########################################################################
;ROTINA PARA APAGAR ECRAN

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


;########################################################################


main		proc
	mov		ax, dseg
	mov		ds,ax
	mov		ax,0B800h
	mov		es,ax

	
		GOTO_XY 5,10

		call		apaga_ecran
		
		MOSTRA menu
	
	mov     ah,4ch
	int     21h
		
main		endp
cseg    	ends
end     	Main