[BITS 32]

global kReadCPUID, kSwitchAndExecuted64bitKernel

SECTION .text

kReadCPUID:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov eax, dword[ebp+0x08]
    cpuid

    mov esi, dword[ebp+0x0C]
    mov dword[esi], eax

    mov esi, dword[ebp+0x10]
    mov dword[esi], ebx

    mov esi, dword[ebp+0x14]
    mov dword[esi], ecx

    mov esi, dword[ebp+0x18]
    mov dword[esi], edx

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret

kSwitchAndExecuted64bitKernel:
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

    mov eax, 0x100000
    mov cr3, eax

    mov ecx, 0xC0000080
    rdmsr

    or eax, 0x0100

    wrmsr

    mov eax, cr0
    or eax, 0xE0000000
    xor eax, 0x60000000
    mov cr0, eax

    jmp 0x08:0x200000

    jmp $
