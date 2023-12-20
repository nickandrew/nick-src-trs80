// copygame - Copies Colossal Cave from diskette to file or vice-versa.
// Only single density is supported - format diskette 35 track SSSD.
// Automatically determines whether diskette is protected
//
//  Usage:
//    copygame export :drive_number filename/bin:0       ; Copy diskette to file
//    copygame import [/J] :drive_number filename/bin:0  ; Copy file to diskette
//  Options:
//    /J   - Write JV1 diskette (0xf8 Data Address Mark on directory sectors)
//
//  Exit codes:
//    0  Normal exit
//    2  Incorrect arguments
//    3  Diskette error
//    4  File error

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

#define VERSION "1.0"

// Cache size
#define CACHE_SECTORS 50

// Colossal Cave uses 35 tracks, 10 sectors/track
#define NUMBER_SECTORS 350

int	drive_number = 1;
int protected = 0;  // Read/Write a protected diskette
int jv1 = 0;        // JV1 emulated diskette; write track 17 with DAM 0xf8
char sector_cache[CACHE_SECTORS * 256];

enum {
	no_action,
	export_action,
	import_action,
} action;

// Next (untranslated) track and sector number to write to the diskette
char track_number = 0;
char sector_number = 0;

// There is none in the library at the moment
int _stricmp(const char *s1, const char *s2) {
	char c;

	while (*s1 && *s2) {
		c = tolower(*s1) - tolower(*s2);
		if (c) {
			return c;
		}

		++s1;
		++s2;
	}

	c = *s1 - *s2;
	return c;
}

void print_type1_error(int status) {
	printf("Bad status at track %d sector %d\n", track_number, sector_number);
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
	printf("Bad status at track %d sector %d\n", track_number, sector_number);
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
	printf("Copy from diskette to a file:\n");
	printf("   copygame export :drive_number filename/bin:0\n");
	printf("Copy from a file to diskette:\n");
	printf("   copygame import (/J) :drive_number filename/bin:0\n");
	printf("Options:\n");
	printf("   /J   - Write JV1 diskette (0xf8 DAM on directory sectors)\n");
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
	size_t nmemb = fread(data, 256, sector_count, ifp);
	if (nmemb != sector_count) {
		printf("Wrote %d of %d sectors\n", nmemb, sector_count);
		return 4;
	}

	return 0;
}

int write_file(const void *data, int sector_count, FILE *ofp)
{
	size_t nmemb = fwrite(data, 256, sector_count, ofp);
	if (nmemb != sector_count) {
		printf("Wrote %d of %d sectors\n", nmemb, sector_count);
		return 4;
	}

	return 0;
}

// test_diskette: Ensure a diskette is in the drive and test if it contains
// translated sectors.
int test_diskette(char *buf) {

	fd1771_set_single_density();
	spin_up();
	// At this point, the head has already been restored to track 0
	fd1771_set_track(translate(0));
	fd1771_set_sector(translate(1));

	char *last_addr = fd1771_read(0x08, buf);
	int bytes_read = last_addr - buf;

	char status = fd1771_get_status();
	if (status & 0x8c) {
		print_fd1771_error(status);
		return 3;
	}

	if (!(status & 0x10)) {
		// Found translated sector number
		printf("Found translated sector number: protected\n");
		protected = 1;
		return 0;
	}

	// Try again, untranslated
	fd1771_set_sector(1);
	last_addr = fd1771_read(0x08, buf);

	status = fd1771_get_status();
	if (status & 0x8c) {
		print_fd1771_error(status);
		return 3;
	}

	if (!(status & 0x10)) {
		// Found normal sector number
		printf("Found normal sector number: not protected\n");
		return 0;
	}

	printf("Looks like the diskette is not formatted?\n");
	return 3;
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

		status = fd1771_get_status();
		if (status & 0x9c) {
			print_fd1771_error(status);
			printf("Aborting\n");
			return 3;
		}

		if (bytes_read != 256) {
			printf("Bad byte count\n");
			return 3;
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
				printf("step_in failed\n");
				return 3;
			}
		}
	}

	return 0;
}

// write_diskette: Write the next `sector_count` sectors to the game diskette
int write_diskette(const char *buf, int sector_count)
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

		status = fd1771_get_status();
		if (status & 0x9c) {
			print_fd1771_error(status);
			return 3;
		}

		if (bytes_written != 256) {
			printf("Bad byte count\n");
			return 3;
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
				printf("step_in failed\n");
				return 3;
			}
		}
	}

	return 0;
}

int copy_from_diskette(const char *filename) {
	FILE *ofp = fopen(filename, "w");
	if (ofp == NULL) {
		printf("Unable to open %s for write - aborting\n", filename);
		return 4;
	}

	int sectors_todo = NUMBER_SECTORS;
	int rc;

	while (sectors_todo > 0) {
		int sectors_tocopy = (sectors_todo > CACHE_SECTORS) ? CACHE_SECTORS : sectors_todo;

		rc = read_diskette(sector_cache, sectors_tocopy);
		if (rc != 0) {
			printf("Read error on diskette\n");
			fclose(ofp);
			return rc;
		}

		rc = write_file(sector_cache, sectors_tocopy, ofp);
		if (rc != 0) {
			printf("Write error on %s\n", filename);
			fclose(ofp);
			return rc;
		}

		sectors_todo -= sectors_tocopy;
	}

	fclose(ofp);
	return 0;
}

int copy_from_file(const char *filename) {
	FILE *ifp = fopen(filename, "r");
	if (ifp == NULL) {
		printf("Unable to open %s for read - aborting\n", filename);
		return 4;
	}

	int sectors_todo = NUMBER_SECTORS;
	int rc;

	while (sectors_todo > 0) {
		int sectors_tocopy = (sectors_todo > CACHE_SECTORS) ? CACHE_SECTORS : sectors_todo;

		rc = read_file(sector_cache, sectors_tocopy, ifp);
		if (rc != 0) {
			printf("Read error on %s\n", filename);
			fclose(ifp);
			return rc;
		}

		rc = write_diskette(sector_cache, sectors_tocopy);
		if (rc != 0) {
			printf("Write error on diskette\n");
			fclose(ifp);
			return rc;
		}

		sectors_todo -= sectors_tocopy;
	}

	fclose(ifp);
	return 0;
}

int main(int argc, char *argv[]) {
	int ch;
	int rc;
	char *action_arg = argv[1];
	char **argp = &argv[2];
	char *filename;

	printf("Copy Colossal Cave to/from diskette, version %s\n", VERSION);

	if (argc < 4) {
		usage();
		return 2;
	}

	if (!_stricmp(action_arg, "export")) {
		action = export_action;
	} else if (!_stricmp(action_arg, "import")) {
		action = import_action;
	} else {
		usage();
		return 2;
	}

	// Parse an optional /P or /J argument
	while (*argp && argp[0][0] == '/') {
		if (argp[0][1] == 'J') {
			jv1 = 1;
		} else {
			usage();
			return 2;
		}
		argp++;
	}

	// Parse the required drive number
	if (argp[0][0] != ':' || !isdigit(argp[0][1])) {
		usage();
		return 2;
	}

	drive_number = atoi(&argp[0][1]);

	// Take final argument
	filename = argp[1];

	printf("Insert game diskette into drive %d; press ENTER or Q to quit\n", drive_number);

	do {
		ch = getchar();
	} while (ch != '\r' && ch != 'q' && ch != 'Q');

	if (ch == 'q' || ch == 'Q') {
		printf("Exiting.\n");
		return 0;
	}

	spin_up();

	char status = fd1771_restore(0);   // Seek head to track zero
	if (status & 0x98) {
		print_type1_error(status);
		printf("Aborting.\n");
		return 3;
	}

	rc = test_diskette(sector_cache);

	if (rc) {
		printf("Aborting.\n");
		return rc;
	}

	if (action == export_action) {
		rc = copy_from_diskette(filename);
	} else if (action == import_action) {
		rc = copy_from_file(filename);
	} else {
		printf("Unknown action - aborting\n");
		return 2;
	}

	if (rc) {
		printf("Aborting.\n");
		return rc;
	}

	if (action == export_action) {
		printf("Wrote %d sectors from diskette to %s\n", NUMBER_SECTORS, filename);
	} else {
		printf("Wrote %d sectors from %s to diskette\n", NUMBER_SECTORS, filename);
	}

	return 0;
}
