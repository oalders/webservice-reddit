package WebService::Reddit;

use Moo;

use Types::Standard qw( Bool InstanceOf Str );
use WWW::Mechanize               ();
use WebService::Reddit::Response ();

has access_token => (
    is     => 'ro',
    isa    => Str,
    writer => '_set_access_token',
);

has _app_key => (
    is       => 'ro',
    isa      => Str,
    init_arg => 'app_key',
    required => 1,
);

has _app_secret => (
    is       => 'ro',
    isa      => Str,
    init_arg => 'app_secret',
    required => 1,
);

has _refresh_token => (
    is       => 'ro',
    isa      => Str,
    init_arg => 'refresh_token',
    writer   => '_set_token',
);

has ua => (
    is      => 'ro',
    isa     => InstanceOf ['LWP::UserAgent'],
    lazy    => 1,
    default => sub { WWW::Mechanize->new( autocheck => 0 ) },
);

# Make a whole bunch of unsafe assumptions
sub get {
    my $self = shift;
    my $url  = shift;

    my $res = WebService::Reddit::Response->new(
        raw => $self->ua->get( $url, $self->_auth ) );
    if ( $res->code == 401 ) {
        my $token_res = $self->_get_new_access_token;
        die 'Cannot refresh token: ' . np($token_res)
            unless $token_res->code == 200;
        $res = WebService::Reddit::Response->new(
            raw => $self->ua->get( $url, $self->_auth ) );
    }
    return $res;
}

sub _auth {
    my $self = shift;
    return ( Authorization => 'bearer ' . $self->access_token );
}

sub _get_new_access_token {
    my $self = shift;
    $self->ua->credentials( $self->_app_key, $self->_app_secret );
    my $res = WebService::Reddit::Response->new(
        raw => $self->ua->post(
            'https://www.reddit.com/api/v1/access_token',
            {
                grant_type    => 'refresh_token',
                refresh_token => $self->_refresh_token
            }
        )
    );

    my $auth = $res->content;
    $self->_set_access_token( $auth->{access_token} );
    $self->ua->clear_credentials;

    return $res;
}

1;
