/* cmdtobin.c - Convert a .CMD file to raw binary data
**
** Usage: cmdtobin filename.cmd filename.bin
**
** The program "loads" each data block from the .cmd file into a
** buffer which it dynamically extends forward or backward as each
** new data block is read.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Data structure is malloc'ed and realloc'ed as needed
char *buffer;  // All the load data read from the file
unsigned int first_address;
unsigned int buffer_size;

// Add the contents of buf (length bytes, starting at start) to the buffer.
// Extend the buffer as needed
void add_buffer(char *buf, int start, int length)
{
    // The easy case - no buffer yet
    if (!buffer) {
        buffer = malloc(length);
        if (!buffer) {
            fprintf(stderr, "Unable to malloc a buffer of length %d\n", length);
            exit(4);
        }
        memcpy(buffer, buf, length);
        first_address = start;
        buffer_size = length;
        return;
    }

    // Do we need to extend it backward?
    if (start < first_address) {
        // Need to allocate a new array
        int extend_by = first_address - start;
        printf("Extend backward by %d bytes to %04x\n", extend_by, start);
        char *new_buffer = calloc(1, buffer_size + extend_by);
        if (!new_buffer) {
            fprintf(stderr, "Unable to calloc a buffer of length %d\n", buffer_size + extend_by);
            exit(4);
        }
        memcpy(new_buffer + extend_by, buffer, buffer_size);
        char *free_buffer = buffer;
        buffer = new_buffer;
        free(free_buffer);
        first_address = start;
        buffer_size = buffer_size + extend_by;
    }

    // Do we need to extend it forward?
    if (start >= first_address + buffer_size) {
        // Calloc a new array to zero new bytes
        printf("Extend forward by %d bytes to %04x\n", start + length - first_address - buffer_size, start + length);
        int new_size = start + length - first_address;
        char *new_buffer = calloc(1, new_size);
        if (!new_buffer) {
            fprintf(stderr, "Unable to calloc a buffer of length %d\n", new_size);
            exit(4);
        }
        memcpy(new_buffer, buffer, buffer_size);
        char *free_buffer = buffer;
        buffer = new_buffer;
        free(free_buffer);
        buffer_size = new_size;
    }

    // Copy the data
    printf("Copy data from %04x to %04x\n", start, start + length);
    memcpy(buffer + start - first_address, buf, length);
}

int readbuf(char *buf, int length, FILE *fp) {
  int ch;
  for (int i = 0; i < length; ++i) {
    ch = fgetc(fp);
    if (ch == EOF) return EOF;
    *buf++ = ch;
  }

  return 0;
}

void load_file(FILE *ifp)
{
  char buf[256];

  while (1) {
    int c = fgetc(ifp);
    int length;
    char address[2];

    if (c == EOF) {
      break;
    }

    if (c == 0x05) {
      // Program-name
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      if (readbuf(buf, length, ifp) == EOF) {
        break;
      }
      buf[length] = '\0';
      printf("Program name: '%s'\n", buf);
    }
    else if (c == 0x01) {
      // Load length - 2 bytes at some address
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      length = (length - 2) & 0xff;
      if (length == 0) {
        length = 0x100;
      }
      if (readbuf(address, 2, ifp) == EOF) {
        break;
      }
      if (length > 0) {
        if (readbuf(buf, length, ifp) == EOF) {
          break;
        }
      }
      int start = (address[0] & 0xff) | ((address[1] & 0xff) << 8);
      printf("Load block from %04x to %04x\n", start, start + length);
      if (length > 0) {
        add_buffer(buf, start, length);
	  }
    }
    else if (c == 0x02) {
      // Chunk length
      length = fgetc(ifp);
      if (length == EOF) {
        break;
      }
      if (readbuf(buf, length, ifp) == EOF) {
        break;
      }
      printf("Start address %04x\n", buf[0] + (buf[1] << 8));
    }
    else {
      printf("Type byte: %02x\n", c);
      break;
    }
      
  }
}

void write_file(FILE *ofp) {
    if (!buffer) {
        printf("Nothing to write!\n");
        return;
    }

    size_t nbytes = fwrite(buffer, 1, buffer_size, ofp);
    if (nbytes != buffer_size) {
        fprintf(stderr, "Could not write %d bytes to file - wrote %ld\n", buffer_size, nbytes);
        exit(4);
    }

    if (ferror(ofp)) {
        fprintf(stderr, "File error on write\n");
        exit(4);
    }

    printf("Wrote %ld bytes from %04x\n", nbytes, first_address);
}

int cmdtobin(char *infile, char *outfile)
{
  FILE *ifp = fopen(infile, "r");
  if (ifp == NULL) {
    fprintf(stderr, "Unable to open %s for read\n", infile);
    return 2;
  }

  load_file(ifp);
  fclose(ifp);

  FILE *ofp = fopen(outfile, "w");
  if (ofp == NULL) {
    fprintf(stderr, "Unable to open %s for write\n", outfile);
    return 2;
  }

  write_file(ofp);
  fclose(ofp);
  return 0;
}

int main(int argc, char *argv[]) 
{
  if (argc < 3) {
    fprintf(stderr, "Usage: cmdtobin file.cmd file.bin\n");
    return 2;
  }

  int rc = cmdtobin(argv[1], argv[2]);
  if (rc) {
    return rc;
  }
  return 0;
}
