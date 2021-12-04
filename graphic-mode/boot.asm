org 0x7C00   ; add 0x7C00 to label addresses
bits 16      ; tell the assembler we want 16 bit code

mov ah, 0    ; set display mode
mov al, 13h  ; 13h = 320x200
int  0x10

; square 
mov si, 20     ; x - length
mov di, 20     ; y - lenght
mov al, 5      ; color - magenta
mov cx, 10     ; x - start position
mov dx, 10     ; x - start position
call drawBox

; rectangle
mov si, 40     
mov di, 10     
mov al, 11     ; color - cyan
mov cx, 50    
mov dx, 50    
call drawBox

drawBox:
	push si               ; save x-length
	.for_x:
		push di           ; save y-length
		.for_y:
			pusha
			mov bh, 0     ; page number (0 is default)
			add cx, si    ; cx = x-coordinate
			add dx, di    ; dx = y-coordinate
			mov ah, 0xC   ; write pixel at coordinate
			int 0x10      ; draw it
			popa
		sub di, 1         ; decrease di by one and set flags
		jnz .for_y        ; repeat for y-length times
		pop di            ; restore di to y-length
	sub si, 1             ; decrease si by one and set flags
	jnz .for_x            ; repeat for x-length times
	pop si                ; restore si to x-length  -> starting state restored
	ret

times 510-($-$$) db 0
dw 0xaa55 ; some BIOSes require this signature