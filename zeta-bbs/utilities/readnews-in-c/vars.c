/* Zetasource
** Readnews program
** vars.c
*/

int

 group,        /* number of current newsgroup or 0 if none */
 count,        /* last message read in this group          */
 highgrp,      /* highest message in this newsgroup        */
 expiry,       /* expiry time in days this newsgroup       */
 i_group,      /* index group number                       */
 i_article,    /* index article number                     */
 i_start,      /* index start sector                       */
 i_lines,      /* index number of lines                    */
 uid;          /* current users userid                     */


char

 status,       /* subscription status ' ','U','N'          */
 now[6],       /* current date in binary YMDHMS            */
 line[80],     /* buffer for anything                      */
 reply,        /* single character reply                   */
 access,       /* group access Public,Sysop,Restricted     */
 grptype,      /* group originates from Local, News, Echo  */
 sign1[80],    /* signature line 1                         */
 sign2[80],    /* signature line 2                         */
 i_date[6],    /* index date in binary YMDHMS              */
 h_date[80],   /* header date in ascii                     */
 h_from[80],   /* header originator                        */
 h_to[80],     /* header destination                       */
 h_subj[80],   /* header subject                           */
 grpname[80];  /* text of group name                       */


FILE

*newstxt0,     /* where the text is kept (drive 0, 128k)   */
*newstxt1,     /* where the text is kept (drive 2, 512k)   */
*newsidx,      /* index to all articles                    */
*newsrc,       /* newsrc file for all to share             */
*active;       /* list of active groups                    */


