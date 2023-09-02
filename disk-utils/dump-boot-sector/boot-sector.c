// Boot Sector - Reads the boot sector from a diskette and writes to a file
// Only single density is supported.
//
// Usage: bootsect filename :drive_number
// E.g. bootsect boot/bin:0 :1

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

int	drive_number = 1;
char sector_data[256];
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
	if (status & 0x01) {
		printf("  Controller is busy\n");
	}
}

void usage(void) {
	printf("Usage: bootsect filename :drive_number\n");
	printf("e.g.   bootsect boot/bin:0 :1\n");
}

void spin_up(void) {
	fd1771_select(1 << drive_number);
}

int main(int argc, char *argv[]) {
	int track_number = 0;
	int ch;
	char status;

	printf("Boot Sector - copies a diskette boot sector to a file\n");

	if (argc != 3 || argv[2][0] != ':' || !isdigit(argv[2][1])) {
		usage();
		return 4;
	}

	filename = argv[1];
	drive_number = atoi(&argv[2][1]);

	printf("Insert target diskette into drive %d and press ENTER or Q to quit", drive_number);

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
	if (status & 0xd9) {
		print_type1_error(status);
		printf("Aborting.\n");
		return 4;
	}

	fd1771_set_track(0);
	fd1771_set_sector(0);
	char *last_addr = fd1771_read(0x08, sector_data);
	int bytes_read = last_addr - sector_data;
	printf("Bytes read: %d\n", bytes_read);

	if (drive_number == 0) {
		printf("Insert system diskette in drive %d and press Enter\n", drive_number);
		do {
			ch = getchar();
		} while (ch != '\r');
	}

	if (bytes_read == 256) {
		FILE *ofp = fopen(filename, "w");
		if (ofp == NULL) {
			printf("Unable to open %s for write - aborting\n", filename);
			return 2;
		}
		size_t nmemb = fwrite(sector_data, 256, 1, ofp);
		fclose(ofp);
		if (nmemb != 1) {
			printf("Write error on %s\n", filename);
			return 2;
		}
		printf("Wrote %s, %d bytes.\n", filename, bytes_read);
	}

	return 0;
}
