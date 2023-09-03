// Dump Code - Reads the colossal cave game code and writes to a file
// Only single density is supported.
//
// Usage: dumpcode filename :drive_number
// E.g. dumpcode code10/bin:0 :1

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

// The game code loaded into RAM is 62 sectors long
#define NUMBER_SECTORS 62
#define START_SECTOR 1

int	drive_number = 1;
char sector_data[NUMBER_SECTORS][256];
char *filename;

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
	printf("Usage: dumpcode filename :drive_number\n");
	printf("e.g.   dumpcode code10/bin:0 :1\n");
}

void spin_up(void) {
	fd1771_select(1 << drive_number);
}

// Translate track and sector numbers to the protected diskette
char translate(char id) {
	if (id == 0) return 0;
	return 129 - 2 * id;
}

int main(int argc, char *argv[]) {
	char track_number = 0;
	int ch;
	char status;

	printf("Dump the Colossal Cave code to a file\n");

	if (argc != 3 || argv[2][0] != ':' || !isdigit(argv[2][1])) {
		usage();
		return 4;
	}

	filename = argv[1];
	drive_number = atoi(&argv[2][1]);

	printf("Insert game diskette into drive %d; press ENTER or Q to quit\n", drive_number);

	do {
		ch = getchar();
	} while (ch != '\r' && ch != 'q' && ch != 'Q');

	if (ch == 'q' || ch == 'Q') {
		printf("Exiting.\n");
		return 0;
	}

	spin_up();
	fd1771_set_single_density();

	status = fd1771_restore(0);   // Seek head to track zero
	if (status & 0x98) {
		print_type1_error(status);
		printf("Aborting.\n");
		return 4;
	}

	char sector_number = START_SECTOR;
	for (int sector_count = 0; sector_count < NUMBER_SECTORS; ++sector_count) {
		spin_up();
		fd1771_set_track(translate(track_number));
		fd1771_set_sector(translate(sector_number));

		char *last_addr = fd1771_read(0x08, sector_data[sector_count]);
		int bytes_read = last_addr - sector_data[sector_count];
		fprintf(stderr, "Loop %02d Track %02d Sector %d Bytes read: %d\n", sector_count, track_number, sector_number, bytes_read);

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

	// Everything has been read; write it to a file
	FILE *ofp = fopen(filename, "w");
	if (ofp == NULL) {
		printf("Unable to open %s for write - aborting\n", filename);
		return 2;
	}

	size_t nmemb = fwrite(sector_data, 256, NUMBER_SECTORS, ofp);
	fclose(ofp);
	if (nmemb != NUMBER_SECTORS) {
		printf("Write error on %s - %d sectors written\n", filename, nmemb);
		return 2;
	}
	printf("Wrote %s, %d bytes.\n", filename, nmemb * 256);

	return 0;
}
