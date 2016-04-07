#include "page.h"
#include "types.h"
#include "modeswitch.h"

void kPrintString(int x, int y, const char *str);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

void main(void) {
    DWORD i;
    DWORD dwEAX, dwEBX, dwECX, dwEDX;
    char vcVendorString[13] = {0,};

    kPrintString(0, 4, "[SUCCESS] C KERNEL MODE");
    kPrintString(0, 5, "[INFO]    IA-32e MODE ENTRY");

    if(kIsMemoryEnough() == FALSE) {
        kPrintString(0,6, "[FAILURE] NOT ENOUGH MEMORY");
        while(1);
    }
    kPrintString(0, 6, "[SUCCESS] IA-32e Memory Check Completed");

    if(kInitializeKernel64Area() == FALSE) {
        kPrintString(0,7, "[FAILURE] KERNEL MEMORY INIT");
        while(1);
    }

    kPrintString(0, 7, "[SUCCESS] IA-32e Kernel Init Completed");

    kInitializePageTables();

    kPrintString(0, 8, "[SUCCESS] IA-32e Page Tables Initialized");

    kReadCPUID(0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX);
    *(DWORD*)vcVendorString = dwEBX;
    *((DWORD*)vcVendorString + 1) = dwEDX;
    *((DWORD*)vcVendorString + 2) = dwECX;

    kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);

    if(dwEDX & (1 << 29)) {
        kPrintString(0, 9, "[SUCCESS] 64bit support check");
    } else {
        kPrintString(0, 9, "[FAILURE] CPU doesn't support 64bit");
    }

    while(1);
}

void kPrintString(int x, int y, const char *str) {
    CHARACTER* pstScreen = (CHARACTER *)0xB8000;
    int i;

    pstScreen += (y * 80) + x;

    for(i=0;str[i] != 0; i++) {
        pstScreen[i].bCharacter = str[i];
    }
}

BOOL kInitializeKernel64Area(void) {
    DWORD* pdwCurrentAddress;

    pdwCurrentAddress = (DWORD*)0x100000;

    while((DWORD)pdwCurrentAddress < 0x600000) {
        *pdwCurrentAddress = 0x00;
        if(*pdwCurrentAddress != 0) {
            return FALSE;
        }
        pdwCurrentAddress++;
    }

    return TRUE;
}

BOOL kIsMemoryEnough(void) {
    DWORD* pdwCurrentAddress;
    pdwCurrentAddress = (DWORD *)0x100000;
    while((DWORD)pdwCurrentAddress < 0x4000000) {
        *pdwCurrentAddress = 0x12345678;
        if(*pdwCurrentAddress != 0x12345678) return FALSE;
        pdwCurrentAddress += (0x10000/4);
    }
    return TRUE;
}
