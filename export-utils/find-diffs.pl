#!/usr/bin/perl
#	@(#) find-diffs.pl - report on different files with same name

my @paths;

open(P, "find exported -type f -print|");
while (<P>) {
	chomp;
	push(@paths, $_);
}
close(P);

my %info;
my %sums;

foreach my $path (@paths) {
	my $s = `md5sum $path`;
	chomp($s);
	my($md5sum) = split(/\s+/, $s);
	$info{$path}->{md5sum} = $md5sum;

	push(@{$sums{$md5sum}}, $path);
}


# Now find different filenames, same data
foreach my $md5sum (sort (keys %sums)) {
	my $r = $sums{$md5sum};
	my @l = @$r;

	if ($#l > 1) {
		print "Same md5sum ($md5sum):\n";
		foreach my $path (@l) {
			print "\t$path\n";
		}
		print "\n";
	}
}

my %filenames;

# Now find same filename, different data
foreach my $path (keys %info) {
	my $fn = $path;
	$fn =~ s,.*/,,;
	push(@{$filenames{$fn}}, $path);
}

foreach my $filename (sort (keys %filenames)) {
	my $r = $filenames{$filename};
	my @l = @$r;

	if ($#l > 1) {
		my $same = 1;
		my $md5sum;
		foreach my $path (@l) {
			my $newsum = $info{$path}->{md5sum};
			if ($md5sum ne '' && $md5sum ne $newsum) {
				$same = 0;
				last;
			}
			$md5sum = $newsum;
		}

		if (!$same) {
			print "Filenames same but different md5sums:\n";
			foreach my $path (@l) {
				$md5sum = $info{$path}->{md5sum};
				printf "\t%s  %s\n", $md5sum, $path;
			}
			print "\n";
		}
	}
}
