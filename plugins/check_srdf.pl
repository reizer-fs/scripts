#!/tools/list/nagios/perl/bin/perl

=pod

=head1 COPYRIGHT

This software is Copyright (c) 2013 NETWAYS GmbH, Michael Friedrich
                               <support@netways.de>

(Except where explicitly superseded by other copyright notices)

=head1 LICENSE

This work is made available to you under the terms of Version 2 of
the GNU General Public License. A copy of that license should have
been provided with this software, but in any event can be snarfed
from http://www.fsf.org.

This work is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301 or visit their web page on the internet at
http://www.fsf.org.


CONTRIBUTION SUBMISSION POLICY:

(The following paragraph is not intended to limit the rights granted
to you to modify and distribute this software under the terms of
the GNU General Public License and is only of importance to you if
you choose to contribute your changes and enhancements to the
community by submitting them to NETWAYS GmbH.)

By intentionally submitting any modifications, corrections or
derivatives to this work, or any other work intended for use with
this Software, to NETWAYS GmbH, you confirm that
you are the copyright holder for those contributions and you grant
NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
royalty-free, perpetual, license to use, copy, create derivative
works based on those contributions, and sublicense and distribute
those contributions and any derivatives thereof.

Nagios and the Nagios logo are registered trademarks of Ethan Galstad.

=head1 NAME

check_srdf.pl - check srdf sync status, Configuration and current storage, Local and remote ID

=head1 SYNOPSIS

check_srdf.pl - check srdf sync status, Local Symmetrix configuration and VMAX array, Local and remote ID

check_srdf [-h|-v]

=head1 OPTIONS

=over

=item -h|--help

print help page

=item -v|--verbose

print verbose output

=cut

# includes
use warnings;

use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;
use Data::Dumper;

our $opt;
GetOptions (
	"t|timeout=i"		=> \$opt->{timeout},
	"h|help"        	=> \$opt->{help},
	"v|verbose"      	=> \$opt->{verbose}
);

pod2usage(1) if defined $opt->{help};

# some definitions
my %STATE = (
	'OK' => 0,
	'WARNING' => 1,
	'CRITICAL' => 2,
	'UNKNOWN' => 3
);

# getopts
my $fs = "/"; # a default
my $global_warn_perc = 80;
my $global_crit_perc = 90;
my $timeout = 30;

if (defined($opt->{threshold_warn})) {
	$global_warn_perc = $opt->{threshold_warn};
}
if (defined($opt->{threshold_crit})) {
	$global_crit_perc = $opt->{threshold_crit};
}
if (defined($opt->{timeout})) {
	$timeout = $opt->{timeout};
}

# set timeout alarm
$SIG{'ALRM'}=sub {
	print("Timeout ($timeout) reached.\n");
	exit $STATE{"UNKNOWN"};
};

# start timeout alarm
alarm($timeout);

# Verifie que symcfg est present sur la machine
if ( ! -e '/usr/symcli/bin/symcfg') {
	print("UNKNOWN: /usr/symcli/bin/symcfg not found\n");
	exit $STATE{"UNKNOWN"};
}

my $OS = `uname -s`;
chomp($OS);

if ( $OS eq "Linux" ) {
	$awk = 'awk';
	$sed = 'sed';
}elsif ( $OS eq "SunOS" ){
	$awk = 'gawk';
	$sed = 'gsed';
} else {
	print("UNKNOWN: Unsupported OS\n");
        exit $STATE{"UNKNOWN"};
}

my $cmd = "/usr/symcli/bin/symrdf list pd | " . $sed . " -n '/Total/q;p' | " . $sed . " '1,9'd";
@cmdoutput = `$cmd`;
my $ret = $?;

my $symidcmd = "/usr/symcli/bin/symcfg list | grep Local | " . $awk . " '{print \$1}'";
my $symid = `$symidcmd`;
my $cmd2 = "/usr/symcli/bin/symcfg discover 2>&1 >/dev/null ; /usr/symcli/bin/symcfg verify -sid " . $symid;
@cmdoutput2 = `$cmd2`;

# Pour le debug
#foreach (@cmdoutput) {
#       print "$_\n" ;
#}

my @perfdata;
my @ok;
my @unknown;
my @warn;
my @crit;


### Remove any empty lines
@cmdoutput2 = grep(/S/, @cmdoutput2);
foreach my $resultcmd (@cmdoutput2) {
	if ($resultcmd !~ 'file are in sync') {
	$out .= "The Symmetrix configuration and the database file are NOT in sync";
	push @warn, $out;
	}
}

### Remove any empty lines
@cmdoutput = grep(/S/, @cmdoutput);
foreach my $line (@cmdoutput) {
		my ($symdev, $symrdev, $rdftype, $statusSA, $statusRA, $statusLINK, $mode, $r1inv, $r2inv, $statedev, $staterdev, $state) = split / +/, $line;
		# Test local and remote are equal
		if ($symdev ne $symrdev){
			$out = "Local Device ID $symdev differs from the remote Device ID $symrdev";
                        push @warn, $out;
		}
		# Test local and remote are synchronized
                if ($state =~ '^Synchronized') {
			$out = "Device: $symdev is $state ($rdftype)";
                        push @ok, $out;
                }
		# We believe any other value than "synchronized" is critical
		else{
			$out = "Device: $symdev is $state";
                        push @crit, $out;
		}
                # save perfdata for each element
                #push @perfdata, $perf;
}
#print Dumper(\@warn);

# generate output, perfdata, exit state
my $out_prefix;
my $out_str;
my $exit_code = $STATE{'OK'};

if ((scalar(@unknown) > 0) && (scalar(@crit) == 0) && (scalar(@warn) == 0)) {
	$out_prefix = "UNKNOWN: ";
	$exit_code = $STATE{'UNKNOWN'};
	if (@ok > 0) {
		$out_str .= "\n" . join ", ", @ok;
	}
}
elsif (scalar(@warn) > 0 && scalar(@crit) == 0) {
	$out_prefix = "WARNING: ";
	$exit_code = $STATE{'WARNING'};
	$out_str = $out_prefix . join ", ", @warn;
	if (@ok > 0) {
		$out_str .= "\n" . join ", ", @ok;
	}
}
elsif (scalar(@crit) > 0) {
	$out_prefix = "CRITCAL: ";
	$exit_code = $STATE{'CRITICAL'};
	$out_str = $out_prefix . join " ", @crit;
	if (@warn > 0) {
		$out_str .= "\nWARNING: " . join ", ", @warn;
	}
	if (@ok > 0) {
		$out_str .= "\n" . join ", ", @ok;
	}
}
else {
	$out_prefix = "OK: Everything is OK \n";
	$exit_code = $STATE{'OK'};
	$out_str = $out_prefix . join "\n", @ok;
}

print "$out_str\n";
exit($exit_code);
