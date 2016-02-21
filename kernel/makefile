all: Kernel32.bin

Kernel32.bin: src/entrypoint.s
	nasm -o bin/kernel32.bin $<

clean:
	rm -f bin/kernel32.bin
