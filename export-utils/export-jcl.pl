#!/usr/bin/perl
#	@(#) export-jcl.pl - Create jcl to export all files from a disk

my $diskno = 0;
my $fn;
my $path;

while (<STDIN>) {
	chomp;
	next if (/^ /);
	next if (/^$/);
	last if (/^DRIVE   0/);

	if (/^DRIVE   1/) {
		$diskno++;
		$fn = sprintf "arch-%03d.dmk", $diskno;
		$path = sprintf "exported/arch-%03d", $diskno;
		print "pause Insert $fn into virtual drive\r";
		print "mount -l $fn 1\r";
		next;
	}

	# This one should be a filename
	my @w = split(/\s+/);

	next if ($w[0] eq 'DIR/SYS');

	my $ufn = $w[0];
	$ufn =~ s,/,.,;
	print "export -l $w[0] $path/$ufn\r";
}

exit(0);
