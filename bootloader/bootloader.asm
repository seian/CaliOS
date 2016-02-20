[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START        ; move to START label

; SUCCESS MESSAGES
MBRINITMSG:     db '[SUCCESS] Master Boot Record init', 0
DISKCOMPLMSG:   db '[SUCCESS] Disk Loading Completed', 0

; INFO MESSAGES
DISKINITMSG:    db '[INFO]    Loading Disk', 0

; ERROR MESSAGES
DISKERRMSG:     db '[ERROR]   Disk Loading Failure', 0

; GLOBAL ENV VALUES
TOTALSECTORCOUNT:   dw  1024

; DISK Loaders
SECTORNUMBER:   db  0x02
HEADNUMBER:     db  0x00
TRACKNUMBER:    db  0x00



START:
    mov ax, 0x07C0      ; boot segment address
    mov ds, ax          ; set boot address to DS segment register
    mov ax, 0xB800      ; video memory address
    mov es, ax          ; set video memory address to ES register

    ; stack : 0x0000:0000 ~ 0x0000:FFFF, 64kb
    mov ax, 0x0000
    mov ss, ax
    mov ax, 0xFFFE
    mov sp, ax          ; set SP register as 0xFFFE
    mov bp, ax          ; set BP register as 0xFFFE

    mov si, 0x00        ; initiate character index register


.MBRSECTIONMSGCLEAR:
    mov byte[es : si], 0x00
    mov byte[es : si + 0x01], 0x0A

    add si, 0x02

    cmp si, 80 * 25 * 2
    jl  .MBRSECTIONMSGCLEAR

    mov si, 0x00
    mov di, 0x00

.MBRSECTIONMSGPRINT:    ; in reverse order (parameter call)
                        ; PRINT(x, y, msg)
    push MBRINITMSG     ; msg
    push 0              ; y
    push 0              ; x
    call PRINTMESSAGE
    add  sp, 0x06       ; 3 parameters * word size(2)

.DISKLOADMSGPRINT:
    push DISKINITMSG    ; msg
    push 1              ; y
    push 0              ; x
    call PRINTMESSAGE
    add  sp, 0x06       ; 3 parameters * word size(2)

.DISKINIT:
    ; service number 0, driver number 0 for Floppy
    mov ax, 0x00
    mov dl, 0x00    ; Floppy Disk

    int 0x13
    jc  DISKERRORHANDLER

    mov si, 0x1000      ; set address(ES:BX) to copy disk
    mov es, si
    mov bx, 0x0000      ; set offset

    mov di, word[TOTALSECTORCOUNT]

.READDATA:
    cmp di, 0
    je .READEND

    sub di, 0x01                ; decrease number of sectors

    mov ah, 0x02                ; mode for reading
    mov al, 0x01                ; number of sectors to read
    mov ch, byte[TRACKNUMBER]   ; CH for number of tracks
    mov cl, byte[SECTORNUMBER]  ; CL for number of sectors
    mov dh, byte[HEADNUMBER]    ; DH for number of heads
    mov dl, 0x00                ; Floppy Disk

    int 0x13                    ; disk loading error interrupt
    jc  DISKERRORHANDLER

    add si, 0x0020              ; segment register:offset
                                ; multiply 16bits * 0x010
    mov es, si

    mov al, byte[SECTORNUMBER]
    add al, 0x01
    cmp al, 0x13
    jl .READDATA

    xor byte[HEADNUMBER], 0x01
    mov byte[SECTORNUMBER], 0x01

    cmp byte[HEADNUMBER], 0x00  ; if not equals with 0
    jne .READDATA

.READEND:
    push DISKCOMPLMSG
    push 2
    push 0
    call PRINTMESSAGE
    add  sp, 0x06

    ;;;;;;;;;;;;;;;;;;;;;
    jmp  0x1000:0x0000 ;; load OS image
    ;;;;;;;;;;;;;;;;;;;;;

DISKERRORHANDLER:
    push DISKERRMSG
    push 4
    push 0
    call PRINTMESSAGE
    add sp, 0x06

    jmp $               ; Program Halts here

PRINTMESSAGE:
    push bp             ; stack
                        ; _______
                        ; | msg | bp+0x08
                        ; |  y  | bp+0x06
                        ; |  x  | bp+0x04
                        ; | ret | return address (bp+0x02)
                        ; |__bp_|
    mov  bp, sp

    push es
    push si
    push di
    push ax
    push cx
    push dx

    mov ax, 0xB800      ; set video memory address to ES register
    mov es, ax

    ; y coord
    mov ax, word[bp + 0x06]     ; parameter 2(y)
    mov si, 160                 ; 80 characters * 2 for a char
    mul si                      ; multiply si with ax
    mov di, ax                  ; value y

    ; x coord
    mov ax, word[bp + 0x04]
    mov si, 0x02                ; 2bytes for a character
    mul si
    add di, ax                  ; final axis

    mov si, word[bp + 0x08]     ; msg

.MSGLOOP:
    mov cl, byte[si]
    cmp cl, 0
    je  .MESSAGEEND

    mov byte[es:di], cl         ; ES for video memory address

    add si, 0x01
    add di, 0x02

    jmp .MSGLOOP

.MESSAGEEND:
    pop dx
    pop cx
    pop ax
    pop di
    pop si
    pop es
    pop bp
    ret




times 510 - ($ - $$)    db 0x00
dw 0xAA55
