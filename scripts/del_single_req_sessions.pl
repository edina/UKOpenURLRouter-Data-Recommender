#!/usr/local/bin/perl 
use strict;
use Data::Dumper;
use File::Slurp;
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

my $level2Path = "../data/";

my @logFileLines = read_file($level2Path."L2_".$year."-".$month."_grouped-sessions.csv");

my $fileLines = @logFileLines;
my $sessionNoOfReq = 0;

print STDERR "Deleting single request sessions\n" if($verbose);

my $progressCnt=0;
my $progress=0;
my $progressMod = int($fileLines/100);

for (my $i=0; $i<$fileLines; $i++){		
	
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	
	if(@logFileLines[$i] eq "\n"){								
		
		if($sessionNoOfReq==1){
			delete @logFileLines[$i];
			delete @logFileLines[$i-1];
		}
		$sessionNoOfReq=0;
	}else{
		$sessionNoOfReq++;
	}
}

print STDERR "\r100","% completed\n" if($verbose);

# if the last session is a single request session then delete it
my $line3 = @logFileLines[$fileLines-2];
my $line2 = @logFileLines[$fileLines-1];
my $line1 = @logFileLines[$fileLines];

if($line1 eq ""){	
	if(defined($line2) && ($line3 eq "\n" || $line3 eq "\r")){
		delete (@logFileLines[$fileLines]);
		delete (@logFileLines[$fileLines-1]);
	} 
}elsif(defined($line1) && ($line2 eq "\n" || $line2 eq "\r")){
	delete (@logFileLines[$fileLines]);
}

my $out_file = $level2Path."L2_".$year."-".$month."_mult_req-sessions.csv";

print STDERR "Printing final session file to '".$level2Path."L2_".$year."-".$month."_mult_req-sessions.csv'\n" if($verbose);

open(OUT_FILE, '>:utf8', $out_file ) or die "Can't open out file: $out_file\n";

foreach my $elmnt (@logFileLines){
	if(defined($elmnt)){
		print OUT_FILE $elmnt;
	}
}

__END__

=pod

=head1 NAME

del_single_request_sessions.pl

=head1 SYNOPSIS

This script will parse a file 'L2_year-month_grouped-sessions.csv' and produce a file 
'L2_year-month_mult_req-sessions.csv'. This script will essentially remove all the
single request sessions that have failed to be grouped to a neighbour session.  

=head1 DEPENDENCIES

This script depends totally on the extract_proxy_free.pl, get_sessions.pl and
group_single_request_sessions.pl which should be run in that sequence before running
this script.

=head1 USE

perl del_single_request_sessions.pl -m 4 -y 2011 -verbose

The above example will parse file L2_2011-04_grouped-sessions.csv and produce 
L2_2011-04_mult_req-sessions.csv

=cut