// Make Game - Reads Colossal Cave .bin files and writes a game diskette.
// Only single density is supported - format diskette 35 track SSSD.
// Encoded sector numbers are not supported.
//
// Usage: makegame :drive_number bootfile codefile datafile
// E.g. makegame :1 boot10np/bin:0 code10/bin:0 data10/bin:0

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

// Cache size
#define NUMBER_SECTORS 62

// Boot = 1 sector; Code = 62; Data = 287 (total 350)
#define CODE_SECTORS 62
#define DATA_SECTORS 287

int	drive_number = 1;
int protected = 0;  // Read/Write a protected diskette
int jv1 = 0;        // JV1 emulated diskette; write track 17 with DAM 0xf8
char sector_data[NUMBER_SECTORS * 256];
char *boot_filename;
char *code_filename;
char *data_filename;

// Next (untranslated) track and sector number to write to the diskette
char track_number = 0;
char sector_number = 0;

void print_type1_error(int status) {
	printf("Error %02x from fd1771:\n", status);
	if (status & 0x80) {
		printf("  Not Ready\n");
	}
	if (status & 0x40) {
		printf("  Diskette is write protected\n");
	}
	if (status & 0x10) {
		printf("  Seek error\n");
	}
	if (status & 0x08) {
		printf("  CRC error\n");
	}
}

void print_fd1771_error(int status) {
	printf("Error %02x from fd1771:\n", status);
	if (status & 0x80) {
		printf("  Not Ready\n");
	}
	if (status & 0x10) {
		printf("  Record not found\n");
	}
	if (status & 0x08) {
		printf("  CRC error\n");
	}
	if (status & 0x04) {
		printf("  Lost Data\n");
	}
}

void usage(void) {
	printf("Usage: makegame [/J] [/P] :drive_number bootfile codefile datafile\n");
	printf("e.g.   makegame /J :1 boot10np/bin:0 code10/bin:0 data10/bin:0\n");
}

void spin_up(void) {
	fd1771_select(1 << drive_number);
}

// Translate track and sector numbers to the protected diskette
char translate(char id) {
	if (id == 0) return 0;
	return 129 - 2 * id;
}

// Conditionally translate track and sector numbers
char cond_translate(char id) {
	if (protected) {
		return translate(id);
	}
	return id;
}

int read_file(void *data, int sector_count, FILE *ifp)
{
	fprintf(stderr, "Reading %d sectors\n", sector_count, data);

	size_t nmemb = fread(data, 256, sector_count, ifp);
	if (nmemb != sector_count) {
		printf("Wrote %d of %d sectors\n", nmemb, sector_count);
		return 2;
	}

	return 0;
}

int write_file(const void *data, int sector_count, FILE *ofp)
{
	fprintf(stderr, "Writing %d sectors\n", sector_count, data);

	size_t nmemb = fwrite(data, 256, sector_count, ofp);
	if (nmemb != sector_count) {
		printf("Wrote %d of %d sectors\n", nmemb, sector_count);
		return 2;
	}

	return 0;
}

// read_diskette: Read the next `sector_count` sectors from the game diskette
// Store in buf
int read_diskette(char *buf, int sector_count)
{
	char status;

	fd1771_set_single_density();

	for (int i = 0; i < sector_count; ++i) {
		spin_up();
		fd1771_set_track(cond_translate(track_number));
		fd1771_set_sector(cond_translate(sector_number));

		char *last_addr = fd1771_read(0x08, buf);
		int bytes_read = last_addr - buf;
		fprintf(stderr, "Loop %02d Track %02d Sector %d Bytes read: %d at %p\n", i, track_number, sector_number, bytes_read, buf);

		status = fd1771_get_status();
		if (status & 0x9c) {
			print_fd1771_error(status);
			printf("Aborting\n");
			return 4;
		}

		if (bytes_read != 256) {
			printf("Bad byte count, aborting\n");
			return 4;
		}

		// Bump buffer pointer
		buf += 256;

		++sector_number;

		if (sector_number == 10) {
			++track_number;
			sector_number = 0;

			status = fd1771_step_in(fd1771_load_head | fd1771_step_rate_3);
			// Potential errors:
			if (status & 0x98) {
				print_type1_error(status);
				printf("Aborting after step_in.\n");
				return 4;
			}
		}
	}

	return 0;
}

// write_diskette: Read the next `sector_count` sectors from the game diskette
// Store in buf
int write_diskette(char *buf, int sector_count)
{
	char status;

	fd1771_set_single_density();

	for (int i = 0; i < sector_count; ++i) {
		spin_up();
		fd1771_set_track(cond_translate(track_number));
		fd1771_set_sector(cond_translate(sector_number));

		char write_flags = 0x08;
		if (jv1 && track_number == 17) {
			// Set deleted DAM on directory sector
			write_flags |= 0x03;
		}

		char *last_addr = fd1771_write(write_flags, buf);
		int bytes_written = last_addr - buf;
		fprintf(stderr, "Loop %02d Track %02d Sector %d Bytes written: %d at %p\n", i, track_number, sector_number, bytes_written, buf);

		status = fd1771_get_status();
		if (status & 0x9c) {
			print_fd1771_error(status);
			printf("Aborting\n");
			return 4;
		}

		if (bytes_written != 256) {
			printf("Bad byte count, aborting\n");
			return 4;
		}

		// Bump buffer pointer
		buf += 256;

		++sector_number;

		if (sector_number == 10) {
			++track_number;
			sector_number = 0;

			status = fd1771_step_in(fd1771_load_head | fd1771_step_rate_3);
			// Potential errors:
			if (status & 0x98) {
				print_type1_error(status);
				printf("Aborting after step_in.\n");
				return 4;
			}
		}
	}

	return 0;
}

int copy_from_file(char *filename, int n_sectors) {
	FILE *ifp = fopen(filename, "r");
	if (ifp == NULL) {
		printf("Unable to open %s for read - aborting\n", filename);
		return 2;
	}

	int sectors_todo = n_sectors;
	int rc;

	while (sectors_todo > 0) {
		int sectors_tocopy = (sectors_todo > NUMBER_SECTORS) ? NUMBER_SECTORS : sectors_todo;

		rc = read_file(sector_data, sectors_tocopy, ifp);
		if (rc != 0) {
			printf("Read error on %s\n", filename);
			fclose(ifp);
			return 5;
		}

		rc = write_diskette(sector_data, sectors_tocopy);
		if (rc != 0) {
			printf("Write error on diskette\n");
			fclose(ifp);
			return 2;
		}

		sectors_todo -= sectors_tocopy;
	}

	fclose(ifp);
	printf("Read %s, %ld bytes.\n", filename, (long)(n_sectors * 256));

	return 0;
}

int main(int argc, char *argv[]) {
	int ch;
	int rc;
	char status;
	char **argp = &argv[1];

	printf("Write the Colossal Cave boot, code and data to diskette\n");

	if (argc < 5) {
		usage();
		return 4;
	}

	// Parse an optional /P or /J argument
	while (*argp && argp[0][0] == '/') {
		if (argp[0][1] == 'P') {
			protected = 1;
		} else if (argp[0][1] == 'J') {
			jv1 = 1;
		} else {
			usage();
			return 4;
		}
		argp++;
	}

	// Parse the required drive number
	if (argp[0][0] != ':' || !isdigit(argp[0][1])) {
		usage();
		return 4;
	}
	drive_number = atoi(&argp[0][1]);

	// Take final arguments
	boot_filename = argp[1];
	code_filename = argp[2];
	data_filename = argp[3];

	printf("Insert game diskette into drive %d; press ENTER or Q to quit\n", drive_number);

	do {
		ch = getchar();
	} while (ch != '\r' && ch != 'q' && ch != 'Q');

	if (ch == 'q' || ch == 'Q') {
		printf("Exiting.\n");
		return 0;
	}

	spin_up();

	status = fd1771_restore(0);   // Seek head to track zero
	if (status & 0x98) {
		print_type1_error(status);
		printf("Aborting.\n");
		return 4;
	}

	// Start writing at sector 0
	sector_number = 0;

	rc = copy_from_file(boot_filename, 1);
	if (rc) {
		return rc;
	}

	rc = copy_from_file(code_filename, CODE_SECTORS);
	if (rc) {
		return rc;
	}

	rc = copy_from_file(data_filename, DATA_SECTORS);
	if (rc) {
		return rc;
	}

	printf("Done.\n");
	return 0;
}
