/*  dos_file.c - DOS file I/O functions
**
**  These functions should work identically across all DOSes.
*/

#include "doscalls.h"
#include <stdio.h>
#include <string.h>

int dos_file_extract(const char *filename, union dos_fcb *fcb) __naked __sdcccall(0)
{
  filename;
  fcb;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld l,0(iy)  ; filename low
  ld h,1(iy)  ; filename high
  ld e,2(iy)  ; fcb low
  ld d,3(iy)  ; fcb high
  call 0x441c ; DOS_EXTRACT
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_open_new(union dos_fcb *fcb, char *buf, unsigned short lrecl) __naked __sdcccall(0)
{
  fcb; buf; lrecl;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  ld l,2(iy)  ; buf low
  ld h,3(iy)  ; buf high
  ld b,4(iy)  ; lrecl
  call 0x4420 ; DOS_OPEN_NEW
              ; Return flags: Z = success, and C = created new file; NC = existing file
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_open_ex(union dos_fcb *fcb, char *buf, unsigned short lrecl) __naked __sdcccall(0)
{
  fcb; buf; lrecl;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  ld l,2(iy)  ; buf low
  ld h,3(iy)  ; buf high
  ld b,4(iy)  ; lrecl
  call 0x4424 ; DOS_OPEN_EX
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_close(union dos_fcb *fcb) __naked __sdcccall(0)
{
  fcb;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  call 0x4428 ; DOS_CLOSE
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_rewind(union dos_fcb *fcb) __naked __sdcccall(0)
{
  fcb;

  __asm

        ld      iy, #2   ; Skip over return address
        add     iy,sp
        ld      e,0(iy)  ; fcb low
        ld      d,1(iy)  ; fcb high
        call    0x443f   ; DOS_REWIND
        ld      hl, #0
        ret     z
        ld      l, a
        ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_seek_eof(union dos_fcb *fcb) __naked __sdcccall(0)
{
  fcb;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  call 0x4448 ; DOS_POS_EOF
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

// Return value: 0 if all OK, else dos error code
int dos_file_seek_rba(union dos_fcb *fcb, long pos) __naked __sdcccall(0)
{
  fcb; pos;

  __asm

        ld      iy, #2   ; Skip over return address
        add     iy,sp
        ld      e,0(iy)  ; fcb low
        ld      d,1(iy)  ; fcb high
        ld      c,2(iy)  ; pos low
        ld      l,3(iy)  ; pos medium
        ld      h,4(iy)  ; pos high
        call    0x444e   ; DOS_POS_RBA
        ld      hl, #0
        ret     z
        ld      l, a
        ret

  __endasm;
}

// 0x4409 DOS Error Exit (returns if err == 0 or err >= 128)
// To always test for an error, code this idiom:
//     dos_error(dos_function(args ...))
// If there is no error, dos_error will return silently.

void dos_error(int err) __naked __sdcccall(0)
{
  err;

  __asm

  ld iy, #2         ; Skip over return address
  add iy,sp
  ld a,0(iy)        ; err low
  cp #0
  ret z             ; Return silently if there was no error
  call 0x4409       ; DOS_ERROR
  ret               ; Only reached if (err & 0x80 == 1)

  __endasm;
}

int dos_file_read(union dos_fcb *fcb, char *buf) __naked __sdcccall(0)
{
  fcb; buf;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  ld l,2(iy)  ; buf low
  ld h,3(iy)  ; buf high
  call 0x4436 ; DOS_READ_SECT
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

int dos_write_byte(union dos_fcb *fcb, char ch) __naked __sdcccall(0)
{
  fcb; ch;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  ld a,2(iy)  ; buf low
  call 0x001b ; ROM@PUT
  ld hl, #0
  ret z
  ld l, a
  ret

  __endasm;
}

int dos_read_byte(union dos_fcb *fcb) __naked __sdcccall(0)
{
  fcb;

  __asm

  ld iy, #2   ; Skip over return address
  add iy,sp
  ld e,0(iy)  ; fcb low
  ld d,1(iy)  ; fcb high
  call 0x0013 ; ROM@GET
  ld l, a
  ld h, #0
  ret z
  ld h, #0xff ; Error condition. Register A contains DOS error code.
  ret

  __endasm;
}

int dos_control_byte(union dos_fcb *fcb) __naked __sdcccall(0)
{
  fcb;

  __asm

        ld      iy, #2   ; Skip over return address
        add     iy,sp
        ld      e,0(iy)  ; fcb low
        ld      d,1(iy)  ; fcb high
        call    0x0023   ; ROM@CTL/@CTL/CTLBYT
        ld      l, a
        ld      h, #0
        ret     z
        ld      h, #0xff ; Error condition. Register A contains DOS error code.
        ret

  __endasm;
}

long dos_file_eof(union dos_fcb *fcb)
{
  // Test that fcb is open
  if (!(fcb->bits1 & 0x80)) {
    return -1L;
  }

  return ((long)fcb->eof_h << 8) | fcb->eof_l;
}

long dos_file_next(union dos_fcb *fcb)
{
  // Test that fcb is open
  if (!(fcb->bits1 & 0x80)) {
    return -1L;
  }

  return ((long)fcb->next_h << 8) | fcb->next_l;
}
