
echo "" > log.log
cd src
nasm -felf32 boot.asm -o boot.o
if nasm -felf32 kernel.asm -o kernel.o; then
    echo "Built kernel"
else
    echo "Abort."
    exit 1
fi

PATH=$PATH:/usr/local/cross/bin

#i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
i686-elf-gcc -T ../linker.ld -o ../disk-images/os_hda.img -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
cd ..

rm disk-images/os_hdb.img
dd status=noxfer conv=notrunc if=/dev/zero of=disk-images/os_hdb.img bs=32256 count=16
mkfs.ext2 disk-images/os_hdb.img
# Mount it 
rm -rf tmp-loop
mkdir tmp-loop
mount -o loop disk-images/os_hdb.img tmp-loop

cp -r guest-filesystem/* tmp-loop

umount tmp-loop || exit


if grub-file --is-x86-multiboot disk-images/os_hda.img; then
  echo multiboot confirmed

    mkdir -p isodir/boot/grub
    cp disk-images/os_hda.img isodir/boot/os.bin
    grub-mkrescue -o disk-images/os_hda.img isodir
    qemu-system-i386 -monitor stdio -drive file=disk-images/os_hda.img,format=raw,index=0,media=disk -drive file=disk-images/os_hdb.img,format=raw,index=1,media=disk -d int,guest_errors -D log.log
    
    #bochs -f bochsrc
else
  echo the file is not multiboot
fi