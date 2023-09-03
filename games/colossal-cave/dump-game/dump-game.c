// Dump Game - Reads the Colossal Cave code and data and writes to files.
// Only single density is supported.
//
// Usage: dumpgame :drive_number codefile datafile
// E.g. dumpgame :1 code10/bin:0 data10/bin:0

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

// The game code loaded into RAM is 62 sectors long
// Also the size of the buffer for game data.
#define NUMBER_SECTORS 62
#define START_SECTOR 1
#define LAST_SECTOR 350

int	drive_number = 1;
char sector_data[NUMBER_SECTORS * 256];
char *code_filename;
char *data_filename;

// Next (untranslated) track and sector number to read from the diskette
char track_number = 0;
char sector_number = 1;

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

void print_read_error(int status) {
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
	printf("Usage: dumpgame :drive_number codefile datafile\n");
	printf("e.g.   dumpgame :1 code10/bin:0 data10/bin:0\n");
}

void spin_up(void) {
	fd1771_select(1 << drive_number);
}

// Translate track and sector numbers to the protected diskette
char translate(char id) {
	if (id == 0) return 0;
	return 129 - 2 * id;
}

int write_sectors(const void *data, int sector_count, FILE *ofp)
{
	fprintf(stderr, "Writing %d sectors\n", sector_count, data);

	size_t nmemb = fwrite(data, 256, sector_count, ofp);
	if (nmemb != sector_count) {
		printf("Wrote %d of %d sectors\n", nmemb, sector_count);
		return 2;
	}

	return 0;
}

// read_sectors: Read the next `sector_count` sectors from the game diskette
// Store in buf
int read_sectors(char *buf, int sector_count)
{
	char status;

	fd1771_set_single_density();

	for (int i = 0; i < sector_count; ++i) {
		spin_up();
		fd1771_set_track(translate(track_number));
		fd1771_set_sector(translate(sector_number));

		char *last_addr = fd1771_read(0x08, buf);
		int bytes_read = last_addr - buf;
		fprintf(stderr, "Loop %02d Track %02d Sector %d Bytes read: %d at %p\n", i, track_number, sector_number, bytes_read, buf);

		status = fd1771_get_status();
		if (status & 0x9c) {
			print_read_error(status);
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

int main(int argc, char *argv[]) {
	int ch;
	int rc;
	char status;

	printf("Dump the Colossal Cave code and data to files\n");

	if (argc != 4 || argv[1][0] != ':' || !isdigit(argv[1][1])) {
		usage();
		return 4;
	}

	drive_number = atoi(&argv[1][1]);
	code_filename = argv[2];
	data_filename = argv[3];

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

	// Start reading at sector 1
	sector_number = 1;

	// Everything has been read; write it to a file
	FILE *ofp = fopen(code_filename, "w");
	if (ofp == NULL) {
		printf("Unable to open %s for write - aborting\n", code_filename);
		return 2;
	}

	rc = read_sectors(sector_data, NUMBER_SECTORS);
	if (rc != 0) {
		printf("Failed to read code from diskette.\n");
		fclose(ofp);
		return 5;
	}

	rc = write_sectors(sector_data, NUMBER_SECTORS, ofp);
	if (rc != 0) {
		printf("Write error on %s\n", code_filename);
		fclose(ofp);
		return 2;
	}

	fclose(ofp);
	printf("Wrote %s, %d bytes.\n", code_filename, NUMBER_SECTORS * 256);

	// Copy the data area
	ofp = fopen(data_filename, "w");
	if (ofp == NULL) {
		printf("Unable to open %s for write - aborting\n", data_filename);
		return 2;
	}

	int sectors_todo = LAST_SECTOR - NUMBER_SECTORS - START_SECTOR;

	while (sectors_todo > 0) {
		int sectors_toread = (sectors_todo > NUMBER_SECTORS) ? NUMBER_SECTORS : sectors_todo;

		rc = read_sectors(sector_data, sectors_toread);
		if (rc != 0) {
			printf("Failed to read data from diskette.\n");
			fclose(ofp);
			return 5;
		}

		rc = write_sectors(sector_data, sectors_toread, ofp);
		if (rc != 0) {
			printf("Write error on %s\n", data_filename);
			fclose(ofp);
			return 2;
		}

		sectors_todo -= sectors_toread;
	}

	fclose(ofp);
	printf("Wrote %s, %ld bytes.\n", data_filename, (long)(LAST_SECTOR - NUMBER_SECTORS - START_SECTOR) * 256);
	printf("Done\n");

	return 0;
}
