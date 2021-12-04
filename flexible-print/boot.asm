; Pasecinic Nichita
; FAF - 192
; 19.11.2021

[org 0x7c00] ; set origin offset at 0x7c00

; First default text print
mov bx, text ; save to bx the pointer to variable 'text'
mov ah, 0Eh  ; teletype output	

; loop like while true
loop:   
    mov al, [bx] ; defer bx to al
    cmp al, 0    ; if al is termial (0) char : go to second procedure
    je second      
    int 10h      ; BIOS video service
    inc bx       ; increment bx to point to next char in string
    jmp loop     ; loop again


; Draw a rectangle from alphabet letters using different background and foreground colors
; A ..... Z
; .       .
; .       .
; N       N
; A ..... Z

; prints a vertical line, starting from row - 3 and col - 3
; red text on green background
second:
    ; change cursor position
    mov ah, 02h ; FUNCTION: Set cursor position	
    mov bh, 0 ; set page number
    mov dh, 3 ; set row
    mov dl, 3 ; set column
    int 10h ; BIOS video service

    mov al, 64 ; A in decimal is 65, so we need to start looping from 64

    loop1:
        mov ah, 09h ; FUNCTION: Write Character and Attribute at Cursor
        inc al ; increment al (al++)
        cmp al, 'Z' + 1 ; if is last letter that we need, go to next procedure 
        je third   

        mov bl, 24H ; red text on green background
        mov cx, 1 ; Number of times to print character - 1
        int 10h ; BIOS video service

        ; increment cursor position
        mov ah, 02h ; FUNCTION: Set cursor position	
        mov bh, 0   ; page nr
        inc dl      ; increment column for cursor position
        int 10h     ; BIOS video service
        jmp loop1   ; loop again


; similar as previous just it is a vertical line from A to N (A - Z will form a rectangle)
; col 3, row 3
; A - to N
; light cyan text on light red background
third:
    mov ah, 02h 
    mov bh, 0 
    mov dh, 3 
    mov dl, 3 
    int 10h 

    mov al, 64 

    loop2:

        mov ah, 09h 
        inc al 
        cmp al, 'N' + 1 
        je fourth   

        mov bl, 1100_1011b 
        mov cx, 1 
        int 10h

        mov ah, 02h 
        mov bh, 0
        inc dh      
        int 10h
        jmp loop2

; vertical A - O
; white background and black text
fourth:
    mov ah, 02h 
    mov bh, 0 
    mov dh, 3 
    mov dl, 29 
    int 10h 

    mov al, 64 
    loop3:
        mov ah, 09h 
        inc al 
        cmp al, 'O' + 1 
        je fifth   

        mov bl, 1111_0000b
        mov cx, 1 
        int 10h 

        mov ah, 02h 
        mov bh, 0
        inc dh      
        int 10h
        jmp loop3


; horizontal A - Z
; yellow text on blue background
fifth:
    mov ah, 02h 
    mov bh, 0 
    mov dh, 17 
    mov dl, 3 
    int 10h 

    mov al, 64 
    loop4:
        mov ah, 09h 
        inc al 
        cmp al, 'Z' + 1 
        je exit   

        mov bl, 1EH 
        mov cx, 1 
        int 10h 

        mov ah, 02h 
        mov bh, 0
        inc dl     
        int 10h
        jmp loop4

exit:
    hlt ; halt execution until wake up

text:
    db "real programmers can write assembly code in any language!", 0 ; define bytes, with 0 as terminal char


; Mark the device as bootable
; Add any additional zeroes to make 510 bytes in totals
times 510-($-$$) db 0 ; repead instruction define bytes (db) 510-($-$$) times
; $$ - beginning of the current section
; $-$$ = length of the previous code = 3
; 3 + (510 - 3) = 510
db 0x55, 0xaa ; Write the final 2 bytes as the magic number 0x55aa, remembering x86 little endian