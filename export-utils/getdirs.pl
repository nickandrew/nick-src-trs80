#!/usr/bin/perl
#	create JCL statements to do "dir" on all virtual disks

foreach my $f (<arch-*.dmk>) {
	print "PAUSE Please insert diskette $f\r";
	print "MOUNT -l $f 1\r";
	print "DIR 1 a s i p\r";
}

# filler because xtrs buffers stdout ...
foreach (1..10) {
	print "DIR 0 a s p\r";
}

exit(0);
