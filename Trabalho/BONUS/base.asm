MOSTRA MACRO STR 
		MOV AH,09H
		LEA DX,STR 
		INT 21H
ENDM

goto_xy	macro		POStrX,POStrY
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POStrX
		mov		dh,POStrY
		int		10h
endm

.8086
.model	small
.stack	2048

dseg   	segment para public 'data'
		count		dw	0
		char		db  ?
		leitura		db	'Fim 1 leitura$',0
		string		db	'0000$',0
		num			dw	0
		n_dir 		db 	0
		d_dir  		db  'Direcao: $',0	
		d_zero  	db  '00 - Norte$',0
		d_um  		db  '01 - Sul$',0
		d_dez  		db  '10 - Este$',0
		d_onze  	db  '11 - Oeste$',0

		n_pass 		db 0
		p_pass		db  'Passos: $',0
		p_zero  	db  '00 - Um$',0	
		p_um  		db  '01 - Dois$',0
		p_dez  		db  '10 - Tres$',0
		p_onze  	db  '11 - Quatro$',0

		conta 		db 0

		POSy 		db 0

		 POStrY			db		3	; a linha pode ir de [1 .. 25]
		POStrX			db		17	; POStrX pode ir [1..80]	
		str_bonus		db 		'000$',0					;STR com o nome do jogador
    	NUMDIG			db			0	; controla o numero de digitos do numero lido
		MAXDIG			db			3	; Constante que define o numero MAXIMO de digitos a ser aceite

dseg    	ends

cseg		segment para public 'code'
		assume  cs:cseg, ds:dseg

LE_TECLA    PROC

        mov     ah,08h
        int     21h
        mov     ah,0
        cmp     al,0
        jne     SAI_TECLA
        mov     ah, 08h
        int     21h
        mov     ah,1
SAI_TECLA:  RET
LE_TECLA    endp



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

converter  proc

number: cmp al, '0'
		jb exit
		cmp al, '9'
		ja uppercase
		sub al, 30h
		call process
		jmp exit

uppercase: 	cmp al, 'A'
	   		 jb exit
		    cmp al, 'F'
			ja lowercase
			sub al, 37h
			call process
			jmp exit

lowercase: 	cmp al, 'a'
			jb exit
			cmp al, 'f'
			ja exit
			sub al, 57h
			call process
			jmp exit

			

process: 	mov ch, 4
			mov cl, 3
			mov bl, al
			mov SI, 0

convert:	mov al, bl
			ror al, cl
			and al, 01
			add al, 30h

			;GOTO_XY 0, 22

			mov string[SI], al
			inc SI
			;mov ah, 02h
			;mov dl, al
			;int 21h

			dec cl
			dec ch
			jnz convert

			mov dl, 20h
			int 21h

exit:		
			ret
converter endp

le_bonus  proc
		mov		NUMDIG, 0			; inícia leitura de novo número
		mov		cx, 5			
		XOR		BX,BX


		xor cx,cx
		mov POStrX, 41
		mov POStrY, 0
CICLO:	goto_xy POStrX, POStrY
		

		call 	LE_TECLA		; lê uma nova tecla
		cmp		ah,1			; verifica se é tecla extendida
		je		ESTEND
		CMP 	AL,27			; caso seja tecla ESCAPE sai do programa
		JE		fim
		cmp 	al, 'f'
		ja 		ciclo
		
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
		mov		str_bonus[bx],' '	; Retira um digito		
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
		MOV		str_bonus[bx], al		
		mov		ah,02h			; imprime digito 
		mov		dl,al			; na possicão do cursor
		int		21H

		inc		POStrX			; avança o cursor e
		inc		NUMDIG			; incrementa o numero de digitos

ESTEND:	jmp	CICLO			

OKNUM:	
		mov		bl,MAXDIG		; se atigido numero máximo de digitos ?	
		CMP		bl,NUMDIG
		jne		CICLO
			 
fim:	ret

le_bonus ENDP

trata_hex proc
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		GOTO_XY 20, 0
		MOSTRA str_bonus
		mov dh,0
		mov BP, 0			
looping:	
		mov al, str_bonus[BP]

		GOTO_XY 0, POSy
			mov ah, 02h
			mov dl, al
			int 21h
		inc POSy
		GOTO_XY 0, POSy
		call converter
		MOSTRA string


		mov al, string[0] 
		sub al, 30h
		MOV bl, 10
		mul bl

		mov n_dir, al

		mov al, string[1] 
		sub al, 30h

		
		add n_dir, al



passos:	mov al, string[2] 
		sub al, 30h
		MOV bl, 10
		mul bl

		mov n_pass, al

		mov al, string[3] 
		sub al, 30h

		
		add n_pass, al
		;add dir, 30h
		
		inc POSy
		goto_xy 0,POSy
		MOSTRA p_pass
		cmp n_pass, 0
		jne p_um1
		MOSTRA p_zero
		jmp cont
p_um1:	cmp n_pass, 1
		jne p_dez1
		MOSTRA p_um
		jmp cont
p_dez1:	cmp n_pass, 10
		jne p_onze1
		MOSTRA p_dez
		jmp cont
p_onze1:	cmp n_pass, 11
		jne fim
		MOSTRA p_onze
		
cont:
		inc conta
		mov dh, conta
		cmp dh, 3
		je fim


		inc BP
		inc POSy
		inc POSy
		

		jmp looping
fim:
		ret
trata_hex endp

main		proc
		mov     ax, dseg
		mov     ds, ax

		mov	ax,0B800h
		mov	es,ax					; es é ponteiro para mem video

		call apaga_ecran
		
		GOTO_XY 0, 0
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		
			
ciclo:		
		call le_bonus
		cmp al, 27
		je fim
		GOTO_XY 10, 0
		MOSTRA str_bonus
		call trata_hex
		jmp ciclo
fim:
	;call apaga_ecran
	mov		ah,4CH
	INT		21H
		
main		endp
cseg    	ends
end     	Main