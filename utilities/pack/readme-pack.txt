Instructions for installing PACK on Alcor C
-------------------------------------------

Compile:     pack/c into pack/o
Compile    unpack/c into unpack/o
Compile    fileno/c into fileno/o
Assemble objcat/asm
do:        objcat   pack/o fileno/o pack/obj
           objcat unpack/o fileno/o unpack/obj

Then: RUNC pack filename

