TESTPC SEGMENT
	ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
	ORG 100H
START: JMP BEGIN


MCB_TYPE db 'MCB Type - $'
MCB_SIZE db ' Size -       $'
SECTOR db ' Sector - $'
A_MEMORY db 'Available memory -        B.', 13, 10, '$'
X_MEMORY db 'Extended memory size -       B.', 13, 10, '$'
FREE db 'IS FREE $'
XMS db 'OS XMS UBM $'
DRIVER db 'IS DRIVER MEMORY $'
MS_DOS db 'MS DOS$'
OCCUPIED_MAX_UBM db 'OCCUPIED BY 386MAX UMB $'
BLOCKED_MAX_UBM db 'BLOCKED BY 386MAX UMB $'
MAX_UBM db '386MAX UMB $'
LAST_BYTES db ' Bytes. Last 8 bytes - $'
ENDLINE db 13, 10, '$'
MT db '$'

PRINT PROC near
    mov ah, 09h
    int 21h
    ret
PRINT endp

TETR_TO_HEX PROC near ;check
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP

BYTE_TO_HEX PROC near ;check
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

WORD_TO_DEC PROC near ;check
	push cx
	push dx
	mov cx, 10
loc_loop:
	div cx
	or dl, 30h
	mov [si], dl
	dec si
	xor dx, dx
	cmp ax, 0
	jnz loc_loop
end_loop:
	pop dx
	pop cx
	ret
WORD_TO_DEC ENDP

BEGIN:
	mov ah, 4ah
	mov bx, 0ffffh
	int 21h
	
	mov ax, bx
	mov cx, 16
	mul cx
	mov si, offset A_MEMORY + 24;;;
	call WORD_TO_DEC
	mov dx, offset A_MEMORY
	call PRINT

	xor ax, ax
	xor dx, dx
	mov al, 30h ; запись адреса ячейки CMOS
	out 70h, al
	in al, 71h  ; чтение младшего байта
	mov bl, al  ; расщиренной памяти
	mov al, 31h ; запись адреса ячейки CMOS
	out 70h, al
	in al, 71h  ; чтение старшего байта
				; размера расширенной памяти
	mov bh, al
	mov ax, bx
	mov si, offset X_MEMORY + 27
	call WORD_TO_DEC
	mov dx, offset X_MEMORY
	call PRINT
	
	xor ax, ax
	mov ah, 52h
	int 21h
	
	mov es, es:[bx-2]
FIND_TYPE_SECTOR:
	mov dx, offset MCB_TYPE
	call PRINT
	mov al, es:[0]
	
	call BYTE_TO_HEX
	mov CH, AH
	mov DL, AL
	mov AH, 02h
	int 21h
	mov DL, CH
	mov AH, 02h
	int 21h

	mov dx, offset SECTOR
	call PRINT
	mov ax, es:[1]
	mov dx, offset FREE 
	cmp ax, 0000h
	je FIND_SIZE
	mov dx, offset XMS 
	cmp ax, 0006h
	je FIND_SIZE
	mov dx, offset DRIVER 
	cmp ax, 0007h
	je FIND_SIZE
	mov dx, offset MS_DOS 
	cmp ax, 0008h
	je FIND_SIZE
	mov dx, offset OCCUPIED_MAX_UBM 
	cmp ax, 0fffah
	je FIND_SIZE
	mov dx, offset BLOCKED_MAX_UBM 
	cmp ax, 0fffdh
	je FIND_SIZE
	mov dx, offset MAX_UBM 
	cmp ax, 0fffeh
	je FIND_SIZE
	
	mov dx, offset MT
	xchg ah, al
	mov cl, ah

	push DX
	call BYTE_TO_HEX
	mov CH, AH
	mov DL, AL
	mov AH, 02h
	int 21h
	mov DL, CH
	mov AH, 02h
	int 21h
	pop DX

	mov al, cl

	push DX
	call BYTE_TO_HEX
	mov CH, AH
	mov DL, AL
	mov AH, 02h
	int 21h
	mov DL, CH
	mov AH, 02h
	int 21h
	pop DX
	
FIND_SIZE:
	call PRINT

	mov ax, es:[3]
	mov cx, 16
	mul cx
	mov si, offset MCB_SIZE + 13
	call WORD_TO_DEC
	mov dx, offset MCB_SIZE
	call PRINT
	mov dx, offset LAST_BYTES
	call PRINT
	
	mov cx, 8
	mov si, 8
	mov ah, 2
FIND_NEXT:
	mov dl, es:[si]
	int 21h
	inc si
	loop FIND_NEXT 
	
	mov dx, offset ENDLINE
	call PRINT
	mov al, es:[0]
	cmp al, 5ah
	je EXIT
	
	mov bx, es
	add bx, es:[3]
	inc bx
	mov es, bx
	jmp FIND_TYPE_SECTOR
EXIT:
	xor al, al
	mov ah, 4ch
	int 21h
TESTPC ENDS
	END START;