#! /usr/bin/perl
use strict;
# Program
# Loader.pl
#
# Author
# Marcio Mendonça
#
# Function
# This file take the CSV file and create a SQLite dataabase for more easy querys
# For this test I presume a file named Mobile_Food_Facility_Permit.csv in 'data' directory 
# a database name db is created in 'db' directory
#
# Dependencies:
# DBI
# Text::CSV
# DBD::SQLite
#
# Todo
# - More configuration options

use Text::CSV;
use DBI;

my $database = "db/db.db";

# if the database already exists, he is deleted
if(-e $database){
  qx(rm $database);
  print "old database erased\n"
}

my $dsn = "DBI:SQLite:dbname=$database";
my $dbh = DBI->connect($dsn, "", "", { RaiseError => 1 }) 
   or die $DBI::errstr;

# Todo: make a better data analysis for better fields typing 
my $sql_create = <<SQLEND;
CREATE TABLE SHOPS
(
  locationid  TEXT    NOT NULL,
  Applicant TEXT    NOT NULL,
  FacilityType  TEXT    NOT NULL,
  cnn TEXT    NOT NULL,
  LocationDescription TEXT    NOT NULL,
  Address TEXT    NOT NULL,
  blocklot  TEXT    NOT NULL,
  block TEXT    NOT NULL,
  lot TEXT    NOT NULL,
  permit  TEXT    NOT NULL,
  Status  TEXT    NOT NULL,
  FoodItems TEXT    NOT NULL,
  X TEXT    NOT NULL,
  Y TEXT    NOT NULL,
  Latitude  TEXT    NOT NULL,
  Longitude TEXT    NOT NULL,
  Schedule  TEXT    NOT NULL,
  dayshours TEXT    NOT NULL,
  NOISent TEXT    NOT NULL,
  Approved  TEXT    NOT NULL,
  Received  TEXT    NOT NULL,
  PriorPermit TEXT    NOT NULL,
  ExpirationDate  TEXT    NOT NULL,
  Location  TEXT    NOT NULL,
  Fire_Prevention_Districts TEXT    NOT NULL,
  Police_Districts  TEXT    NOT NULL,
  Supervisor_Districts  TEXT    NOT NULL,
  Zip_Codes TEXT    NOT NULL,
  Neighborhoods__old  TEXT    NOT NULL
);
SQLEND

my $res = $dbh->do($sql_create);

if($res < 0){
  print $DBI::errstr;
}

my $csv = Text::CSV->new({ sep_char => ',' });

my $arq = 'data/Mobile_Food_Facility_Permit.csv';
open(ARQ, $arq) or die "Can't open the file";

my $c = 1; # Line count
my @cabec; # Fields from the CSV file
my $nflds; # number of fields
my $reg; # Pointer for the struct of the register (line)
my @regs; # Array of Above pointers
while(my $line = <ARQ>){
  chomp $line;
  $csv->parse($line);
  my @flds = $csv->fields();
  if($c == 1){
    $nflds = scalar @flds;
    for(my $i=0; $i<$nflds; $i++){
      $flds[$i] =~ s/[)]//g;
      $flds[$i] =~ s/[ ()]/_/g;
    }
    @cabec = @flds;
    my @cabec_ret;
    foreach my $cab(@cabec){
      print "$cab\n"
    } 
  } else {
    $reg = {};
    for(my $i=0;$i<$nflds;$i++){
      if ($flds[$i] =~ m/['"]/){
        $flds[$i] =~ s/['"]/`/g;
        print "$c ==> $flds[$i]\n"
      }
      $reg->{$cabec[$i]}=$flds[$i];
    }
    push @regs, $reg;
    # print "$c ==>\n";	
    foreach my $k (sort keys %$reg){
      my $v = %$reg{$k};
      # print "\t$k	TEXT    NOT NULL,
    }
  }
  $c++;
}
close ARQ;

foreach my $r(@regs){
  my $s_flds = join(',', @cabec);
  my $s_vals = '';
  print "----------------------------------------------------------------\n\n"; 
  for my $k(@cabec){
    my $val = %$r{$k};
    if ($s_vals ne  ''){
      $s_vals .= ','
    }
    $s_vals .= "'$val'";
  }
  my $sql_ins = <<SQLEND;
  INSERT into SHOPS($s_flds) values ($s_vals);
SQLEND
  print $sql_ins;
  my $rv = $dbh->do($sql_ins) or die $DBI::errstr;
  print "Inserted!\n"
}


print "============================================================================== \n";
print "ok\n";

