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

my $database_connection_string = "DBI:SQLite:dbname=$database";
my $database_connection = DBI->connect($database_connection_string, "", "", { RaiseError => 1 }) 
   or die $DBI::errstr;

# Todo: make a better data analysis for better fields typing 
my $query_create = <<SQLEND;
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

my $execution_result = $database_connection->do($query_create);

if($execution_result < 0){
  print $DBI::errstr;
}

my $csv_parser = Text::CSV->new({ sep_char => ',' });

my $input_file = 'data/data.csv';
open(INPUT_FILE, $input_file) or die "Can't open the file";

my $line_counter = 1; # Line count
my @field_names; # Fields from the CSV file
my $number_fields; # number of fields
my $register_pointer; # Pointer for the struct of the register (line)
my @registers; # Array of Above pointers
while(my $line = <INPUT_FILE>){
  chomp $line;
  $csv_parser->parse($line);
  my @register_values = $csv_parser->fields();
  if($line_counter == 1){
    $number_fields = scalar @register_values;
    for(my $i=0; $i<$number_fields; $i++){
      $register_values[$i] =~ s/[)]//g;
      $register_values[$i] =~ s/[ ()]/_/g;
    }
    @field_names = @register_values;
  } else {
    $register_pointer = {};
    for(my $i=0;$i<$number_fields;$i++){
      if ($register_values[$i] =~ m/['"]/){
        $register_values[$i] =~ s/['"]/`/g;
      }
      $register_pointer->{$field_names[$i]}=$register_values[$i];
    }
    push @registers, $register_pointer;
  }
  $line_counter++;
}
close INPUT_FILE;

foreach my $register(@registers){
  my $string_field_names = join(',', @field_names);
  my $string_field_values = '';
  print "----------------------------------------------------------------\n\n"; 
  for my $field_name(@field_names){
    my $field_value = %$register{$field_name};
    if ($string_field_values ne  ''){
      $string_field_values .= ','
    }
    $string_field_values .= "'$field_value'";
  }
  my $query_ins = <<SQLEND;
  INSERT into SHOPS($string_field_names) values ($string_field_values);
SQLEND
  #print $query_ins;
  my $return_query_insert = $database_connection->do($query_ins) or die $DBI::errstr;
  my $location_id = %$register{locationid};
  my $applicant = %$register{Applicant};
  print "($location_id ==> $applicant) Inserted!\n"
}


print "============================================================================== \n";
print "ok\n";

