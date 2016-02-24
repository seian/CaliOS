all: bootloadersection Kernel32 imagemakersection disk.img

bootloadersection:
	@echo
	@echo ======== Build Boot Loader ========
	@echo

	make -C bootloader

	@echo
	@echo ======== Build Complete ========
	@echo


imagemakersection:
	@echo
	@echo ======== Image Maker Build ========
	@echo

	make -C imagemaker

	@echo
	@echo ====== Image Maker Build Complete ========
	@echo



Kernel32:
	@echo
	@echo ======== Build Boot Loader ========
	@echo

	make -C kernel

	@echo
	@echo ======== Build Complete ========
	@echo

disk.img: bootloader/bootloader.bin kernel/kernel32.bin
	@echo
	@echo ======== Disk Image Build ========
	@echo

	./imagemaker/imagemaker $^

	@echo
	@echo ====== All Build Complete ========
	@echo


clean:
	make -C bootloader clean
	make -C kernel clean
	make -C imagemaker clean
	rm -f disk.img
