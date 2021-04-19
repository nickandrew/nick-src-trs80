/*  doscalls.h - Function prototypes for DOS calls
**
**  These are common to Model 1 and Model3, LDOS and NewDos/80,
**  unless otherwise noted.
*/

union dos_fcb {
  char filename[50];  // Newdos/80 uses 32; Model III TRSDOS uses 50
  struct {
    char bits1;
    char bits2;
    char bits3;
    char *buf;
    char next_l;
    char drive_id;
    char fpde_dec;
    char eof_l;
    char lrecl;
    unsigned int next_h;
    unsigned int eof_h;
    char fpde[8];
    char fxde[10];
  };
};

extern void dos_exit(void); // 0x402d No Error Exit
extern void dos_disp_error(void); // 0x4030 Error Displayed Exit
extern void dos_command(const char *s); // 0x4405 Enter DOS and execute a command (don't return)
extern void dos_error(int err); // 0x4409 DOS Error Exit (returns if err >= 128)
// Ignored some ...
extern void dos_mess_do(const char *s); // 0x4467 Send a message to the display
extern void dos_mess_pr(const char *s); // 0x446a Send a message to the printer

// DOS file I/O functions
extern int dos_file_open_new(union dos_fcb *fcb, char *buf, unsigned short lrecl);
extern int dos_file_open_ex(union dos_fcb *fcb, char *buf, unsigned short lrecl);
extern int dos_file_extract(const char *filename, union dos_fcb *fcb);
extern int dos_file_close(union dos_fcb *fcb);
extern int dos_file_rewind(union dos_fcb *fcb);
extern int dos_file_seek_eof(union dos_fcb *fcb);
extern int dos_file_seek_rba(union dos_fcb *fcb, long pos);
extern long dos_file_eof(union dos_fcb *fcb);
extern long dos_file_next(union dos_fcb *fcb);

// Implement these later
extern int dos_file_kill(union dos_fcb *fcb);
extern int dos_file_read(union dos_fcb *fcb, char *buf);
extern int dos_file_write(union dos_fcb *fcb, const char *buf);
extern int dos_file_write_verify(union dos_fcb *fcb, const char *buf);
extern int dos_file_seek(union dos_fcb *fcb, unsigned int lrec);
extern int dos_file_seek_back(union dos_fcb *fcb);
extern int dos_file_allocate(union dos_fcb *fcb);
extern int dos_file_write_eof(union dos_fcb *fcb);

extern int dos_set_extension(char *filename, const char *ext);
