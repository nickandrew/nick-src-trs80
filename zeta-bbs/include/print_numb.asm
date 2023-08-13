;PRINT_NUMB. Print a number in HL to unit $stdout_def.
;sets up TENS&ONES for suffix printing.
;Also PRINT_NUMB_DEV for printing to a device.
;
PRINT_NUMB
	LD	DE,DCB_2O
	JR	PRINT_NUMB_DEV
;
