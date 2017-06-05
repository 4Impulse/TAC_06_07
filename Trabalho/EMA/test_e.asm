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
;		POSX -> COLUNA
;		POSY -> LINHA
; REGISTOS USADOS
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

;------------------------------------------------------------------------
;	Le caracter pretendido
;------------------------------------------------------------------------
le_car macro car_fich
		mov     ah, 3fh
     	mov     bx, HandleFich
     	mov     cx, 1				; vai ler apenas um byte de cada vez
     	lea     dx, car_fich		; DX fica a apontar para o caracter lido
      	int     21h					; lê um caracter do ficheiro
		jc		erro_ler

		cmp		ax, 0				; verifica se já chegou o fim de ficheiro EOF? 
		je		fecha_ficheiro		; se chegou ao fim do ficheiro fecha e sai


endm

;-------------------------------------------------------------------------
;	IMPRIME O CRACTER
;-------------------------------------------------------------------------
escreve_car macro
 		mov 	bx,	HandleFich			
		mov		ah, 40h				
		lea		dx, Char
		mov 	cx,	1	
		int		21H	
endm


;------------------------------------------------------------------------
; SAVE_MAZE - Guarda as primeiras 40x20 celulas do ecra no ficheiro STR
;------------------------------------------------------------------------
SAVE_MAZE MACRO STR 
mov		ah, 3ch					; Abrir o ficheiro para escrita
		mov		cx, 00H			; Define o tipo de ficheiro ??
		lea		dx, STR			; DX aponta para o nome do ficheiro 
		int		21h				; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
		mov 	HandleFich,ax
		jnc		comeco			; Se não existir erro escreve no ficheiro
	
		mov		ah, 09h
		lea		dx, msgErrorCreate
		int		21h
	
		jmp		fimm
		

comeco:
		mov POSy,0

check_y:
		cmp 	POSy,25
		je 		fimm
		mov 	POSx,0
back:
		goto_xy POSx,POSy
		mov 	ah, 08h
		mov		bh,0			; numero da página
		int		10h		
		mov		Char, al		; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah			; Guarda a cor que está na posição do Cursor
		cmp     Char,219		; Verifica se o que vai escrever é uma parede
		je 		escreve_p
		cmp     Char,176		;Verifica se o que vai escrever é o fim
		je 		escreve_f
		jmp 	escreve

aumenta_Y:
		inc 	POSx
		cmp 	POSx,40
		JNE 	back
		inc 	POSy
		jmp		escreve_enter

	
escreve:
		mov 	bx,	HandleFich			
		mov		ah, 40h				;indica que é para escrever
		lea		dx, Char
		mov 	cx,	1	
		int		21H	
		
		jnc		aumenta_Y			; Se não existir erro na escrita continua
	
		mov		ah, 09h
		lea		dx, msgErrorWrite
		int		21h

escreve_p:
	mov Char,'#'
	jmp escreve
escreve_f:
	mov Char,'F'
	jmp escreve

escreve_enter:
		cmp 	POSy,20
		je 		fimm
		MOV 	char,13  
		mov 	bx,	HandleFich			
		mov		ah, 40h				
		lea		dx, Char
		mov 	cx,	1	
		int		21H

		MOV 	char,10  
		mov 	bx,	HandleFich			
		mov		ah, 40h				
		lea		dx, Char
		mov 	cx,	1	
		int		21H

		jnc		check_y	

fimm:

	mov bx,HandleFich	        	
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	exit				; se não acontecer erro termina
	
	goto_xy 25,23
	mov	ah, 09h
	lea	dx, Erro_Close
	int	21h

exit:

ENDM
;------------------------------------------------------------------------

.8086
.model	small
.stack	2048

;------------------------------------------------------------------------
;								VARS
;------------------------------------------------------------------------

dseg   	segment para public 'data'

	;------------------------------------------------------------------------	
	matriz 			db 	10 dup(4 dup(0))
    tempo     		db  '0066'		
	tempo_aux 		db  '    '	
    top_scores  	db  'topmenu.txt$',0
    score 			db 	'TOP10.txt$',0
    Minutos			dw		0	; Vai guardar os minutos actuais
	Segundos		dw		0	; Vai guardar os segundos actuais
	Old_seg			dw		0	; Guarda os últimos segundos que foram lidos
	STR12			DB 		"            "	; String para o tempo
	
	Minus_de_jogo 	dw 		0	; vai ter os minutso que passaram desque iniciou o jogo
	Secs_de_jogo 	dw 		0	; vai ter os secs que passaram desque inicio o jogo


	;				ESCREVER FICHEIRO / LER FICHEIRO
	;------------------------------------------------------------------------
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    msgErrorCreate	db		"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db		"Ocorreu um erro na escrita para ficheiro!$"
    HandleFich      dw      0
    car_fich        db      ?

    ; 				Ficheiros Labirinto
    Erro_Campo		db		'Campo com formato incorrecto$'
    game_screen     db      'ecra.TXT$',0
    HandleFile      dw      0
    POStrY			db		3	; a linha pode ir de [1 .. 25]
	POStrX			db		17	; POStrX pode ir [1..80]	
    nome			db 		'      ',0					;STR com o nome do jogador
    NUMDIG			db			0	; controla o numero de digitos do numero lido
	MAXDIG			db			3	; Constante que define o numero MAXIMO de digitos a ser aceite
	ASK_STR			db 		'Insira o seu nome: $',0

    ; 				Ficheiros Top10
    Fich         	db      'TOP10.txt$',0

    ; 				Ficheiros Configs
    mazegen         db      'mazegen.TXT',0
    selectedMaze	db 		'maze1.TXT$',0
    defaultMaze     db      'maze1.TXT$',0
    savedMaze 	    db 		'maze2.TXT$',0

    ;				MOSTRAR PARA VOLTAR AO MENU
    Volta_Menu		db 		'Para voltar ao menu Prima "5" $',0

    ;				VARIAVEIS PARA O LABIRINTO E AVATAR
    ;------------------------------------------------------------------------
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
	menu0_str		db	'         ___  ___  ___   ______ _____  ______  _   _  _   _  _____ ______      ',13,10
					db	'         |  \/  | / _ \ |___  /|  ___| | ___ \| | | || \ | ||  ___|| ___ \     ',13,10
					db	'         | .  . |/ /_\ \   / / | |__   | |_/ /| | | ||  \| || |__  | |_/ /     ',13,10
					db	'         | |\/| ||  _  |  / /  |  __|  |    / | | | || . ` ||  __| |    /      ',13,10
					db	'         | |  | || | | |./ /___| |___  | |\ \ | |_| || |\  || |___ | |\ \      ',13,10
					db	'         \_|  |_/\_| |_/\_____/\____/  \_| \_| \___/ \_| \_/\____/ \_| \_|     ',13,10
					db	'                                                                               ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Jogar                                       ',13,10
					db	'                                2. TOP 10                                      ',13,10
					db	'                                3. Configurar labirinto                        ',13,10
					db	'                                4. Sair                                        ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	menu3_str		db	'                             ______            _____                           ',13,10
					db	'                            / ____/___  ____  / __(_)___ ______                ',13,10
					db	'                           / /   / __ \/ __ \/ /_/ / __ `/ ___/                ',13,10
					db	'                          / /___/ /_/ / / / / __/ / /_/ (__  )                 ',13,10
					db	'                          \____/\____/_/ /_/_/ /_/\__, /____/                  ',13,10
					db	'                                                 /____/                        ',13,10
					db	'                                                                               ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                1. Voltar atras                                ',13,10
					db	'                                2. Carregar Labirinto Por Omissao              ',13,10
					db	'                                3. Carregar Labirinto Personalizado            ',13,10
					db	'                                4. Editar Labirinto Carregado                  ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10
					db  '$'

	ganhou_str		db '                      _____             _                 _                ',13,10
					db '                     |  __ \           | |               | |               ',13,10
					db '                     | |  \/ __ _ _ __ | |__   ___  _   _| |               ',13,10
					db '                     | | __ / _` |  _ \|  _ \ / _ \| | | | |               ',13,10
					db '                     | |_\ \ (_| | | | | | | | (_) | |_| |_|               ',13,10
					db '                      \____/\__,_|_| |_|_| |_|\___/ \__,_(_)               ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db	'                                                                               ',13,10	
					db	'                      Tempo decorrido:                                         ',13,10
					db	'                                                                               ',13,10
					db	'                                                                               ',13,10
					db	'+-----------------------------------------------------------------------------+',13,10
					db '$'


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
; le_string - Le uma String de tamanho NUMDIG, e insere em NUMDIG+1 o char $
;				(String nome)
;------------------------------------------------------------------------
le_string  proc
		mov		NUMDIG, 0			; inícia leitura de novo número
		mov		cx, 5			
		XOR		BX,BX

LIMPA_N: 							;caso a gente queira voltar a usar
		mov		nome[bx], ' '	
		inc		bx
		loop 	LIMPA_N

		xor cx,cx
		mov POStrX, 41
		mov POStrY, 14
CICLO:	goto_xy POStrX, POStrY
		

		call 	LE_TECLA		; lê uma nova tecla
		cmp		ah,1			; verifica se é tecla extendida
		je		ESTEND
		CMP 	AL,27			; caso seja tecla ESCAPE sai do programa
		JE		fim
		
		CMP 	AL,13			; Pressionando ENTER vai para OKNUM
		JE		OKNUM		
		
		CMP 	AL,8			; Teste BACK SPACE <- (apagar digito)
		JNE		NOBACK
		
		mov		bl,NUMDIG		; Se Pressionou BACK SPACE 
		CMP		bl,0			; Verifica se não tem digitos no numero
		JE		NOBACK			; se não tem digitos continua então não apaga e salta para NOBACK

		dec		NUMDIG			; Retira um digito (BACK SPACE)
		dec		POStrX			; Retira um digito	

		dec 	bx
		mov		bl, NUMDIG
		mov		nome[bx],' '	; Retira um digito		
		goto_xy	POStrX,POStrY
		mov 	al, ' '
		mov		ah,02h			; imprime digito 
		mov		dl,al			; na possicão do cursor
		int		21H
		jmp 	CICLO
NOBACK:	
		
		mov		bl,MAXDIG		; se atigido numero máximo de digitos ?	
		CMP		bl,NUMDIG	
		jbe		CICLO			; não aceita mais digitos
		xor		Bx, Bx			; caso contrario coloca digito na matriz nome
		mov		bl, NUMDIG
		MOV		nome[bx], al		
		mov		ah,02h			; imprime digito 
		mov		dl,al			; na possicão do cursor
		int		21H

		inc		POStrX			; avança o cursor e
		inc		NUMDIG			; incrementa o numero de digitos

ESTEND:	jmp	CICLO			

OKNUM:		
		mov		bl, NUMDIG
		MOV 	nome[bx], '$'
		inc 	bl			 
fim:	ret

le_string ENDP

;------------------------------------------------------------------------
;	CARREGA FICHEIRO
;------------------------------------------------------------------------

LOAD_FILE PROC
        mov     ah,3dh                  ; vamos abrir ficheiro para leitura 
        mov     al,0                    ; tipo de ficheiro      
        int     21h                     ; abre para leitura 
        jc      erro_abrir              ; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax           ; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo               ; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     FIM

ler_ciclo:
        mov     ah,3fh                  ; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich           ; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1                    ; numero de bytes a ler 
        lea     dx,car_fich             ; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h                             ; faz efectivamente a leitura
        jc        erro_ler            ; se carry é porque aconteceu um erro
        cmp       ax,0                        ;EOF?   verifica se já estamos no fim do ficheiro 
        je        fecha_ficheiro      ; se EOF fecha o ficheiro 
        mov     ah,02h					; coloca o caracter no ecran
        cmp     car_fich, '#'
        je		troca

continua:       
		mov       dl,car_fich         ; este é o caracter a enviar para o ecran
        int       21h                         ; imprime no ecran
        jmp       ler_ciclo           ; continua a ler o ficheiro
troca:	
		mov car_fich, 219
		jmp continua
erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:                                 ; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     FIM

        mov     ah,09h                  ; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
FIM:    
        ret 
LOAD_FILE endp

;------------------------------------------------------------------------
; LOAD_SCORE - Carrega score Emma
;------------------------------------------------------------------------

LOAD_SCORE PROC
	call apaga_ecran
	lea dx,top_scores
	call LOAD_FILE
INICIO:	
		xor bx,bx
		xor ax,ax
	

		mov     ah,3dh
		mov     al,0
		lea     dx,score
		int     21h				; Chama a rotina de abertura de ficheiro (AX fica com Handle)
		jc      erro_abrir
		mov     HandleFich,ax
		

		jmp     ler_ciclo1




ler_ciclo1:
      	
      	mov posx,35
      	mov POSy,12
tenta:	

		le_car car_fich
		cmp     car_fich,30h
		jl 		tenta
		cmp 	car_fich,39h
		ja 		tenta


		mov 	al,car_fich
		mov 	STR12[0],al

		le_car car_fich
		mov 	al,car_fich
		mov 	STR12[1],al
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],':'

		le_car car_fich
		mov 	al,car_fich
		MOV 	STR12[4],al

		le_car car_fich
		mov 	al,car_fich
		MOV 	STR12[5],al
		MOV 	STR12[6],'s'		
		MOV 	STR12[7],'$'

		goto_xy posx,posy
		MOSTRA STR12
		inc POSy

		cmp 	POSy,23
		jne		tenta
		jmp 	fecha_ficheiro






erro_abrir:
		mov     ah,09h
		lea     dx,Erro_Open
		int     21h
		jmp     FIM

erro_ler:
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h
		jmp 	FIM
	  
	  
fecha_ficheiro:
	mov     ah,3eh
	mov     bx,HandleFich
	int     21h
	jnc     FIM

	mov     ah,09h
	lea     dx,Erro_Close
	Int     21h
	jmp 	fim


FIM:

	call LE_TECLA
	CMP 		AL, 49		; Tecla 1
	JNE		FIM
	ret

LOAD_SCORE endp

;----------------------------------------------------------------------------
;LE TEMPO
;----------------------------------------------------------------------------
ler_tempo proc
	
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF

		MOV AH, 2CH    ; Buscar a hORAS
		INT 21H  

		XOR AX,AX
		MOV AL, DH         ; segundos para al
		mov Segundos, ax   ; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL         ; Minutos para al
		mov Minutos, AX    ; guarda MINUTOS na variavel correspondente

		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
ler_tempo endp

;------------------------------------------------------------------------------
;TRATA DAS HORAS
;------------------------------------------------------------------------------

trata_horas proc
			PUSHF
			PUSH AX
			PUSH BX
			PUSH CX
			PUSH DX	
			CALL 	Ler_TEMPO
	conta:	MOV		AX, Segundos
			cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
			je		fim_horas			; Se a hora não mudou desde a última leitura sai.
			mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
	
	
			inc Secs_de_jogo
			CMP Secs_de_jogo, 60
			JNE MOSTRA_SECS
	
			mov Secs_de_jogo,0
			inc Minus_de_jogo
	MOSTRA_SECS:	
			mov AX, Minus_de_jogo
			MOV 	bl, 10     
			div 	bl
			add 	al, 30h				; Caracter Correspondente às dezenas
			add		ah,	30h				; Caracter Correspondente às unidades
	
			MOV 	STR12[0],al			 
			MOV 	STR12[1],ah
			MOV 	STR12[2],'m'		
			MOV 	STR12[3],':'
			;goto_xy	6,1
			;MOSTRA	STR12 		
	
			mov 	ax,Secs_de_jogo
			MOV 	bl, 10     
			div 	bl
			add 	al, 30h				; Caracter Correspondente às dezenas
			add		ah,	30h				; Caracter Correspondente às unidades
			MOV 	STR12[4],al			 
			MOV 	STR12[5],ah
			MOV 	STR12[6],'s'		
			MOV 	STR12[7],'$'
			goto_xy	34,23
			MOSTRA	STR12 		
	
	
	
	fim_horas:		
			goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
			
			POPF
			POP DX		
			POP CX
			POP BX
			POP AX
			RET				
trata_horas endp

;----------------------------------------------------------------------
; GUARDA O TEMPO
;----------------------------------------------------------------------

save_score 	PROC
		mov bx,0
		mov al,STR12[bx] 		;Str12->'01m:25s'
		mov tempo[bx],al		;tempo->'0125'

		inc bx
		mov al,STR12[bx]
		mov tempo[bx],al

		mov bx,4
		mov al,STR12[bx]
		mov bx,2
		mov tempo[bx],al

		mov bx,5
		mov al,STR12[bx]
		mov bx,3
		mov tempo[bx],al

		INICIO:	
				xor cx,cx
				xor si,si
				xor bx,bx
				xor ax,ax
	

				mov     ah,3dh
				mov     al,0
				lea     dx,score
				int     21h				; Chama a rotina de abertura de ficheiro (AX fica com Handle)
				jc      erro_abrir
				mov     HandleFich,ax
		

				xor	    si,si			; indice da matriz inicia a zero
				jmp     ler_ciclo1
		ler_ciclo1:
      			lea 	si,matriz   
		linha:
      		tenta:	
				le_car  car_fich
				cmp     car_fich,30h    ;compara se ta a baixo do 0
				jl 		tenta
				cmp 	car_fich,39h    ;compara se ta acima do 9
				ja 		tenta

				mov 	bx,0				;1º algarismo da 1º coluna
				mov 	al,car_fich
				mov 	matriz[si][bx],AL 	;meter numero
				le_car car_fich

				mov 	bx,1				;2 algarismo da coluna
				mov 	al,car_fich
				mov 	matriz[si][bx],AL 	;meter numero
				le_car car_fich

				mov 	bx,2				;1 algarismo da 2  coluna
				mov 	al,car_fich
				mov 	matriz[si][bx],AL 	;meter numero
				le_car car_fich

				mov 	bx,3				;2 algarismo da 2 coluna
				mov 	al,car_fich
				mov 	matriz[si][bx],AL 	;meter numero

				add 	si,4				;anda na linha
				cmp 	si,40				;ve se esta no maximo
				jne		tenta
				jmp 	fecha_ficheiro

		erro_abrir:
				mov     ah,09h
				lea     dx,Erro_Open
				int     21h
				jmp     sai

		erro_ler:
				mov     ah,09h
				lea     dx,Erro_Ler_Msg
				int     21h
				jmp 	sai
	  
	  
		fecha_ficheiro:
			mov     ah,3eh
			mov     bx,HandleFich
			int     21h
			jnc     comparacao

			mov     ah,09h
			lea     dx,Erro_Close
			Int     21h
			jmp 	fim
		
		troca:
			mov bx,0
			mov al,matriz[si][bx]	;tira o primeiro algarismo da matriz
			mov tempo_aux[bx],al 	; mete-o na variavel auxiliar
			mov al,tempo[bx]		;tira o primeiro algarismo de tempo
			mov matriz[si][bx],al 	;mete-o na matriz
			mov al, tempo_aux[bx]	;tira o primeiro alrismo da variavel auxiliar
			mov tempo[bx],al 		;mete-o na variavel aux
			
			inc bx
			mov al,matriz[si][bx]	;tira o segundo algarismo da matriz
			mov tempo_aux[bx],al 	; mete-o na variavel auxiliar
			mov al,tempo[bx]		;tira o segundo algarismo de tempo
			mov matriz[si][bx],al 	;mete-o na matriz
			mov al, tempo_aux[bx]	;tira o segundo alrismo da variavel auxiliar
			mov tempo[bx],al 		;mete-o na variavel aux
			
			inc bx
			mov al,matriz[si][bx]	;tira o treceiro algarismo da matriz
			mov tempo_aux[bx],al 	; mete-o na variavel auxiliar
			mov al,tempo[bx]		;tira o treceiro algarismo de tempo
			mov matriz[si][bx],al 	;mete-o na matriz
			mov al, tempo_aux[bx]	;tira o treceiro alrismo da variavel auxiliar
			mov tempo[bx],al 		;mete-o na variavel aux
			
			inc bx
			mov al,matriz[si][bx]	;tira o quarto algarismo da matriz
			mov tempo_aux[bx],al 	; mete-o na variavel auxiliar
			mov al,tempo[bx]		;tira o quarto algarismo de tempo
			mov matriz[si][bx],al 	;mete-o na matriz
			mov al, tempo_aux[bx]	;tira o quarto alrismo da variavel auxiliar
			mov tempo[bx],al 		;mete-o na variavel aux
			jmp comparacao
	
		comparacao:
			mov 	si,0
		 aqui:	
		 	mov 	bx,0				;temos o tempo assim: 0000 (em hexadecimal)
		 	mov     al,tempo[bx]
		 	cmp 	matriz[si][bx],al 	;compara [0]0000
		 	ja 		troca
		 	cmp 	matriz[si][bx],al
		 	jl 		continua
		
		 	inc 	bx
		 	mov     al,tempo[bx]
		 	cmp 	matriz[si][bx],al 	;compara 0[0]00
		 	ja 		troca
		 	cmp 	matriz[si][bx],al
		 	jl 		continua
		
		 	inc 	bx
		 	mov     al,tempo[bx]
		 	cmp 	matriz[si][bx],al	;compara 00[0]0
		 	ja 		troca
		 	cmp 	matriz[si][bx],al
		 	jl 		continua
		
		 	inc 	bx
		 	mov     al,tempo[bx]
		 	cmp 	matriz[si][bx],al 	;compara 000[0]
		 	ja 		troca
		 	cmp 	matriz[si][bx],al
		 	jl 		continua
		continua:
		 	add 	si,4
		 	cmp 	si,40								
			jne		aqui
		
		sai:
				mov		ah, 3ch				; Abrir o ficheiro para escrita
				mov		cx, 00H				; Define o tipo de ficheiro ??
				lea		dx, score			; DX aponta para o nome do ficheiro 
				int		21h					; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
				mov 	HandleFich,ax
				jnc		comeca_save			; Se não existir erro escreve no ficheiro
			
				jmp		fim
		

		comeca_save:
		
				mov 	si,0
		novalinha:
					;escreve o 1 caracter da 1 caluna
				mov 	bx,0
				mov 	al,matriz[si][bx]
				mov 	char,al 				
				escreve_car	
					;escreve o 2 caracter da 1 caluna
				mov 	bx,1
				mov 	al,matriz[si][bx]
				mov 	char,al 				
				escreve_car	
					;escreve o 1 caracter da 2 caluna
				mov 	bx,2
				mov 	al,matriz[si][bx]
				mov 	char,al 				
				escreve_car
					;escreve o 2 caracter da 2 caluna
				mov 	bx,3
				mov 	al,matriz[si][bx]
				mov 	char,al 				
				escreve_car
					;escrever mudanca de linha
				MOV 	char,13  
				mov 	bx,	HandleFich			
				mov		ah, 40h				
				lea		dx, Char
				mov 	cx,	1	
				int		21H
		
				MOV 	char,10  
				mov 	bx,	HandleFich			
				mov		ah, 40h				
				lea		dx, Char
				mov 	cx,	1	
				int		21H
		
				add si, 4
				cmp si,40
				jne novalinha
					;fecha_ficheiro
				mov bx,HandleFich	        	
				mov	ah,3eh			; indica que vamos fechar
				int	21h				; fecha mesmo
				jnc	FIM				; se não acontecer erro termina
			
		
				mov	ah, 09h
				lea	dx, Erro_Close
				int	21h
		
		FIM:
			ret

save_score endp
;------------------------------------------------------------------------
; LOAD_SCREEN - imprime o ficheiro game_screen
;------------------------------------------------------------------------
LOAD_SCREEN proc 
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,game_screen		; nome do ficheiro
        int     21h				; abre para leitura 
        jc      M_erro_abrir	; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax	; ax devolve o Handle para o ficheiro 
        jmp     M_ler_ciclo		; depois de abero vamos ler o ficheiro 

M_erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     M_sai

M_ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
	  jc	    M_erro_ler		; se carry é porque aconteceu um erro
	  cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
	  je	    M_fecha_ficheiro; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	  int	    21h				; imprime no ecran
	  jmp	    M_ler_ciclo		; continua a ler o ficheiro

M_erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

M_fecha_ficheiro:				; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     M_sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
M_sai:
	ret
        
LOAD_SCREEN endp

;------------------------------------------------------------------------
; LOAD_MAZE - Carrega Labirinto para o ecra 
;									Inicio (AH=1) Carrega Ecra (AH=0) nop
;									Return (AH=0) Ok (AH=1) ERRO
;------------------------------------------------------------------------
LOAD_MAZE PROC
	cmp ah, 1
	jne inicio
	call LOAD_SCREEN
	
inicio:	GOTO_XY 0,0

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
    lea     dx,selectedMaze	; nome do ficheiro
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

;-------------------------------------------------------------------------
;LE TECLA SO PARA O JOGO
;-------------------------------------------------------------------------

LE_TECLA_JOGO	PROC
sem_tecla:
		call trata_horas
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		goto_xy	POSx,POSy
		
		MOV	AH,08H
		INT	21H
		MOV	AH,0
		CMP	AL,0
		JNE	SAI_TECLA
		MOV	AH, 08H
		INT	21H
		MOV	AH,1
SAI_TECLA:	
		RET
LE_TECLA_JOGO	ENDP


;------------------------------------------------------------------------
; JOGO
;------------------------------------------------------------------------
JOGO PROC

	mov Secs_de_jogo,0
	mov Minus_de_jogo,0 

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
		cmp char,176		; DETETOU O FIM
		jE  ENCONTROU 		; vai para encontrou 
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
		
LER_SETA:	call 		LE_TECLA_JOGO
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

ENCONTROU:
		call ganhou
fim:	
		ret

JOGO endp

;--------------------------------------------------------------------------
; ENCONTROU
;--------------------------------------------------------------------------

ganhou PROC
		
		Call 	apaga_ecran
		GOTO_XY 0,5
		MOSTRA  ganhou_str
		goto_xy	41,13
		MOSTRA	STR12
		goto_xy	22,14
		MOSTRA 	ASK_STR
		call le_string
		goto_xy	80,25
		call save_score
		call Main

			
		mov     ah,4ch
        int     21h	
ganhou endp

;------------------------------------------------------------------------
; CONFIG_MAZE
;------------------------------------------------------------------------
CONFIG_MAZE proc

mov POSx, 1
mov POSy, 1

CICLO:	goto_xy	POSx,POSy

		cmp POSx, 39		;Passou o limite do mapa X > 40 ....yeah I know
		ja volta 			;Logo volta a Pos anterior
		cmp POSy, 19 		;Passou o limite do mapa Y > 19
		ja volta

IMPRIME:	mov		ah, 02h
		goto_xy	POSx,POSy	; Vai para posição do cursor
		mov		ah, 02h
		mov		dl, char 	; Coloca AVATAR
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
		
LER_SETA:		call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND

BRANCO:		CMP 		AL, 48				; Tecla 0
		JNE		INICIAL
		mov		Char, 32					;ESPAÇO
		jmp		CICLO					
		
INICIAL:		CMP 		AL, 'i'			; Tecla I
		JNE		PAREDE
		mov		Char, 'I'			
		jmp		CICLO		
	
PAREDE:		CMP 		AL, 'p'				; Tecla P
		JNE		FINAL
		mov		Char, 219					; #
		jmp		CICLO			
		
FINAL:		CMP 		AL, 'f'				; Tecla F
		JNE		GRAVAR
		mov		Char, 'F'			
		jmp		CICLO

GRAVAR:		CMP 		AL, 'g'				; Tecla G
		JNE		S_GRAVAR
		SAVE_MAZE selectedMaze
		jmp		fim

S_GRAVAR:	CMP 		AL, 27				; Tecla ESC
		JNE		CICLO
		jmp		fim

	
ESTEND:	cmp 		al,48h
		jne		BAIXO
		dec		POSy				;cima
		jmp		CICLO

BAIXO:	cmp		al,50h
		jne		ESQUERDA
		inc 		POSy			;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx				;Esquerda
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		CICLO 
		inc		POSx				;Direita
		jmp		CICLO
Volta: 						;retorna a pos Anterior
		mov al,POSya
		mov POSy,al
		mov al, POSxa
		mov	POSx,al
		jmp LER_SETA

fim:	
		ret
CONFIG_MAZE endp

;------------------------------------------------------------------------
; LOAD_MAZEGEN - imprime o ficheiro mazegen
;------------------------------------------------------------------------
LOAD_MAZEGEN proc 
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,mazegen		; nome do ficheiro
        int     21h				; abre para leitura 
        jc      M_erro_abrir	; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax	; ax devolve o Handle para o ficheiro 
        jmp     M_ler_ciclo		; depois de abero vamos ler o ficheiro 

M_erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     M_sai

M_ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
	  jc	    M_erro_ler		; se carry é porque aconteceu um erro
	  cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
	  je	    M_fecha_ficheiro; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	  int	    21h				; imprime no ecran
	  jmp	    M_ler_ciclo		; continua a ler o ficheiro

M_erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

M_fecha_ficheiro:				; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     M_sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
M_sai:
	ret
        
LOAD_MAZEGEN endp

;------------------------------------------------------------------------
; SELECT_DEFAULT - copia defaultMaze para selectedMaze
;------------------------------------------------------------------------
SELECT_DEFAULT proc
	mov bx, 0 ;imaginar em C == i=0;
CICLO:
	mov al, defaultMaze[bx]
	cmp al, 0
	JE Sai		
		mov selectedMaze[bx], al ;copia
		inc BX 	;i++
    JMP CICLO ;jump not equal
 
    Sai:
    	ret

SELECT_DEFAULT endp


;------------------------------------------------------------------------
; SELECT_SAVED - copia savedMaze para selectedMaze
;------------------------------------------------------------------------
SELECT_SAVED proc
	mov bx, 0 ;imaginar em C == i=0;
CICLO:
		mov al, savedMaze[bx]
	cmp al, 0
	JE Sai		
		mov selectedMaze[bx], al ;copia
		inc BX 	;i++
    JMP CICLO ;jump not equal
 
    Sai:
    	ret

SELECT_SAVED endp
;------------------------------------------------------------------------

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
	call apaga_ecran
	mov ah, 1 				;Load_MAZE tem input e output
	call LOAD_MAZE
	cmp al, 1				;Load_MAZE tem input e output
	je c_erro
	cmp al, 0				;Load_MAZE tem input e output
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
	jne voltar3_1
		je menu_0
	voltar3_1: CMP 	AL, 50			; TECLA dois
	jne voltar3_2
	call SELECT_DEFAULT
	jmp menu_3
	voltar3_2: CMP 	AL, 51			; TECLA tres
	jne voltar3_3
	call SELECT_SAVED
	jmp menu_3
	voltar3_3: CMP 	AL, 52			; TECLA quatro
		jne menu_3
		call		apaga_ecran
		call 		LOAD_MAZEGEN
		mov ah, 0					;Load_MAZE tem input e output
		call 		LOAD_MAZE
		call 		CONFIG_MAZE
	jmp menu_3
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
