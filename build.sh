cd src/bootloader

nasm stage1.asm -o stage1.bin || exit
nasm stage2.asm -o stage2.bin || exit
cd ..

nasm boot.asm   -o boot.bin || exit
#exit
cd ..

#dd status=noxfer conv=notrunc if=/dev/zero of=os.img count=256

dd status=noxfer conv=notrunc if=src/bootloader/stage1.bin of=os.img || exit
dd status=noxfer conv=notrunc if=src/bootloader/stage2.bin seek=1 of=os.img || exit
dd status=noxfer conv=notrunc if=src/boot.bin seek=16 of=os.img || exit

hexdump os.img
qemu-system-i386 -hda os.img -d int,guest_errors
#bochs -f bochsrc
