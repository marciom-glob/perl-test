#!/usr/bin/perl
use Tk;
use DBI;

$sql_apl = "SELECT DISTINCT Applicant from SHOPS order by upper(Applicant);";

my $database = "db/db.db";

# if the database already exists, he is deleted

my $dsn = "DBI:SQLite:dbname=$database";
my $dbh = DBI->connect($dsn, "", "", { RaiseError => 1 }) 
   or die $DBI::errstr;

my $sth = $dbh->prepare( $sql_apl );
my $sn_apl = $sth->execute() or die $DBI::errstr;

my @aplicants= ("*");
while(my @row = $sth->fetchrow_array()) {
  push @aplicants, $row[0];
}

my $mw = MainWindow->new;
$mw->title("Hello World");
$mw->Label(-text => "Shops!")->pack();
#$lb = $mw->Listbox(-selectmode => "single",-scrollbars => "e"->pack());
$lb = $mw->Listbox(-selectmode => "single")->pack( -fill => 'both'); 
$lb->insert('end', @aplicants);#qw/red yellow green blue grey/);
#$lb->insert('end', qw/red yellow green blue grey/); 
$lb->bind('<Button-1>', sub {
  my $sel = $lb->get($lb->curselection( ));
  my $sql_query = "SELECT Applicant,FacilityType, Address, FoodItems FROM SHOPS WHERE Applicant like '$sel\%';";
  my $sth = $dbh->prepare( $sql_query );
  my $sn_apl = $sth->execute() or die $DBI::errstr;
  $result = "===============================================================\n";
  while(my @row = $sth->fetchrow_array()) {
    my $item = <<ITEM;
Type =====> $row[1]
Address ==> $row[2]
Itens ====> $row[3]
===============================================================
ITEM
    $result .= $item;
  }
  $t->delete("1.0", 'end');
  $t->insert('end',$result) 
});
$t = $mw->Scrolled("Text")->pack(-fill => 'both', -expand => 1);
$mw->Button(-text => "Done", -command => sub { exit })->pack;
MainLoop;


