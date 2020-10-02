AStack SEGMENT STACK
        DW 100h DUP(5353H)
AStack ENDS
DATA SEGMENT 
VERS db 'Number of main version=  .   ',0DH,0AH,'$'
OEM      db'Serial number OEM:                  ',0DH,0AH,'$'
USER     db'24 byte serial number:      H',0DH,0AH,'$'

TYPE1 db 'The type of IBM is PC',0DH,0AH,'$'
TYPE2 db 'The type of IBM is PC/XT',0DH,0AH,'$'
TYPE3 db 'The type of IBM is PS2 model 30',0DH,0AH,'$'
TYPE4 db 'The type of IBM is AT or PS2 model 50 or 60',0DH,0AH,'$'
TYPE5 db 'The type of IBM is PS2 model 80',0DH,0AH,'$'
TYPE6 db 'The type of IBM is PCjr',0DH,0AH,'$'
TYPE7 db 'The type of IBM is PC Convertible',0DH,0AH,'$'

DATA ENDS
TESTPC SEGMENT
	ASSUME CS:TESTPC, DS:DATA, ES:NOTHING, SS:AStack
START: JMP BEGIN

TETR_TO_HEX PROC near 
and AL,0Fh
 cmp AL,09
 jbe NEXT1
 add AL,07
NEXT1: add AL,30h
 ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near
 push CX
 mov AH,AL
 call TETR_TO_HEX
 xchg AL,AH
 mov CL,4
 shr AL,CL
 call TETR_TO_HEX 
 pop CX 
 ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
 push BX
 mov BH,AH
 call BYTE_TO_HEX
 mov [DI],AH
 dec DI
 mov [DI],AL
 dec DI
 mov AL,BH
 call BYTE_TO_HEX
 mov [DI],AH
 dec DI
 mov [DI],AL
 pop BX
 ret
WRD_TO_HEX ENDP

BYTE_TO_DEC PROC near
 push CX
 push DX
 xor AH,AH
 xor DX,DX
 mov CX,10
loop_bd: div CX
 or DL,30h
 mov [SI],DL
 dec SI
 xor DX,DX
 cmp AX,10
 jae loop_bd
 cmp AL,00h
 je end_l
 or AL,30h
 mov [SI],AL
end_l: pop DX
 pop CX
 ret
 
BYTE_TO_DEC ENDP
BEGIN:
	push DS
	sub AX,AX
	push AX
	mov AX,DATA
	mov DS, AX
	mov ax,0F000h
	mov es,ax
	mov al,es:[0FFFEh]
	
	cmp al,00FFh
	je Wt1
	cmp al,00FEh
	je Wt2
	cmp al,00FBh
	je Wt2
	cmp al,00FCh
	je Wt4
	cmp al,00FAh
	je Wt3
	cmp al,00F8h
	je Wt5
	cmp al,00FDh
	je Wt6
	cmp al,00F9h
	je Wt7
	Wt1:	
		mov DX,offset TYPE1
		mov AH,09h
		int 21h
		jmp next
	Wt2:	
		mov DX,offset TYPE2
		mov AH,09h
		int 21h
		jmp next
	Wt3:	
		mov DX,offset TYPE3
		mov AH,09h
		int 21h
		jmp next
	Wt4:	
		mov DX,offset TYPE4
		mov AH,09h
		int 21h
		jmp next
	Wt5:	
		mov DX,offset TYPE5
		mov AH,09h
		int 21h
		jmp next
	Wt6:	
		mov DX,offset TYPE6
		mov AH,09h
		int 21h
		jmp next
	Wt7:	
		mov DX,offset TYPE7
		mov AH,09h
		int 21h
		jmp next	
	next:
	
	mov ah,30h
	int 21h
	mov si, offset VERS
	add si, 24
	call BYTE_TO_DEC		
	mov si, offset  VERS
	add si, 27
	mov al,ah
	call BYTE_TO_DEC
	
	mov DX,offset VERS
	mov AH,09h
	int 21h	
	
	mov ah, 30h 
    int 21h
    mov al, bh
    
	mov si, offset OEM
    add si, 21
    call BYTE_TO_DEC

    mov ax, cx	
    mov di, offset USER
    add di, 27
    call WRD_TO_HEX
    mov al, bl
    call BYTE_TO_HEX
    mov di, offset USER 
    add di, 22
	
    mov [di], ax
	mov DX,offset OEM
	mov AH,09h
	int 21h
	
	mov DX,offset USER
	mov AH,09h
	int 21h		
	
	xor AL,AL
	mov AH,4Ch
	int 21H
TESTPC ENDS
 END START ;