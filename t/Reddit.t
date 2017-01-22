use strict;
use warnings;

use Test2::Bundle::Extended;
use WebService::Reddit ();

my $reddit
    = WebService::Reddit->new( app_key => 'foo', app_secret => 'bar', );

ok( $reddit, 'create object' );

done_testing;
