/*  fd1771.h - Structures and function prototypes for the FD1771 disk controller.
**
*/

#ifndef FD1771_H_
#define FD1771_H_

#define fd1771_step_rate_0 0x00
#define fd1771_step_rate_1 0x01
#define fd1771_step_rate_2 0x02
#define fd1771_step_rate_3 0x03

#define fd1771_verify 0x04

#define fd1771_load_head 0x08

#define fd1771_update_track 0x10

#define fd1771_multiple 0x10

#define fd1771_block_length_ibm 0x08

#define fd1771_enable_hld_delay 0x04

#define fd1771_data_mark 0x00
#define fd1771_user_defined_1 0x01
#define fd1771_user_defined_2 0x02
#define fd1771_deleted_data_mark 0x03

#define fd1771_synchronize 0
#define fd1771_no_synchronize 1

#define fd1771_int_nr_to_r 1
#define fd1771_int_r_to_nr 2
#define fd1771_int_index 4
#define fd1771_int_immediate 8

struct fd1771_id_buf {
	char track_addr;
	char zeros;
	char sector_addr;
	char sector_length;
	char crc_1;
	char crc_2;
};

extern void fd1771_delay(unsigned int delay) __sdcccall(1);
extern char fd1771_get_sector(void) __sdcccall(1);
extern char fd1771_get_status(void) __sdcccall(1);
extern char fd1771_get_track(void) __sdcccall(1);
extern char *fd1771_read(char flags, char *buf) __sdcccall(1);
extern char fd1771_read_address(struct fd1771_id_buf *buf) __sdcccall(1);
extern char fd1771_restore(char flags) __sdcccall(1);
extern char fd1771_seek(char flags, char track) __sdcccall(1);
extern void fd1771_select(char selector) __sdcccall(1);
extern void fd1771_set_double_density(void);
extern void fd1771_set_sector(char sector) __sdcccall(1);
extern void fd1771_set_single_density(void);
extern void fd1771_set_track(char track) __sdcccall(1);
extern char fd1771_step(char flags) __sdcccall(1);
extern char fd1771_step_in(char flags) __sdcccall(1);
extern char fd1771_step_out(char flags) __sdcccall(1);

#endif
