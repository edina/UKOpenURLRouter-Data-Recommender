#!/usr/local/bin/perl 
use strict;
use Getopt::Long;


my $year;
my $month;
my $verbose;

my $result = GetOptions ("month=i" => \$month, # numeric
					  	 "year=i" => \$year, # numeric
					  	 "verbose" => \$verbose); # flag
$verbose=0 if($verbose eq "");

# validate date
die "INPUT ERROR: Values of month and year should all be numerical\n" if($result!=1);
die "INPUT ERROR: Month should be between 1 and 12\n" if ($month<1 || $month >12);

# the month in the log filenames have 2 digits so if it's less or equal to 9 add a zero infront
if($month < 10){
	$month = "0".$month;	
}else{
	$month = $month;
}

my $level2FileName = "L2_$year-$month.csv";
my $level2Path = "../data/";
my $level2FilePath = $level2Path.$level2FileName;

print STDERR "Getting IP frequencies from '$level2FilePath' \n" if($verbose);

open L2FILE, $level2FilePath;
my $lineCount = `wc -l < $level2FilePath`;
my %ips;

my $progressCnt=0;
my $progress=0;
my $progressMod;
$progressMod = int($lineCount/100);

# get the IP frequencies
while (my $line = <L2FILE>){
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	my $ip = (split(/\t/, $line))[2];
	$ips{"$ip"}++;
}
print STDERR "\r100","% completed\n" if($verbose);

#################################################
############## GET PROXY FREE DATA ############## 
#################################################

#open L2FILE, $level2FilePath;
my $frequencyLimit = 40;

my $level2ProxyFree = $level2Path."L2_$year-$month"."_proxy-free.csv";

print STDERR "Printing proxy-free data to '$level2ProxyFree'\n" if($verbose);
open(LEVEL2_PROXYFREE, '>:utf8', $level2ProxyFree ) or die "Attempting to open file '$level2ProxyFree' for printing proxy-free data -> Failed";

# place pointer at start of file
seek(L2FILE, 0, 0);

$progressCnt=0;
$progress=0;
while (my $line = <L2FILE>){
	
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	
	my $ipAddress = (split(/\t/, $line))[2];
	chomp($ipAddress);
	my $freq = $ips{$ipAddress};
	
	if($freq <= $frequencyLimit && $freq >1){
		print LEVEL2_PROXYFREE $line;
	}
}

print STDERR "\r100","% completed\n" if($verbose);

close(LEVEL2_PROXYFREE);
close(L2FILE);

__END__

=pod

=head1 NAME

extract_proxy_free.p;

=head1 SYNOPSIS

This script will parse a file with bibliographical metadata with name in the format of:
L2_2011-06.csv and will produce one csv file that is essentialy a subset of the file
L2_year-month.csv. It contains all the proxy free requests. At the moment, this
is done by discarding all requests that come from an IP address whose frequency
across the whole monthly set is greater than 40. The $frequencyLimit variable
sets this value.

=head1 USE

extract_proxy_free.pl -m 4 -y 2011 -verbose

The above example will parse the appropriate raw log for April 2011.
Run in verbose mode to see messages printed out on your terminal that
describe the current stage of the script.

=cut