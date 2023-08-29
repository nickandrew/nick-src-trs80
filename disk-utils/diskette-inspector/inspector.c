// Diskette Inspector - Shows the detailed track/sector formatting for a diskette
// Only single density is supported.
//
// Usage: inspect [:drive_number]
// E.g. inspect :1

#include <ctype.h>
#include <fd1771.h>
#include <stdio.h>
#include <stdlib.h>

#define RETRIES 20
#define MAX_TRACKS 80

int	drive_number = 1;
struct fd1771_id_buf sector_data[RETRIES];
char sector_dam[RETRIES];
int sector_seen[256];
char data_buffer[256];

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

void print_type3_error(int status) {
	printf("Error %02x from fd1771:\n", status);
	if (status & 0x80) {
		printf("  Not Ready\n");
	}
	if (status & 0x40) {
		printf("  Diskette is write protected\n");
	}
	if (status & 0x10) {
		printf("  ID not found\n");
	}
	if (status & 0x08) {
		printf("  CRC error\n");
	}
	if (status & 0x04) {
		printf("  Lost Data\n");
	}
	if (status & 0x01) {
		printf("  Controller is busy\n");
	}
}

void usage(void) {
	printf("Usage: inspect :drive_number\n");
	printf("e.g.   inspect :1\n");
}

void spin_up(void) {
	fd1771_select(1 << drive_number);
}

// Scan repeatedly for sectors on the track at the current head position.
int inspect_track(int track_number) {
	char status;
	int try;

	printf("Inspecting track %d\n", track_number);

	// Clear the table of seen sector numbers
	for (int i = 0; i < 256; ++i) sector_seen[i] = 0;
	for (int i = 0; i < RETRIES; ++i) sector_dam[i] = 0;

	// Wait for an index hole before starting scan
	while (1) {
		status = fd1771_get_status();
		if (status & 0x80) {
			printf("Not Ready %02x ", status);
			return 1;
		}

		if (status & 0x02) {
			// Index hole
			break;
		}
	}

	// Scan several times per track, to try to pick up all the sectors

	for (try = 0; try < RETRIES; ++try) {
		spin_up();
		status = fd1771_read_address(&sector_data[try]);
		// Potential errors: Not Ready (S7), ID not found (S4), CRC Error (S3), Lost Data (S2)
		if (status & 0x9d) {
			print_type3_error(status);
			printf("Aborting after try %d.\n", try);
			return 4;
		}

		char sector_addr = sector_data[try].sector_addr;
		sector_seen[sector_addr] = 1;
	}

	for (int read_try = 0; read_try < try; ++read_try) {
		char sector_addr = sector_data[read_try].sector_addr;
		char track_addr = sector_data[read_try].track_addr;
		spin_up();
		fprintf(stderr, "Reading track %d sector %d\n", track_addr, sector_addr);
		fd1771_set_track(sector_data[read_try].track_addr);
		fd1771_set_sector(sector_addr);
		status = fd1771_get_status();
		char *last_addr = fd1771_read(0x08, data_buffer);
		int bytes_read = last_addr - data_buffer;
		// 00 = FB, 01 = FA, 02 = F9, 03 = F8
		sector_dam[read_try] = 0xfb - ((status & 0x60) >> 5);
		fprintf(stderr, "Track %d Sector %d read %d bytes Status %02x DAM %02x\n",
			track_addr, sector_addr, bytes_read, status, sector_dam[read_try]);
	}

	// Report details about this track
	for (int i=0; i < RETRIES; ++i) {
		char sector_addr = sector_data[i].sector_addr;
		if (sector_seen[sector_addr]) {
			// Only print each sector number once
			sector_seen[sector_addr] = 0;

			printf("(%d,%d,%d) ",
				sector_data[i].track_addr,
				sector_data[i].sector_addr,
				sector_data[i].sector_length
			);
		}
	}
	printf("\n");

	// Print all the DAMs read
	printf("DAMs:");
	for (int read_try = 0; read_try < try; ++read_try) {
		printf(" %02x", sector_dam[read_try]);
	}
	printf("\n");

	return 0;
}

int main(int argc, char *argv[]) {
	int track_number = 0;
	int ch;
	char status;

	printf("Diskette Inspector - examines the track/sector formats\n");

	if (argc != 2 || argv[1][0] != ':' || !isdigit(argv[1][1])) {
		usage();
		return 4;
	}

	drive_number = atoi(&argv[1][1]);

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

	for (track_number = 0; track_number < MAX_TRACKS; ) {
		spin_up();
		int rc = inspect_track(track_number);

		if (rc) {
			printf("Press Enter to try again, or Q to quit\n");
			do {
				ch = getchar();
			} while (ch != '\r' && ch != 'q' && ch != 'Q');

			if (ch == 'q' || ch == 'Q') {
				break;
			} else {
				spin_up();
				continue;
			}
		}

		printf("Press Enter to scan next track, or Q to quit\n");
		do {
			ch = getchar();
		} while (ch != '\r' && ch != 'q' && ch != 'Q');

		if (ch == 'q' || ch == 'Q') {
			break;
		}

		spin_up();

		status = fd1771_step_in(fd1771_load_head | fd1771_step_rate_3);
		// Potential errors:
		if (status & 0xd9) {
			print_type1_error(status);
			printf("Aborting after step_in.\n");
			return 4;
		}

		track_number ++;
	}

	if (drive_number == 0) {
		printf("Insert system diskette in drive %d and press Enter\n", drive_number);
		do {
			ch = getchar();
		} while (ch != '\r');
	}

	return 0;
}
