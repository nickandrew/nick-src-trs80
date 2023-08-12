/* soft_time.c - Read in-memory time and date */

#include <time.h>

#include "hardware_id.h"

void soft_time_tm(struct tm *timeptr)
{
  int hw_id = get_hardware_id();
  char *base;

  if (hw_id & HW_ID_MODEL_1) {
    base = (char *) 0x4041;
  }
  else {
    // Assume Model III and 4 hardware times are at the same location
    base = (char *) 0x4217;
  }

  timeptr->tm_sec = base[0];
  timeptr->tm_min = base[1];
  timeptr->tm_hour = base[2];

  char year = base[3];
  if (year < 50) {
    year += 100;
  }
  timeptr->tm_year = year;  // year since 1900

  timeptr->tm_mday = base[4];
  timeptr->tm_mon = base[5] - 1;
}

time_t soft_time(time_t *tloc)
{
  struct tm now;

  soft_time_tm(&now);

  time_t t = mktime(&now);
  if (tloc) {
    *tloc = t;
  }

  return t;
}
