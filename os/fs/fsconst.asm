;fsconst.asm	filesystem constants
;
;	Table Sizes
;
NR_ZONE_NUMS	EQU	9	; # zone numbers in inode
NR_BUFS		EQU	30	; # blocks in buffer cache
NR_BUF_HASH	EQU	32	; must be power of 2
NR_FDS		EQU	20	; per process
NR_FILPS	EQU	64	; total files can be open
I_MAP_SLOTS	EQU	4	; ?
ZMAP_SLOTS	EQU	6	; ?
NR_INODES	EQU	32
NR_SUPERS	EQU	5	; 4 drives + root device
NAME_SIZE	EQU	14
FS_STACK_BYTES	EQU	512	; max stack used by FS
;
;	Miscellaneous constants
SUPER_MAGIC	EQU	137FH
SU_UID		EQU	0	;Super user's ID
SYS_UID		EQU	0	; MM and INIT uids.
SYS_GID		EQU	0
NORMAL		EQU	0
NO_READ		EQU	1
;
XPIPE		EQU	0
NO_BIT		EQU	0
DUP_MASK	EQU	64	;0100 octal
;
LOOK_UP		EQU	0
ENTER		EQU	1
DELETE		EQU	2
;
CLEAN		EQU	0
DIRTY		EQU	1
;
BOOT_BLOCK	EQU	0
SUPER_BLOCK	EQU	1
ROOT_INODE	EQU	1
;
;	Derived sizes
ZONE_NUM_SIZE	EQU	2	;# bytes in a zone number
NR_DZONE_NUM	EQU	7
DIR_ENTRY_SIZE	EQU	16
INODE_SIZE	EQU	32	;sizeof d_inode
INODES_PER_BLOC EQU	32
NR_DIR_ENTRIES	EQU	64
NR_INDIRECTS	EQU	512
SUPER_SIZE	EQU	34	; ??? sizeof super_block
PIPE_SIZE	EQU	7168
;;MAX_ZONES	EQU	VERY_BIG
;
