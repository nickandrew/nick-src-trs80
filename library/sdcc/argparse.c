/* argparse.c - Parses a TRS-80 command line into (argc,argv)
**
** Copyright (C) 2023, Nick Andrew <nick@nick-andrew.net>
*/

// The TRS-80 command line ends with an 0x0d character
#define CR 0x0d

// Starting the enum at values greater than 0 is required to avoid
// an sdcc compiler bug.
enum p_state {
  between_words = 100,
  in_word,
  single_quote,
  double_quote,
  backslash,
};

// Static declared argv area, for use when malloc does not exist.
#define MAX_WORDS 20
static char *argv[MAX_WORDS];

/*
**  static int pack_words(char *ibuf)
**
**  Parse a TRS-80 command line starting at 'ibuf' into a
**  set of C strings, one string per word, and return a count
**  of the number of words processed. The character buffer at
**  'ibuf' is also the output buffer, as words are guaranteed
**  to be less than or equal to the length of the original string.
**
**  Words are generally separated by one or more whitespace characters,
**  but single- or double-quoted strings are interpreted to preserve
**  whitespace if possible. Backslashes are also interpreted to allow
**  strings containing quotes.

Example:

Input:   "process   file/txt:2 -s \"hello \\\"there\" \"goodbye you\"\x03"

Output:  argc = 5
         ibuf = "process\0file/txt:2\0-s\0hello "there\0goodbye you\0"

**  Backslash escape sequences (like \n) are not converted like in C;
**  that one ends up as a plain 'n'. Backslash is just to allow quotes.
*/

static int pack_words(char *ibuf)
{
  // char *start = ibuf;
  char *obuf = ibuf;
  int nwords = 0;
  enum p_state state = between_words;
  enum p_state prior_state = between_words;
  char c;

  while (*ibuf && *ibuf != CR) {
    c = *ibuf;

    // Prepare for next run through the loop
    ++ibuf;

    switch (state) {
      case between_words:
        if (c == ' ') break;
        if (c == '"') {
          state = double_quote;
          break;
        }
        if (c == '\'') {
          state = single_quote;
          break;
        }
        if (c == '\\') {
          prior_state = in_word;
          state = backslash;
          break;
        }

        *obuf++ = c;
        state = in_word;
        break;

      case in_word:
        if (c == '"') {
          state = double_quote;
          break;
        }
        if (c == '\'') {
          state = single_quote;
          break;
        }
        if (c == ' ') {
          *obuf++ = '\0';
          ++nwords;
          state = between_words;
          break;
        }
        if (c == '\\') {
          prior_state = in_word;
          state = backslash;
          break;
        }

        *obuf++ = c;
        break;

      case single_quote:
        if (c == '\'') {
          state = in_word;
          break;
        }
        if (c == '\\') {
          prior_state = single_quote;
          state = backslash;
          break;
        }

        *obuf++ = c;
        break;

      case double_quote:
        if (c == '"') {
          state = in_word;
          break;
        }
        if (c == '\\') {
          prior_state = double_quote;
          state = backslash;
          break;
        }

        *obuf++ = c;
        break;

      case backslash:
        // Next character is added verbatim, and return to the previous state
        *obuf++ = c;
        state = prior_state;
        break;

      default:
        *obuf++ = c;
        state = in_word;
    }
  }

  if (state != between_words) {
    // Terminate last word, if the last character read was a double or single quote
    *obuf++ = '\0';
    nwords++;
  }

  return nwords;
}

/*  char **argparse(char *buf, int *p_argc)
**
**  Parse TRS-80 command line and return (via pointer arguments) argc and argv.
*/

char **argparse(char *buf, int *p_argc)
{
  int nwords = pack_words(buf);

  *p_argc = nwords;

  if (nwords == 0) {
    argv[0] = (void *) 0;
    return argv;
  }

  if (nwords >= MAX_WORDS) {
    // Don't accept this
    *p_argc = 0;
    argv[0] = (void *) 0;
    return argv;
  }

  char **argvp = argv;

  // Iterate over buf, saving the address of the beginning of each string
  while (nwords--) {
    *argvp++ = buf;
    while (*buf++) ;
  }

  // Terminate the argv array with a final NULL
  *argvp = (void *) 0;
  return argv;
}
