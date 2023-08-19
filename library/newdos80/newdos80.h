/* newdos80.h - NEWDOS/80 specific
**
**  I'm not sure how many of the error codes are common between all DOSes.
*/

#ifndef _NEWDOS80_H_
#define _NEWDOS80_H_

#define DOSERR_NO_ERROR                                                   0x00
#define DOSERR_BAD_FILE_DATA                                              0x01
#define DOSERR_SEEK_ERROR_DURING_READ                                     0x02
#define DOSERR_LOST_DATA_DURING_READ                                      0x03
#define DOSERR_PARITY_ERROR_DURING_READ                                   0x04
#define DOSERR_DATA_RECORD_NOT_FOUND_DURING_READ                          0x05
#define DOSERR_TRIED_TO_READ_LOCKED_DELETED_RECORD                        0x06
#define DOSERR_TRIED_TO_READ_SYSTEM_RECORD                                0x07
#define DOSERR_DEVICE_NOT_AVAILABLE                                       0x08
#define DOSERR_UNDEFINED_ERROR_CODE                                       0x09
#define DOSERR_SEEK_ERROR_DURING_WRITE                                    0x0a
#define DOSERR_LOST_DATA_DURING_WRITE                                     0x0b
#define DOSERR_PARITY_ERROR_DURING_WRITE                                  0x0c
#define DOSERR_DATA_RECORD_NOT_FOUND_DURING_WRITE                         0x0d
#define DOSERR_WRITE_FAULT_ON_DISK_DRIVE                                  0x0e
#define DOSERR_WRITE_PROTECTED_DISKETTE                                   0x0f
#define DOSERR_DEVICE_NOT_AVAILABLE2                                      0x10
#define DOSERR_DIRECTORY_READ_ERROR                                       0x11
#define DOSERR_DIRECTORY_WRITE_ERROR                                      0x12
#define DOSERR_ILLEGAL_FILE_NAME                                          0x13
#define DOSERR_TRACK_NUMBER_TOO_HIGH                                      0x14
#define DOSERR_ILLEGAL_FUNCTION_UNDER_DOS_CALL                            0x15
#define DOSERR_UNDEFINED_ERROR_CODE2                                      0x16
#define DOSERR_UNDEFINED_ERROR_CODE3                                      0x17
#define DOSERR_FILE_NOT_IN_DIRECTORY                                      0x18
#define DOSERR_FILE_ACCESS_DENIED                                         0x19
#define DOSERR_DIRECTORY_SPACE_FULL                                       0x1a
#define DOSERR_DISKETTE_SPACE_FULL                                        0x1b
#define DOSERR_END_OF_FILE_ENCOUNTERED                                    0x1c
#define DOSERR_PAST_END_OF_FILE                                           0x1d
#define DOSERR_DIRECTORY_FULL_CANT_EXTEND_FILE                            0x1e
#define DOSERR_PROGRAM_NOT_FOUND                                          0x1f
#define DOSERR_ILLEGAL_OR_MISSING_DRIVE_NUMBER                            0x20
#define DOSERR_NO_DEVICE_SPACE_AVAILABLE                                  0x21
#define DOSERR_LOAD_FILE_FORMAT_ERROR                                     0x22
#define DOSERR_MEMORY_FAULT                                               0x23
#define DOSERR_TRIED_TO_LOAD_READ_ONLY_MEMORY                             0x24
#define DOSERR_ILLEGAL_ACCESS_TRIED_TO_PROTECTED_FILE                     0x25
#define DOSERR_FILE_NOT_OPEN                                              0x26
#define DOSERR_ILLEGAL_INITIALIZATION_DATA_ON_SYSTEM_DISKETTE             0x27
#define DOSERR_ILLEGAL_DISKETTE_TRACK_COUNT                               0x28
#define DOSERR_ILLEGAL_LOGICAL_FILE                                       0x29
#define DOSERR_ILLEGAL_DOS_FUNCTION                                       0x2a
#define DOSERR_ILLEGAL_FUNCTION_UNDER_CHAINING                            0x2b
#define DOSERR_BAD_DIRECTORY_DATA                                         0x2c
#define DOSERR_BAD_FCB_DATA                                               0x2d
#define DOSERR_SYSTEM_PROGRAM_NOT_FOUND                                   0x2e
#define DOSERR_BAD_PARAMETERS                                             0x2f
#define DOSERR_BAD_FILESPEC                                               0x30
#define DOSERR_WRONG_DISKETTE_RECORD_TYPE                                 0x31
#define DOSERR_BOOT_READ_ERROR                                            0x32
#define DOSERR_DOS_FATAL_ERROR                                            0x33
#define DOSERR_ILLEGAL_KEYWORD_OR_SEPARATOR_OR_TERMINATOR                 0x34
#define DOSERR_FILE_ALREADY_EXISTS                                        0x35
#define DOSERR_COMMAND_TOO_LONG                                           0x36
#define DOSERR_DISKETTE_ACCESS_DENIED                                     0x37
#define DOSERR_ILLEGAL_MINI_DOS_FUNCTION                                  0x39
#define DOSERR_OPERATOR_PROGRAM_PARAMETER_REQUIRE_FUNCTION_TERMINATION    0x39
#define DOSERR_DATA_COMPARE_MISMATCH                                      0x3a
#define DOSERR_INSUFFICIENT_MEMORY                                        0x3b
#define DOSERR_INCOMPATIBLE_DRIVES_OR_DISKETTES                           0x3c
#define DOSERR_ASE_N_ATTRIBUTE_CANT_EXTEND_FILE                           0x3d
#define DOSERR_CANT_EXTEND_FILE_VIA_READ                                  0x3e

#endif
