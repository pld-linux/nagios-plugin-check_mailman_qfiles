#!/usr/bin/perl

## check_mailman_qfiles
#
#  Simple perl script to check the various mailman qfiles directories for old,
#  unprocessed items and report on freshness.
#
#  Eric Waters <ewaters@xmission.com> 27-Apr-2007

use strict;
use warnings;
use File::Find::Rule;
use Getopt::Long;

my $qfiles_base = '/var/lib/mailman/qfiles';
my %opts = (
	warning => 5,   # 5 minutes
	critical => 20, # 20 minutes
);
GetOptions(
	'warning=i' => \$opts{warning},
	'critical=i' => \$opts{critical},
);

# convert to seconds
$opts{warning} *= 60;
$opts{critical} *= 60;

my %problems;
my $problem_status;

foreach my $qdir (qw(archive bounces commands in news out retry)) {
	# Get all the 'pickle' files in the queue directory
	my @files = File::Find::Rule->file->name('*.pck')->in("$qfiles_base/$qdir");
	next unless @files;

	# Get the modification times of the files, sorted desc
	my @mtimes = sort { $a <=> $b } map { (stat($_))[9] } @files;

	# Age of the oldest file in queue
	my $diff = time - $mtimes[0];

	if ($diff > $opts{critical}) {
		$problems{$qdir} = [ 'CRITICAL' ];
		$problem_status = 'CRITICAL';
	}
	elsif ($diff > $opts{warning}) {
		$problems{$qdir} = [ 'WARNING' ];
		$problem_status = 'WARNING' if ! $problem_status;;
	}

	if ($problems{$qdir}) {
		$problems{$qdir}[1] = sprintf "%d tasks, oldest %s", int(@files), describe_diff($diff);
	}
}

if (! $problem_status) {
	print "all normal\n";
	exit 0;
}

print join('; ', map { "$_ has $problems{$_}[1]" } sort keys %problems)."\n";;

exit ($problem_status eq 'CRITICAL' ? 2 : 1);

sub describe_diff {
	my $diff = shift;

	my $units = 'sec';
	if ($diff > 60) {
		$diff /= 60;
		$units = 'min';
	}
	if ($units eq 'min' && $diff > 60) {
		$diff /= 60;
		$units = 'hr';
	}
	if ($units eq 'day' && $diff > 24) {
		$diff /= 24;
		$units = 'day';
	}
	return sprintf "%.1f %s%s", $diff, $units, $diff == 1 ? '' : 's';
}
