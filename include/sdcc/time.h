/* time.h
**
**  Contains some definitions copied from sdcc time.h
**  Released under GPL v2.
*/

#ifndef _TIME_H_
#define _TIME_H_

#include <sys/types.h>

// Override time() because the one in z80.lib does not work
#define time(T) soft_time(T)

struct tm
{
  unsigned char tm_sec;                   /* Seconds.     [0-60]      */
  unsigned char tm_min;                   /* Minutes.     [0-59]      */
  unsigned char tm_hour;                  /* Hours.       [0-23]      */
  unsigned char tm_mday;                  /* Day.         [1-31]      */
  unsigned char tm_mon;                   /* Month.       [0-11]      */
  int tm_year;                            /* Year since 1900          */
  unsigned char tm_wday;                  /* Day of week. [0-6]       */
  int tm_yday;                            /* Days in year.[0-365]     */
  unsigned char tm_isdst;                 /* Daylight saving time     */
  unsigned char tm_hundredth;             /* not standard 1/100th sec */
};

extern time_t time(time_t *tloc);
extern time_t mktime(struct tm *timeptr);

#endif /* _TIME_H_ */
