
    cd src
nasm -felf32 boot.asm -o boot.o
if nasm -felf32 kernel.asm -o kernel.o; then
    echo "Built kernel"
else
    echo "Abort."
    exit 1
fi

#i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
i686-elf-gcc -T ../linker.ld -o ../os.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
cd ..

if grub-file --is-x86-multiboot os.bin; then
  echo multiboot confirmed

    mkdir -p isodir/boot/grub
    cp os.bin isodir/boot/os.bin
    grub-mkrescue -o os.img isodir

    # Delete partition 3 and 4
    parted os.img rm 3
    parted os.img rm 4

    # Complex gawk expression to extract free space

    FREESPACE=`parted os.img unit B print free | gawk 'match($0, /([[:digit:],]+[kMB]+)[[:space:]]+([[:digit:],]+[kMB]+)[[:space:]]+[[:digit:],]+[kMB]+[[:space:]]+Free Space$/, a) {print a[1]; print a[2]}'`
    PSTART=`echo $FREESPACE | gawk  '/([[:digit:],]+[kMB]+[[:space:]]+)/ {print $3}'`
    PEND=`echo $FREESPACE | gawk  '/([[:digit:],]+[kMB]+[[:space:]]+)/ {print $4}'`

    parted -a none os.img unit B mkpart primary ext2 $PSTART $PEND 
    parted os.img name 3 FranOS
    


    qemu-system-i386 -d cpu_reset,int -D log.log os.img
    #bochs -f bochsrc
else
  echo the file is not multiboot
fi