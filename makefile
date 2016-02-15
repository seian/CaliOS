all: bootloadersection disk.img

bootloadersection:
	@echo
	@echo ======== Build Boot Loader ========
	@echo

	make -C bootloader

	@echo
	@echo ======== Build Complete ========
	@echo

disk.img: bootloader/bootloader.bin
	@echo
	@echo ======== Disk Image Build ========
	@echo

	cp bootloader/bootloader.bin disk.img

	@echo
	@echo ====== All Build Complete ========
	@echo

clean:
	make -C bootloader clean
	rm -f disk.img
