use strict;
use warnings;

use Devel::Confess;
use Path::Tiny qw( path );
use Test::RequiresInternet (
    'oauth.reddit.com' => 443,
    'www.reddit.com'   => 443,
);
use Test2::Bundle::Extended;
use Test2::Compare qw( compare );
use WebService::Reddit ();

use WWW::Mechanize;
use LWP::ConsoleLogger::Easy qw( debug_ua );
my $ua = WWW::Mechanize->new( autocheck => 0 );
debug_ua($ua);

my $reddit = WebService::Reddit->new(
    access_token  => 'qux',
    app_key       => 'foo',
    app_secret    => 'bar',
    refresh_token => 'baz',
    ua            => $ua,
);

ok( $reddit, 'create object' );

like(
    dies { $reddit->get('/api/v1/me') },
    qr{Cannot refresh token}i,
    'exception on bad auth'
);

my $filename = 'credentials.conf';
my $config   = get_config();

# cp credentials.conf.sample credentials.conf
#
# to enable testing with credentials

SKIP: {
    skip "$filename not found", 1, unless $config;
    ok( 'placeholder', 'placeholder test' );
}

sub get_config {
    my $file = path($filename);
    return undef unless $file->exists;
    my $contents = $file->slurp;
    ## no critic (BuiltinFunctions::ProhibitStringyEval)
    return eval $contents || die $!;
}

done_testing;
