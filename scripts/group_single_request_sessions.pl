#!/usr/local/bin/perl 
use strict;
use File::Slurp;
use DateTime;
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
my $line;
my $trash;
my $ipSection;
my $ipAddress;
my @logFileLines;
my $sessionNoOfReq=0;


@logFileLines = read_file($level2Path."L2_$year-$month"."_sessions.csv");
my $filelines = @logFileLines;

my $progressCnt=0;
my $progress=0;
my $progressMod = int($filelines/100);

my $sessionNoOfReq=0;

# the time limit (in seconds) that will decide whether two requests of the same IP address should
# be part of the same session or not. 
my $timeLapse = 9498;

my $lastReqOfPreviousSession;
my $singleReqLine;
my $firstReqOfNextSession;

my $sessionNoOfReq=0;

print STDERR "Grouping single request sessions:\n" if($verbose);

for (my $i=0; $i<$filelines; $i++){

	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}		
	}
	
	my $currentLine = @logFileLines[$i];
	
	if($currentLine eq "\n"){		
		if($sessionNoOfReq==1){
		
			$lastReqOfPreviousSession = @logFileLines[$i-3];
			$singleReqLine = @logFileLines[$i-1];
			$firstReqOfNextSession = @logFileLines[$i+1];
			
			# if the last request in the file is a single request session then proceeding will throw
			# an error as there is no request after it in the array to retrieve so exit loop.
			next if($firstReqOfNextSession eq "");									
			
			(my $date1, my $time1, my $ip1) = split(/\t/, $lastReqOfPreviousSession);
			(my $date2, my $time2, my $ip2) = split(/\t/, $singleReqLine);
			(my $date3, my $time3, my $ip3) = split(/\t/, $firstReqOfNextSession);
			
			(my $year1, my $month1, my $day1) = split(/-/, $date1);
			(my $year2, my $month2, my $day2) = split(/-/, $date2);
			(my $year3, my $month3, my $day3) = split(/-/, $date3);
			
			(my $hour1, my $min1, my $sec1) = split(/:/, $time1);
			(my $hour2, my $min2, my $sec2) = split(/:/, $time2);
			(my $hour3, my $min3, my $sec3) = split(/:/, $time3);
			
			my $dt1 = DateTime->new(year => $year1, month => $month1, day => $day1, hour => $hour1, minute => $min1, second => $sec1, nanosecond => 000000000, time_zone  => 'GMT',);
			my $dt2 = DateTime->new(year => $year2, month => $month2, day => $day2, hour => $hour2, minute => $min2, second => $sec2, nanosecond => 000000000, time_zone  => 'GMT',);
			my $dt3 = DateTime->new(year => $year3, month => $month3, day => $day3, hour => $hour3, minute => $min3, second => $sec3, nanosecond => 000000000, time_zone  => 'GMT',);
			
			my $dateDiff_2_1 = $dt2->subtract_datetime_absolute($dt1);
			my $dateDiff_2_3 = $dt2->subtract_datetime_absolute($dt3);
			
			my $dateDiff_2_1Sec = $dateDiff_2_1->seconds;
			my $dateDiff_2_3Sec = $dateDiff_2_3->seconds;
			
			
			if($ip2 eq $ip1 && $ip2 eq $ip3){
				if($dateDiff_2_1Sec<$timeLapse && $dateDiff_2_3Sec<$timeLapse){

					if($dateDiff_2_1Sec < $dateDiff_2_3Sec){
						delete @logFileLines[$i-2];
					}else{
						delete @logFileLines[$i];
					}
				}elsif($dateDiff_2_1Sec<$timeLapse){					
					delete @logFileLines[$i-2];
				}elsif($dateDiff_2_3Sec<$timeLapse){
					delete @logFileLines[$i];
				}
				
			}elsif($ip1 eq $ip2){
				if($dateDiff_2_1Sec < $timeLapse){
					# print to file without new line in between
					delete @logFileLines[$i-2];	
				}
				
			}elsif($ip2 eq $ip3){
				if($dateDiff_2_3Sec < $timeLapse){
					delete @logFileLines[$i];
				}
			
			}
		}		
		$sessionNoOfReq=0;
	}else{
		$sessionNoOfReq++;
	}
}
print STDERR "\r100","% completed\n" if($verbose);
print STDERR "Printing grouped sessions into file 'L2_$year-$month"."_grouped-sessions.csv'\n" if($verbose);

my $out_doc = $level2Path."L2_$year-$month"."_grouped-sessions.csv";
open(OUT_DOC, '>:utf8', $out_doc ) or die "Can't open out file: $out_doc\n";

foreach my $elmnt (@logFileLines){
	if(defined($elmnt)){
		print OUT_DOC $elmnt;	
	}
}


__END__

=pod

=head1 NAME

group_single_request_sessions.pl

=head1 SYNOPSIS

This script will parse a file 'L2_year-month_sessions.csv' and produce a file 
'L2_year-month_grouped-sessions.csv'. This file is essentially the same as the
'L2_year-month_sessions.csv' with the only difference that some of the 
single request sessions are grouped to neighbour sessions. This is to soften
the brutal separation into sessions due to the 15min cut-off point.

=head1 DEPENDENCIES

This script depends totally on the the get_proxy_free_data.pl script which has to
be run first as well as to the get_sessions.pl script before that. This is because it is 
necessary to have a parsed file where requests are sorted by IP address and divided
into sessions.

=head1 USE

perl group_single_request_sessions.pl -m 4 -y 2011 -verbose

The above example will parse file L2_2011-04_sessions.csv and produce 
L2_2011-04_grouped-sessions.csv

=cut