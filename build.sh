cd src/bootloader

nasm stage1.asm -o stage1.bin || exit
nasm stage2.asm -o stage2.bin || exit
cd ..

nasm boot.asm   -o boot.bin || exit
#exit
cd ..

dd status=noxfer conv=notrunc if=/dev/zero of=disk_images/os_hda.img count=256

dd status=noxfer conv=notrunc if=src/bootloader/stage1.bin of=disk_images/os_hda.img || exit


dd status=noxfer conv=notrunc if=src/bootloader/stage2.bin seek=1 of=disk_images/os_hda.img || exit

dd status=noxfer conv=notrunc if=src/boot.bin of=disk_images/os_hdb.img || exit

#qemu-img dd if=disk_images/os.img of=disk_images/os.img 

#parted -a none disk_images/os.img mkpart primary 33280B 130048B

qemu-system-i386 -drive file=disk_images/os_hda.img,format=raw,index=0,media=disk -drive file=disk_images/os_hdb.img,format=raw,index=1,media=disk -d int,guest_errors -D log.log
#bochs -f bochsrc
