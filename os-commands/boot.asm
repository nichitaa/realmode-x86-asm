; author <pasecinic.nichita>
; FAF 192
; 04.12.2021

org 0x7C00   ; add 0x7C00 to label addresses
bits 16      ; tell the assembler we want 16 bit code

; print OS welcome message
mov si, msg
call print

mainloop:
    ; print the prompt promptol 
    mov si, prompt
    call print 

    ; get user input and save it to buff
    mov di, buff
    call input 

    ; ignore blank lines (enters)
    mov si, buff
    cmp byte [si], 0 
    je mainloop

    ; handle help command
    mov si, buff
    mov di, help  
    call compare    ; compare user input with help command keyword
    jc .help_cmd    ; if carry flag is set go to the help command 

    ; handle about command
    mov si, buff
    mov di, about
    call compare
    jc .about_cmd

    ; handle time command
    mov si, buff
    mov di, time  
    call compare
    jc .time_cmd

    mov si, buff
    mov di, box 
    call compare 
    jc .draw_box

    ; else, show imvalid command helper message
    mov si, invalidMsg
    call print

    ; again to the main loop
    jmp mainloop

    ; --------------------------------------------------------------------------
    ; ---------------------------- command handlers ----------------------------
    ; --------------------------------------------------------------------------

    ; print the os about message
    .about_cmd:
        mov si, aboutMsg
        call print
        jmp mainloop

    ; print the os help message
    .help_cmd:
        mov si, helpMsg
        call print
        jmp mainloop

    ; will draw a square
    .draw_box:
        mov ah, 0               ; set display mode
        mov al, 13h             ; 13h = 320x200
        int 10h
        ; square configuration
        mov si, 20              ; x - length x == y
        mov di, 20              ; y - lenght x == y 
        mov al, 5               ; color - magenta
        mov cx, 10              ; x - start position
        mov dx, 10              ; x - start position
        push si                 ; save x-length
        .for_x:
            push di             ; save y-length
            .for_y:
                pusha
                mov bh, 0       ; page number (0 is default)
                add cx, si      ; cx = x-coordinate
                add dx, di      ; dx = y-coordinate
                mov ah, 0xC     ; write pixel at coordinate
                int 0x10        ; draw it
                popa
            sub di, 1           ; decrease di by one and set flags
            jnz .for_y          ; repeat for y-length times
            pop di              ; restore di to y-length
        sub si, 1               ; decrease si by one and set flags
        jnz .for_x              ; repeat for x-length times
        pop si   

        ; delay 1 second
        mov cx, 0fh
        mov dx, 4240h
        mov ah, 86h
        int 15h

        ; reset to default video mode
        mov ax, 0003h
        int 10h
        
        jmp mainloop            ; back to the mainloop

    ; print the os current time
    .time_cmd:
        mov ah, 02h              ; read sys time func
        int 0x1A                 ; read time

        mov al, ch               ; get hour
        shr al, 4                ; discard one's place for now
        add al, 48               ; add ASCII code of digit 0
        mov [timeMsg+0], al      ; set ten's place of hour in our time string template
        mov al, ch               ; get hour again
        and al, 0x0F             ; discard ten's place this time
        add al, 48               ; add ASCII code of digit 0 again
        mov [timeMsg+1], al      ; set one's place of hour in our time string template

        mov al, cl               ; get minute
        shr al, 4
        add al, 48
        mov [timeMsg+4], al      ; set ten's place of minute
        mov al, cl               ; get minute again
        and al, 0x0F
        add al, 48
        mov [timeMsg+5], al      ; set one's place of minute

        mov al, dh               ; get second
        shr al, 4
        add al, 48
        mov [timeMsg+8], al
        mov al, dh
        and al, 0x0F
        add al, 48
        mov [timeMsg+9], al

        ; print the system time
        mov si, timeMsg
        call print 

        ; back to the mainloop
        jmp mainloop


; compare the string from si witht the string from di
; if both are the same -> sets the carry flag so it could
; be used with jc (jump if condition is met)
compare:
    .loop:
        mov al, [si] ; byte from si
        mov bl, [di] ; byte from di
        cmp al, bl 
        jne .false  ; jmp to this if not equal 

        cmp al, 0
        je .true 

        inc di 
        inc si 
        jmp .loop 
    
    .false:
        clc       ; clear carry flag
        ret 

    .true:  
        stc       ; set carry flag
        ret


; gets the user input and stores it to buff
; if user pressed enter then the flow goes back to mainloop
input:
    xor cl, cl                      ; set cl to zero

    .loop:
        mov ah, 0                   ; read the keypress
        int 16h                     ; wait for keypress

        cmp al, 0x08                ; if backspase pressed 
        je .backspace               ; delete the last char

        cmp al, 0x0D                ; if enter pressed 
        je .done                    ; go to enter handler (done)

        cmp cl, 0x5                 ; if 5 chars were alreay inputted 
        je .loop                    ; allow backspace & enter

        mov ah, 0hE
        int 10h                     ; print the char

        stosb                       ; put character in buffer
        inc cl                      ; increment cl
        jmp .loop                   ; again read char
    
    ; backspace handler
    .backspace:
        cmp cl, 0                   ; if is beginning of string
        je .loop                    ; ingore the keypress

        dec di
        mov byte [di], 0            ; delete char
        dec cl                      ; decrement counter 

        mov ah, 0hE
        mov al, 0x08
        int 10h                     ; backspace

        mov al, ' '
        int 10h                     ; blank char

        mov al, 0x08
        int 10h                     ; backspace again

        jmp .loop                   ; go the input loop
    
    ; enter handler
    .done:
        mov al, 0	                ; null terminator
        stosb                       ; store string
        
        ; newline
        mov ah, 0Eh 
        mov al, 0x0D
        int 10h         
        mov al, 0x0A
        int 10h		                
        
        ret


; prints the string from si register
print:
    lodsb        ; load a bite from si

    or al, al    ; if al is 0
    jz .done     ; jump if zero to .done

    mov ah, 0hE 
    int 10h      ; print 

    jmp print

    .done:
        ret


; buffer for user input (max command is 5 chars long)
buff: times 5 db 0 

; custom commands keywords
help: db 'help', 0               
time: db 'time', 0
about: db 'about', 0
box: db 'box', 0

msg: db 'OS', 0x0D, 0x0A, 0
prompt: db '>', 0 
helpMsg: db 'available commands: help, about, time, box', 0x0D, 0x0A, 0
invalidMsg: db 'invalid command :( please use help command to list all commands', 0x0D, 0x0A, 0
aboutMsg: db ' SIMPLE OS :)', 0x0D, 0x0A, 0
timeMsg: db '00h:00m:00s', 0x0D, 0x0A, 0 ; time command string placehoder

times 510-($-$$) db 0
dw 0xaa55 ; some BIOSes require this signature