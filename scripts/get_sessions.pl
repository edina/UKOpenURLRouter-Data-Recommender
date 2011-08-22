#!/usr/local/bin/perl
use strict;
use Getopt::Long;
use IO::Handle;
use File::Slurp;
use DateTime;
use Getopt::Long;


my $year;
my $month;
my $strMonth;
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
	$strMonth = "0".$month;	
}else{
	$strMonth = $month;
}

my $level2Path = "../data/";

my $sessionLapse = 900; # lapse time between requests in seconds
my @proxyFreeData = read_file($level2Path."L2_$year-$strMonth"."_proxy-free.csv");
my $lineCount = @proxyFreeData;

my %ips;
my $index=0;
print STDERR "Getting timestamps for each IP\n" if($verbose);

my $progressCnt=0;
my $progress=0;
my $progressMod;
$progressMod = int($lineCount/100);

foreach my $line (@proxyFreeData){
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	
	(my $date, my $time, my $ip) = split(/\t/, $line);				
	push @{ $ips{"$ip"} }, [$date."-".$time, $index];	
	
	$index++;
}

print STDERR "\r100","% completed\n" if($verbose);

my %sessions;
my $lastIndexAdded;
my $sessionCnt=0;
$progressMod = (scalar keys %ips)/100;
print STDERR "Grouping requests into sessions\n" if($verbose);
$progressCnt=0;
$progress=0;

for my $key (keys %ips) {
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	
	$sessionCnt++;
		
	my $arrayLength = $#{ $ips{$key}};
	
	# get the timestamp and index of the first element and add it to the 1st session for this IP
	my $timeStamp1 = $ips{$key}[0][0];
    my $index1 = $ips{$key}[0][1];
    push @{ $sessions{$sessionCnt} },  $index1;	
	
	for my $i ( 0 .. $arrayLength-1 ) {
		
		$timeStamp1 = $ips{$key}[$i][0];
		$index1 = $ips{$key}[$i][1];
		        
        my $timeStamp2 = $ips{$key}[$i+1][0];
        my $index2 = $ips{$key}[$i+1][1];
        
        (my $year, my $month, my $day, my $time) = split(/-/, $timeStamp1);
        (my $hour, my $minutes, my $seconds) = split(/:/, $time);
        
        #print "$year - $month - $day | $hour:$minutes:$seconds\n";
        my $dt1 = DateTime->new(
			  year       => $year,
			  month      => $month,
			  day        => $day,
			  hour       => $hour,
			  minute     => $minutes,
			  second     => $seconds,
			  nanosecond => 000000000,
			  time_zone  => 'GMT',
		  );
		  
		(my $year, my $month, my $day, my $time) = split(/-/, $timeStamp2);
		(my $hour, my $minutes, my $seconds) = split(/:/, $time);
				
				
		#print "$year - $month - $day | $hour:$minutes:$seconds\n";
		
		my $dt2 = DateTime->new(
			  year       => $year,
			  month      => $month,
			  day        => $day,
			  hour       => $hour,
			  minute     => $minutes,
			  second     => $seconds,
			  nanosecond => 000000000,
			  time_zone  => 'GMT',
		  );
		  
		my $dateDiff = $dt1->subtract_datetime_absolute($dt2);                
                
        # change session when lapse time is greater than sessionLapse
        if($dateDiff->seconds > $sessionLapse){	        
	    	$sessionCnt++;	    	
	    }
	    push @{ $sessions{$sessionCnt} },  $index2;	
	}
}
print STDERR "\r100","% completed\n" if($verbose);

my $out_doc = $level2Path."L2_$year-$strMonth"."_sessions.csv";

open(OUT_DOC, '>:utf8', $out_doc ) or die "Can't open out file: $out_doc\n";

print STDERR "Printing sessions into ".$level2Path."L2_$year-$strMonth"."_sessions.csv\n" if($verbose);

foreach my $key (sort {$a <=> $b} (keys %sessions)){
	my $sessionFreqCnt = 0;
	foreach my $arrayElemnt (@{$sessions{$key}}){
		$sessionFreqCnt++;		
		print OUT_DOC @proxyFreeData[$arrayElemnt];
	}
	print OUT_DOC "\n";
}



__END__

=pod

=head1 NAME

get_sessions.pl

=head1 SYNOPSIS

This script will parse a file 'L2_year-month_proxy-free.csv' and produce a file 
L2_year-month_sessions.csv where sessions requests are sorted by IP address
(encrypted) and divided in sessions. At the moment a 15min cut-off point has been
set to separate sessions. This means that two requests coming from one IP address
will be splited into two session if and only if the idle time between them is greater
than 15min. Sessions are separated by a new line.

=head1 DEPENDENCIES

This script depends totally on the existence get_proxy_free_data.pl script which has to
be run first.

=head1 USE

perl get_sessions.pl -m 4 -y 2011 -verbose

The above example will parse file L2_2011-04_proxy-free.csv and produce 
L2_2011-04_sessions.csv

=cut