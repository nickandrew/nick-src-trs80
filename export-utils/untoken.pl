#!/usr/bin/perl
#	@(#) $Header$
#	Copyright (C) 2002, Nick Andrew (See http://www.nick-andrew.net/)
#	Released under the GNU General Public License.
#
#	Converts a tokenised BASIC file (trs-80 encoding) to plain text.
#
#	Usage: untoken.pl < filename ...

my $buffer;

my %map = (
	0x80 => 'END',
	0x81 => 'FOR',
	0x82 => 'RESET',
	0x83 => 'SET',
	0x84 => 'CLS',
	0x85 => 'CMD',
	0x86 => 'RANDOM',
	0x87 => 'NEXT',
	0x88 => 'DATA',
	0x89 => 'INPUT',
	0x8a => 'DIM',
	0x8b => 'READ',
	0x8c => 'LET',
	0x8d => 'GOTO',
	0x8e => 'RUN',
	0x8f => 'IF',
	0x90 => 'RESTORE',
	0x91 => 'GOSUB',
	0x92 => 'RETURN',
	0x93 => 'REM',
	0x94 => 'STOP',
	0x95 => 'ELSE',
	0x96 => 'TRON',
	0x97 => 'TROFF',
	0x98 => 'DEFSTR',
	0x99 => 'DEFINT',
	0x9a => 'DEFSNG',
	0x9b => 'DEFDBL',
	0x9c => 'LINE',
	0x9d => 'EDIT',
	0x9e => 'ERROR',
	0x9f => 'RESUME',
	0xa0 => 'OUT',
	0xa1 => 'ON',
	0xa2 => 'OPEN',
	0xa3 => 'FIELD',
	0xa4 => 'GET',
	0xa5 => 'PUT',
	0xa6 => 'CLOSE',
	0xa7 => 'LOAD',
	0xa8 => 'MERGE',
	0xa9 => 'NAME',
	0xaa => 'KILL',
	0xab => 'LSET',
	0xac => 'RSET',
	0xad => 'SAVE',
	0xae => 'SYSTEM',
	0xaf => 'LPRINT',
	0xb0 => 'DEF',
	0xb1 => 'POKE',
	0xb2 => 'PRINT',
	0xb3 => 'CONT',
	0xb4 => 'LIST',
	0xb5 => 'LLIST',
	0xb6 => 'DELETE',
	0xb7 => 'AUTO',
	0xb8 => 'CLEAR',
	0xb9 => 'CLOAD',
	0xba => 'CSAVE',
	0xbb => 'NEW',
	0xbc => 'TAB(',
	0xbd => 'TO',
	0xbe => 'FN',
	0xbf => 'USING',
	0xc0 => 'VARPTR',
	0xc1 => 'USR',
	0xc2 => 'ERL',
	0xc3 => 'ERR',
	0xc4 => 'STRING$',
	0xc5 => 'INSTR',
	0xc6 => 'POINT',
	0xc7 => 'TIME$',
	0xc8 => 'MEM',
	0xc9 => 'INKEY$',
	0xca => 'THEN',
	0xcb => 'NOT',
	0xcc => 'STEP',
	0xcd => '+',
	0xce => '-',
	0xcf => '*',
	0xd0 => '/',
	0xd1 => '^',
	0xd2 => 'AND',
	0xd3 => 'OR',
	0xd4 => '>',
	0xd5 => '=',
	0xd6 => '<',
	0xd7 => 'SGN',
	0xd8 => 'INT',
	0xd9 => 'ABS',
	0xda => 'FRE',
	0xdb => 'INP',
	0xdc => 'POS',
	0xdd => 'SQR',
	0xde => 'RND',
	0xdf => 'LOG',
	0xe0 => 'EXP',
	0xe1 => 'COS',
	0xe2 => 'SIN',
	0xe3 => 'TAN',
	0xe4 => 'ATN',
	0xe5 => 'PEEK',
	0xe6 => 'CVI',
	0xe7 => 'CVS',
	0xe8 => 'CVD',
	0xe9 => 'EOF',
	0xea => 'LOC',
	0xeb => 'LOF',
	0xec => 'MKI$',
	0xed => 'MKS$',
	0xee => 'MKD$',
	0xef => 'CINT',
	0xf0 => 'CSNG',
	0xf1 => 'CDBL',
	0xf2 => 'FIX',
	0xf3 => 'LEN',
	0xf4 => 'STR$',
	0xf5 => 'VAL',
	0xf6 => 'ASC',
	0xf7 => 'CHR$',
	0xf8 => 'LEFT$',
	0xf9 => 'RIGHT$',
	0xfa => 'MID$',
	0xfb => '\'',
);

# Couldn't possibly be longer than this!!

sysread(STDIN, $buffer, 409600);

	# First 0xff

if (ord(substr($buffer, 0, 1)) != 0xff) {
	die "Not a tokenized BASIC file!" . ord(substr($buffer, 0, 1)) . "\n";
}

	# Then "80 6a"
	# Then "0a 00" ... line 10
	# Then text
	# Then "00 8b 6a"
	# Then "14 00" ... line 20

$buffer = substr($buffer, 1);

while (length($buffer) >= 6) {

	my($unknown,$lineno,$text) = unpack('vvZ*', $buffer);

	last if ($unknown == 0);
	my $s;
	my $m;

	my $t = new TokenizedLine($text);
	my $c;
	my $state = -1;

	while (defined ($c = $t->getc())) {
		my $class = $t->class($c);
		my $o = ord($c);

		if ($state == -1) {
			# Beginning of line, no prior space
			$m .= '-1';
		} elsif ($state == 0) {
			# Space, just print another
			$m .= '0';
		} elsif ($state == 1) {
			# Ascii, just print it
			$m .= '1';
			if ($class == 2) {
				# Put a space before the token
				$s .= ' ';
			} elsif ($class == 5) {
				$s .= ' ';
			}
		} elsif ($state == 2) {
			# Put a space after last token
			$m .= '2';
			if ($class == 3) {
				# No space
			} elsif ($class == 0) {
				# No space
			} else {
				$s .= ' ';
			}
		} elsif ($state == 3) {
			# No space after (
			$m .= '3';
		} elsif ($state == 4) {
			$m .= '4';
		} elsif ($state == 5) {
			$m .= '5';
			if ($class != 0 && $class != 6) {
				$s .= ' ';
			}
		} elsif ($state == 6) {
			$m .= '6';
			if ($class == 1) {
				$s .= ' ';
			}
		}

		$s .= $t->convert($c);
		$m .= $t->convert($c);

		$state = $class;
	}

	printf "%05d   %s\n", $lineno, $s;

	# Output a debugging representation also
	printf STDERR "%05d | %s\n", $lineno, $m;

	my $i = 4 + length($text) + 1;
	$buffer = substr($buffer, $i);

}

package TokenizedLine;

sub new {
	my $class = shift;
	my $text = shift;

	my $self = { text => $text };
	$self->{'length'} = length($text);
	$self->{'pos'} = 0;

	bless $self, $class;

	return $self;
}

sub peek {
	my $self = shift;

	my $pos = $self->{'pos'};
	my $length = $self->{'length'};
	return undef if ($pos >= $length);

	my $text = $self->{'text'};
	my $c = substr($self->{'text'}, $self->{'pos'}, 1);

	return $c;
}

sub ungetc {
	my $self = shift;

	if ($self->{'pos'} > 0) {
		$self->{'pos'}--;
	}
}

sub getc {
	my $self = shift;

	my $c = $self->peek();
	if (defined $c) {
		$self->{'pos'}++;
	}

	return $c;
}

# Return character class:
# 0 = space, 1 = ascii, 2 = token, 3 = '(', 4 = [+-*/^=],
# 5 = [<], 6 = [>] or undef

sub class {
	my $self = shift;
	my $c = shift;

	return undef if (!defined $c);

	if ($c eq ' ') {
		return 0;
	} elsif ($c eq '(') {
		return 3;
	} elsif ($c =~ /[+*\/^=-]/) {
		return 4;
	} elsif ($c eq "\xd6") {
		return 5;
	} elsif ($c eq "\xd4") {
		return 6;
	} elsif (ord($c) > 0x7f) {
		return 2;
	}

	return 1;
}

sub convert {
	my $self = shift;
	my $c = shift;

	my $o = ord($c);

	if ($o >= 0x20 && $o <= 0x7e) {
		return $c;
	}

	if (exists $map{$o}) {
		return $map{$o};
	}

	# Otherwise, blurgh!
	return sprintf(" 0x%02x ", $o);
}
