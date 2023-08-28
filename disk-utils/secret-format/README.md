# disk-utils/secret-format - Disk formatting programs

## format3 - Format a diskette with a secret extra sector

format3.asm formats a 40-track, single density diskette and adds a secret
sector numbered 128. The sector is only 16 bytes long, compared to the
usual 256, so extra programming effort is required to read this hidden
data.

According to the FD1771 datasheet at https://deramp.com/downloads/floppy_drives/FD1771%20Floppy%20Controller.pdf
there's a bit in the READ command which sets the interpretation of the
Sector Length field - multiples of 128 bytes for IBM 3740 compatibility
(the standard for TRS-80 diskettes), or multiples of 16 otherwise.

So to read a hidden sector, do roughly:

```
        LD      A,128
        LD      ($FDC_SECTOR),A
        LD      HL,$FDC_COMMAND
        LD      (HL),80H
```

A normal length sector would be read with command 0x88 or 0x8c.
