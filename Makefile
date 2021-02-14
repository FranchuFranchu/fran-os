CC = /usr/local/cross/bin/i686-elf-gcc
ASSEMBLER_FLAGS = -Imacros/




all: os_grub

src/boot.o: src/boot.asm
	nasm $(ASSEMBLER_FLAGS) -felf32 src/boot.asm -o src/boot.o

src/kernel.o: $(shell find src -name "*.asm" | sed -e 's/ /\\ /' | tr "\n" " " )
	nasm $(ASSEMBLER_FLAGS) -felf32 src/kernel.asm -o src/kernel.o -Isrc/

disk-images/os_kernel.img: src/kernel.o src/boot.o
	$(CC) -T linker.ld -o disk-images/os_kernel.img -ffreestanding -O2 -nostdlib src/boot.o src/kernel.o -lgcc

mountdir:
	sudo mount -o loop disk-images/os_hdb.img tmp-loop
	sudo chown -R $(USER) tmp-loop
	cat /dev/stdin | head -n 0
	sudo umount tmp-loop || exit
	
.PHONY: imount
imount: 
	sudo mount -o loop disk-images/os_hdb.img tmp-loop
	sudo chown -R $(USER) tmp-loop
	bash -c "echo Press any key to unmount...; read" 
	sudo chown -R root tmp-loop
	sudo umount tmp-loop || exit

disk-images/os_hdb.img: $(shell find guest-filesystem)
	- rm disk-images/os_hdb.img
	dd status=noxfer conv=notrunc if=/dev/zero of=disk-images/os_hdb.img bs=32256 count=16
	mkfs.ext2 disk-images/os_hdb.img
	# Mount it 
	rm -rf tmp-loop
	mkdir tmp-loop

	sudo mount -o loop disk-images/os_hdb.img tmp-loop
	sudo chown -R $(USER) tmp-loop
	cp -r guest-filesystem/* tmp-loop
	sudo chown -R root tmp-loop

	sudo umount tmp-loop || exit


isodir/boot/os_grub.bin: disk-images/os_kernel.img
	mkdir -p isodir/boot/grub
	cp disk-images/os_kernel.img isodir/boot/os_grub.bin

disk-images/os_hda.img: isodir/boot/os_grub.bin
	grub-mkrescue -o disk-images/os_hda.img isodir

clear_images:
	rm disk-images/*


.PHONY: macros
macros:
	make -C macros
	make -C guest-filesystem/core_packages

.PHONY: os_grub
.PHONY: os_kernel
	
os_grub: macros disk-images/os_hda.img disk-images/os_hdb.img
os_kernel: macros disk-images/os_kernel.img disk-images/os_hdb.img


bochs: os_grub
	bochs -f bochsrc

qemu: os_kernel
	qemu-system-i386 \
        -monitor stdio \
        -kernel disk-images/os_kernel.img \
        -drive file=disk-images/os_hdb.img,format=raw,index=1,media=disk \
        -d int,guest_errors \
        -D log.log \
        -m 64M \
        -serial file:serial.log 

qemugdb: os_kernel
	gnome-terminal -- gdb --eval-command="target remote localhost:1234"
	qemu-system-i386   \
        -s \
        -kernel disk-images/os_kernel.img \
        -drive file=disk-images/os_hdb.img,format=raw,index=1,media=disk \
        -d int,guest_errors \
        -D log.log \
        -m 64M \
        -serial file:serial.log
	