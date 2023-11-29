set -e

mkdir -p build
nasm -f elf32 -o build/lpfe.o src/lpfe.asm && ld -m elf_i386 -o lpfe build/lpfe.o
./lpfe $@