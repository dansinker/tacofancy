#!/usr/bin/perl

use File::Basename;

sub indent_for_path ($) {
	my $slashes = $_[0] =~ tr/\//\//;
	return "\t" x $slashes;
}

sub make_line_for_path ($) {
	my $label = $_[0];
	# strip directory and file extension
	$label =~ s/^.*\/(.*?)\.md$/\1/;
	# replace underscores with spaces
	$label =~ tr/_/ /;
	# capitalize all words
	$label =~ s/\b(\w)/\U$1/g;
	return indent_for_path($_[0]) . '* [' . $label . '](' . $_[0] . ')';
}

# read existing INDEX.md

my $dir = dirname($0);
my $output = '';
my %lines = ();
my %unhandled = ();
our @categories = ();
open(my $in, '<', $dir . '/INDEX.md');
while (<$in>) {
	if (/^\s*(\* .*\(\/*([^\)]*)\))/) {
		$lines{$2} = indent_for_path($2) . $1;
		$unhandled{$2} = 1;
		if (!($2 =~ /\//)) {
			push @categories, $2;
		}
	} elsif ($#lines >= 0) {
		print "Skipping line $_";
	} else {
		$output .= $_;
	}
}
close($in);

# enumerate all the recipes in *.md files

my @files = ();
open(my $in, '-|', 'git', '--git-dir=' . $dir . '/.git', 'ls-files', '*/*.md');
while (<$in>) {
	s/\r?\n$//;
	# skip README.md files
	next if /\/README.md$/;
	push @files, $_;
	if (/^(.+)\/.*$/) {
		my $leading = $1;
		if (!defined($lines{$leading})) {
			$lines{$leading} = make_line_for_path($_);
			$unhandled{$leading} = 1;
			push @categories, $leading;
		}
	}
	if (!defined($lines{$_})) {
		$lines{$_} = make_line_for_path($_);
	}
}
close($in);

# sort (case-insensitively) each category separately

foreach (@categories) {
	my $category = $_;
	$output .= $lines{$category} . "\n";
	delete $unhandled{$category};
	my @output2 = ();
	foreach (keys %lines) {
		if (/^$category\//) {
			push @output2, $lines{$_};
			delete $unhandled{$_};
		}
	}
	foreach (sort { lc($a) cmp lc($b) } @output2) {
		$output .= $_ . "\n";
	}
}

# warn about lines we used to have but no longer do

foreach (keys %unhandled) {
	if (!/^\s*$/) {
		print 'Deleting line: ' . $lines{$_} . $_ . "\n";
	}
}

# write a new INDEX.md

open(my $out, '>', $dir . '/INDEX.md');
print $out $output;
close($out);
