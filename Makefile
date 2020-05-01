CC = /usr/local/cross/bin/i686-elf-gcc
GUEST_FILES_ = $(shell find guest-filesystem)
GUEST_FILES = $(shell echo $(GUEST_FILES_) | tr "\n" " ")

src/boot.o: src/boot.asm
	nasm -felf32 src/boot.asm -o src/boot.o

src/kernel.o: src/kernel.asm src/features/* src/features/storage/*
	nasm -felf32 src/kernel.asm -o src/kernel.o -Isrc/

guest-filesystem/test.bin: guest-filesystem/test.asm
	nasm guest-filesystem/test.asm -o guest-filesystem/test.bin

disk-images/os_kernel.img: src/kernel.o src/boot.o
	$(CC) -T linker.ld -o disk-images/os_kernel.img -ffreestanding -O2 -nostdlib src/boot.o src/kernel.o -lgcc

disk-images/os_hdb.img: $(GUEST_FILES)
	rm disk-images/os_hdb.img
	dd status=noxfer conv=notrunc if=/dev/zero of=disk-images/os_hdb.img bs=32256 count=16
	mkfs.ext2 disk-images/os_hdb.img
	# Mount it 
	rm -rf tmp-loop
	mkdir tmp-loop

	sudo mount -o loop disk-images/os_hdb.img tmp-loop
	sudo chown -R $(USER) .
	cp -r guest-filesystem/* tmp-loop

	sudo umount tmp-loop || exit


isodir/boot/os.bin: disk-images/os_kernel.img
	mkdir -p isodir/boot/grub
	cp disk-images/os_kernel.img isodir/boot/os.bin

disk-images/os_hda.img: isodir/boot/os.bin
	grub-mkrescue -o disk-images/os_hda.img isodir

os: disk-images/os_hda.img disk-images/os_hdb.img
	

bochs: os
	bochs -f bochsrc

qemu: os
	qemu-system-i386   \
        -monitor stdio \
        -drive file=disk-images/os_hda.img,format=raw,index=0,media=disk \
        -drive file=disk-images/os_hdb.img,format=raw,index=1,media=disk \
        -d int,guest_errors \
        -D log.log \
        -m 64M