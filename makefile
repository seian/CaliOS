all: bootloadersection Kernel32 disk.img

bootloadersection:
	@echo
	@echo ======== Build Boot Loader ========
	@echo

	make -C bootloader

	@echo
	@echo ======== Build Complete ========
	@echo

Kernel32:
	@echo
	@echo ======== Build Boot Loader ========
	@echo

	make -C kernel

	@echo
	@echo ======== Build Complete ========
	@echo


disk.img: bootloader/bootloader.bin kernel/bin/kernel32.bin
	@echo
	@echo ======== Disk Image Build ========
	@echo

	cat $^ > disk.img

	@echo
	@echo ====== All Build Complete ========
	@echo

clean:
	make -C bootloader clean
	make -C kernel clean
	rm -f disk.img
