#!/bin/bash

if test "`whoami`" != "root" ; then
    echo "You must be logged in as root to build (for loopback mounting)"
    echo "Enter 'sudo bash' or 'sudo ./build.sh' to switch to root"
    exit
fi

cd src/bootloader

nasm stage1.asm -o stage1.bin || exit
nasm stage2.asm -o stage2.bin || exit
cd ..

nasm boot.asm   -o kernel.bin || exit

cd ..


# Copy stuff
cp src/kernel.bin guest-filesystem/kernel.bin

rm disk-images/*

dd status=noxfer conv=notrunc if=src/bootloader/stage1.bin of=disk-images/os_hda.img || exit
dd status=noxfer conv=notrunc if=src/bootloader/stage2.bin seek=1 of=disk-images/os_hda.img || exit

# Make filesystem disk
dd status=noxfer conv=notrunc if=/dev/zero of=disk-images/os_hdb.img bs=1K count=1024
mkfs.ext2 disk-images/os_hdb.img

# Mount it 
rm -rf tmp-loop
mkdir tmp-loop
mount -o loop disk-images/os_hdb.img tmp-loop

cp -r guest-filesystem/* tmp-loop

umount tmp-loop || exit



#qemu-img dd if=disk-images/os.img of=disk-images/os.img 

#parted -a none disk-images/os.img mkpart primary 33280B 130048B

qemu-system-i386 -monitor stdio -drive file=disk-images/os_hda.img,format=raw,index=0,media=disk -drive file=disk-images/os_hdb.img,format=raw,index=1,media=disk -d int,guest_errors -D log.log
#bochs -f bochsrc
