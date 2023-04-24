#!/usr/bin/perl
use Tk;
use DBI;

use constant ADDRESS => 2;
use constant TYPE => 1;
use constant ITEMS => 3;

$query_list_applicant = "SELECT DISTINCT Applicant from SHOPS order by upper(Applicant);";

my $database = "db/db.db";

my $database_connection_string = "DBI:SQLite:dbname=$database";
my $database_connection = DBI->connect($database_connection_string, "", "", { RaiseError => 1 }) 
   or die $DBI::errstr;

my $statement = $database_connection->prepare( $query_list_applicant );
$statement->execute() or die $DBI::errstr;

my @applicants= ("*");
while(my @row = $statement->fetchrow_array()) {
  push @applicants, $row[0];
}

my $main_window = MainWindow->new;
$main_window->title("Restaurant Finder!");
$main_window->Label(-text => "Shops!")->pack();
$applicants_list = $main_window->Scrolled("Listbox", -scrollbars => "e", -selectmode => "single")->pack( -fill => 'both');
$applicants_list->insert('end', @applicants);#qw/red yellow green blue grey/);
$applicants_list->bind('<Button-1>', sub {
  my $applicant_selected = $applicants_list->get($applicants_list->curselection( ));
  my $sql_query = "SELECT Applicant,FacilityType, Address, FoodItems FROM SHOPS WHERE Applicant like '$applicant_selected\%';";
  my $statement = $database_connection->prepare( $sql_query );
  $statement->execute() or die $DBI::errstr;
  $result = "===============================================================\n";
  while(my @row = $statement->fetchrow_array()) {
    my $type = $row[ADDRESS];
    my $address = $row[TYPE];
    my $string_items = $row[ITEMS];
    $string_items =~ s/\: /\n/g;
    my $applicant_text = <<ITEM;
Type =====> $type
Address ==> $address
Itens ====\\/ 
$string_items
===============================================================
ITEM
    $result .= $applicant_text;
  }
  $result_text->delete("1.0", 'end');
  $result_text->insert('end',$result) 
});
$result_text = $main_window->Scrolled("Text")->pack(-fill => 'both', -expand => 1);
$main_window->Button(-text => "Done", -command => sub { exit })->pack;
MainLoop;


