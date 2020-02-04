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
    grub-mkrescue -o os.iso isodir
    qemu-system-i386 -cdrom os.iso -d cpu_reset,int -D log.log
    #bochs
else
  echo the file is not multiboot
fi