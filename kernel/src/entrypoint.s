[ORG 0x00]
[BITS 16]

SECTION .text

START:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    cli

    lgdt [GDTR]

    mov eax, 0x4000003B
    mov cr0, eax

    jmp dword 0x08: (PROTECTEDMODE - $$ + 0x10000)


[BITS 32]
PROTECTEDMODE:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    push (PROTECTEDMODEENTRYMSG - $$ + 0x10000)
    push 3
    push 0
    call .PRINTMSG
    add  esp, 0x0C

    jmp  $

.PRINTMSG:
    push ebp
    mov  ebp, esp

    push esi
    push edi
    push eax
    push ecx
    push edx

    mov eax, dword[ebp + 0x0C]
    mov esi, 0xA0
    mul esi
    mov edi, eax

    mov eax, dword[ebp + 0x08]
    mov esi, 0x02
    mul esi
    add edi, eax

    mov esi, dword[ebp + 0x10]

.MSGLOOP:
    mov cl, byte[esi]
    cmp cl, 0
    je  .MSGEND

    mov byte[edi + 0xB8000], cl

    add esi, 0x01
    add edi, 0x02

    jmp .MSGLOOP

.MSGEND:
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret

align 0x08, db 0

dw 0x0000

GDTR:
    dw GDTEND - GDT - 1
    dd (GDT - $$ + 0x10000)


GDT:
    NULLDescriptor:
        dw 0x0000   ; segment size[15:0]
        dw 0x0000   ; base address[15:0]
        db 0x00     ; base address[23:16]
        db 0x00     ; P, DPL, S, TYPE
        db 0x00     ; G, D/B, L, AVL, Segment Size
        db 0x00     ; base address

    CODEDESCRIPTOR:
        dw 0xFFFF   ; segment size
        dw 0x0000   ; base address[15:0]
        db 0x00     ; base address[23:16]
        db 0x9A     ; P=1, DPL=0, Code Segment, Execute/Read
        db 0xCF     ; G=1, D=1, L=0, Limit[19:16]
        db 0x00     ; Base [31:24]

    DATADESCRIPTER:
        dw 0xFFFF   ; segment size
        dw 0x0000   ; base address[15:0]
        db 0x00     ; base address[23:16]
        db 0x92     ; P=1, DPL=0, Data Segment, Execute/Read
        db 0xCF     ; G=1, D=1, L=0, Limit[19:16]
        db 0x00     ; Base [31:24]
GDTEND:

PROTECTEDMODEENTRYMSG: db '[SUCCESS] Protected Mode Loaded', 0


times 512 - ($ - $$) db 0x00
