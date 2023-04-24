use strict;

use LWP::Simple;

my $url = "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv";

my $data = "data/data.csv";

my $status = getstore($url, $data);

print "File Downloaded!\n";
