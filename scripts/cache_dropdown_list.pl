#!/usr/local/bin/perl 
use strict;
use Data::Dumper;
use DBI;
use DBD::Pg;


# This script will get the all frequencies for all the articles in the database and store it in
# another table that will be used to populate the dropdown list.

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
my $sth2;

$sth = $dbh->prepare("select artid, atitle, count(artid) AS frequency from sessions group by artid order by frequency DESC;");
$sth->execute();

while (my @data = $sth->fetchrow_array()) {
	my $artid = $data[0];
    my $atitle = $data[1];
    my $freq = $data[2];
    
    #print $artid."\t|\t$freq\n";
    
  	$sth2 = $dbh->prepare("INSERT INTO aweights values ('$artid', '$atitle', $freq);");
	$sth2->execute();
}

# close connections
$sth->finish;
$sth2->finish;
$dbh->disconnect;


__END__

=pod

=head1 NAME

cache_dropdown_list.pl;

=head1 SYNOPSIS

This script will execute a query on the sessions table and will populate the 'aweights' table that
is essentially a cache for populating the web application's dropdown list fast as the query on the
sessions table is slow. You can change the default database tables at the start of this script.
The default database settings are:
host = "127.0.0.1";
database = "openurlrec";
user = "edina";
pw = "edina";
port = "3306";

=head1 USE

add_to_db.pl -m 4 -y 2011 -verbose

The above example will parse file 'L2_2011-04_mult_req-sessions.csv' and populate the MySQL database
specified at the beggining of this script.

=cut