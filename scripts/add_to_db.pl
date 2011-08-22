#!/usr/local/bin/perl 
use strict;
use Data::Dumper;
use Getopt::Long;
use Date::Manip::DM5;
use Lingua::StopWords qw( getStopWords );
use DBI;
use DBD::Pg;

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
my $file = $level2Path."L2_".$year."-".$month."_mult_req-sessions.csv";

open LOGFILE, $file or die "Could open file for printing\n"; 

my %sessionsData;

my $trash;
my $dedID;
my $stopwords = getStopWords('en');

my $host = "127.0.0.1";
my $database = "openurlrec";
my $user = "yourDBuser";
my $pw = "yourDBpassword";
my $port = "3306";

my $dsn = "dbi:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw, { RaiseError => 1, AutoCommit => 0 }) or die "cannot connect to database $dsn\n";
$dbh->{RaiseError} = 0;
$dbh->{PrintError} = 0;
my $sth;

# get the maximum sessionID from the session table
$sth = $dbh->prepare("select max(sessionid) AS maxSessID from sessions;");
$sth->execute();

my $sessionID = (($sth->fetchrow_array())[0])+1;

my $lineCount = `wc -l < $file`;
my $progressCnt=0;
my $progress=0;
my $progressMod;
$progressMod = int($lineCount/100);

print STDERR "Inserting data into database\n" if($verbose);

while (my $line = <LOGFILE>){			
	
	if($verbose){
		$progressCnt++;
		if($progressCnt%$progressMod==0){
			print STDERR "\r",$progress++,"% completed";
		}
	}
	
	if($line eq "\n" || $line eq "\r"){
		
		my $sessionDataSize = scalar(keys(%sessionsData));		
		
		if($sessionDataSize > 1){ # if any given session has more than one unique articles in it
			foreach my $key (keys %sessionsData) {			
				$sth = $dbh->prepare($sessionsData{$key});
				$sth->execute();
			}
			$sessionID++;
		}
		
		%sessionsData = (); # empty hash			
	}else{
		(my $logDate, my $logTime, my $digestIP, my $obfuscatedInstID, $trash, my $aulast, $trash, $trash, $trash, $trash, my $au, $trash, my $atitle, my $title, my $jtitle, $trash, my $date, $trash, $trash, my $volume, $trash, my $issue, my $spage, $trash, $trash, $trash, my $issn, my $eissn, my $isbn, $trash, $trash, my $genre, $trash, $trash, $trash, $trash, $trash, $trash, my $doi) = split(/\t/, $line);
		$jtitle = $title if($title ne "");
				
		if($issn ne "" && $spage ne "" && $date ne "" && $atitle ne "" && $atitle !~ /^\d+$/){					
							
			&normaliseISSN($issn);
			
			&normaliseSpage($spage);
			
			# extract the year from date
			my $manDate = ParseDate($date);
			my $manYear = substr($manDate, 0, 4);
			my $dateLength = length($date);
			
			if($manYear eq ""){
				if(substr($date, 0, 2) =~ "16|17|18|19|20" && substr($date, $dateLength-2, 2) eq "00" && $dateLength==8){
					$manYear = substr($date, 0, 4);					
				}elsif($date =~ /^.?\d{4}..?\d{4}.?\d?\d?$/ || $date =~ /^\d{4}.\d\d?.\d{4}\//){ # to match 2002-2003, 2002 (2003), (1872) 1974, (1989)1991 etc
					&normaliseDate($date);
					$manYear = $date;
				}else{			
					my $dateFirstElmnt = (split(/\-/, $date))[0];
					if(length($dateFirstElmnt)==4 && substr($date, 0, 2) =~ "^16|17|18|19|20"){
						$manYear = $dateFirstElmnt;
					}else{
						&normaliseDate($date);
						$manDate = ParseDate($date);
						$manYear = substr($manDate, 0, 4);
					}
					$manYear = $date if($manYear eq "");
				}			
			}
			
			#normalise the title
			my $dedTitle = lc($atitle);
			&normaliseTitle($dedTitle);
			
			my @words = split(/ /, $dedTitle);
	
			$dedTitle = join ' ', grep { !$stopwords->{$_} } @words;
			&removeSpaces($dedTitle);
			
			if(length($dedTitle)>25){
				$dedTitle = substr($dedTitle, 0, 25);
			}else{
				$dedTitle = substr($dedTitle, 0, length($dedTitle));
			}
			
			$dedID = "$issn-$spage-$manYear-$dedTitle";						
			
			&del_newLine($dedID, $digestIP, $obfuscatedInstID, $aulast, $au, $atitle, $jtitle, $date, $volume, $issue, $spage, $issn, $eissn, $isbn, $doi, $genre);						
			
			# PREPARE THE QUERY
			my $query = "INSERT INTO articles VALUES ('$dedID', '$digestIP', $obfuscatedInstID, '$aulast', '$au', '$atitle', '$jtitle', '$date', '$volume', '$issue', '$spage', '$issn', '$eissn', '$isbn', '$doi', '$genre')";
			
			$sth = $dbh->prepare($query);
			
			# EXECUTE THE QUERY
			$sth->execute();
			
			$sessionsData{"$dedID"} = "INSERT INTO sessions VALUES ('$dedID', $sessionID, '$atitle');"
		}
	}

}

print STDERR "\r100","% completed\n";

# close connections
$sth->finish;
$dbh->disconnect;


# function that removes all punctuation and spaces
sub normaliseISSN {
	foreach (@_) {s/\n/ /g} # remove new lines
	foreach (@_) {s/\r/ /g} # remove new lines
	foreach (@_) {s/\([^)]*\)//g} # remove words in parenthesis
	foreach (@_) {s/[[:punct:]]//g} # remove punctuation
	foreach (@_) {s/ //g} # remove spaces
	foreach (@_) {s/[a-wy-z]//gi} # delete all characters appart from X as it can be part of the actuall ISSN
}


sub normaliseSpage {
	foreach (@_) {s/\n/ /g} # remove new lines
	foreach (@_) {s/\r/ /g} # remove new lines
	foreach (@_) {s/[[:punct:]]//g} # remove punctuation
	foreach (@_) {s/ //g} # remove spaces
	foreach (@_) {s/(^.*)/\L\1/} # lower case
}


sub normaliseDate{
	foreach (@_) {s/[[:punct:]]//g} # remove punctuation
	foreach (@_) {s/ //g} # remove spaces
	foreach (@_) {s/[a-z]//gi} # delete all characters from a-z, lower and upper case
}

sub normaliseTitle {
	foreach (@_) {s/\n/ /g} # remove new lines
	foreach (@_) {s/\r/ /g} # remove new lines
	foreach (@_) {s/[[:punct:]]//g} # remove punctuation	
}

sub removeSpaces{
	foreach (@_) {s/ //g} # remove spaces
}

sub del_newLine { 
   foreach (@_) {s/\n/ /g}
   foreach (@_) {s/\r/ /g}
   foreach (@_) {s/'//g}
}


__END__

=pod

=head1 NAME

add_to_db.pl;

=head1 SYNOPSIS

This script will parse file 'L2_year-month_mult_req-sessions.csv' and insert data in a MySQL database.
Specify the database details at the start of the script. The default ones are:
host = "127.0.0.1";
database = "openurlrec";
user = "edina";
pw = "edina";
port = "3306";

=head1 USE

add_to_db.pl -m 4 -y 2011 -verbose

The above example will parse file 'L2_2011-04_mult_req-sessions.csv' and populate the MySQL database
specified in the beggining of this script.

=cut