> Pasecinic Nichita

#### **Notes**

NASM version 2.14.02 compiled on Dec 26 2018

#### Commands

```bash
$ nasm -f bin file_name.asm -o file_name.bin # create .bin file
$ nasm -f bin file_name.asm -o file_name.img # create a image that could be runned on the floppy disk as a SO
$ qemu-system-x86_64 file_name.bin           # simple floppy disk emulator with qemu
```
