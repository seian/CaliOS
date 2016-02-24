BASE	  = /opt/cross/bin/
NASM32    = nasm
GCC32     = x86_64-pc-linux-gcc -c -m32 -ffreestanding
LD32	  = x86_64-pc-linux-ld -melf_i386 -T ../elf_i386.x-edited -nostdlib -e main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

OBJECTDIRECTORY = tmp
SOURCEDIRECTORY = src

all: prepare kernel32.bin

prepare:
	mkdir -p $(OBJECTDIRECTORY)

$(OBJECTDIRECTORY)/entrypoint.bin: $(SOURCEDIRECTORY)/entrypoint.s
		$(NASM32) -o $@ $<

dep:
	@echo === MAKING DEPENDENCY FILE ===
	make -C $(OBJECTDIRECTORY) -f ../makefile InternalDependency
	@echo === DEPENDENCY COMPLETE ===

ExecuteInternalBuild: dep
	make -C $(OBJECTDIRECTORY) -f ../makefile kernel32.elf

$(OBJECTDIRECTORY)/kernel32.elf.bin: ExecuteInternalBuild
	$(BASE)$(OBJCOPY32) $(OBJECTDIRECTORY)/kernel32.elf $@

kernel32.bin: $(OBJECTDIRECTORY)/entrypoint.bin $(OBJECTDIRECTORY)/kernel32.elf.bin
	cat $^ > $@
clean:
	rm -f *.bin
	rm -f $(OBJECTDIRECTORY)/*.*


CENTRYPOINTOBJECTFILE = main.o
CSOURCEFILES = $(wildcard ../$(SOURCEDIRECTORY)/*.c)
ASSEMBLYSOURCEFILES = $(wildcard ../$(SOURCEDIRECTORY)/*.asm)
COBJECTFILES = $(subst main.o, , $(notdir $(patsubst %.c,%.o,$(CSOURCEFILES))))
ASSEMBLYOBJECTFILES = $(notdir $(patsubst %.asm,%.o,$(ASSEMBLYSOURCEFILES)))

%.o: ../$(SOURCEDIRECTORY)/%.c
	$(BASE)$(GCC32) -c $<

%.o: ../$(SOURCEDIRECTORY)/%.asm
	$(NASM32) -f elf32 -o $@ $<

InternalDependency:
	$(BASE)$(GCC32) -MM $(CSOURCEFILES) > Dependency.dep

kernel32.elf: $(CENTRYPOINTOBJECTFILE) $(COBJECTFILES) $(ASSEMBLYOBJECTFILES)
	$(BASE)$(LD32) -o $@ $^

ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif
