package WebService::Reddit;

use Moo;
use MooX::StrictConstructor;

use Types::Standard qw( Bool InstanceOf Int Str );
use Types::URI -all;
use URI                          ();
use WWW::Mechanize               ();
use WebService::Reddit::Response ();

has access_token => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    writer   => '_set_access_token',
);

has access_token_expiration => (
    is        => 'ro',
    isa       => Int,
    predicate => 'has_access_token_expiration',
    writer    => '_set_access_token_expiration',
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

has _base_uri => (
    is       => 'ro',
    isa      => Uri,
    init_arg => 'base_uri',
    lazy     => 1,
    coerce   => 1,
    default  => 'https://oauth.reddit.com',
);

has _refresh_token => (
    is       => 'ro',
    isa      => Str,
    init_arg => 'refresh_token',
    required => 1,
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
    my $self     = shift;
    my $relative = URI->new(shift);

    my $uri = $self->_base_uri->clone;
    $uri->path( $relative->path );
    $uri->path_query( $relative->path_query ) if $relative->path_query;

    my $res = WebService::Reddit::Response->new(
        raw => $self->ua->get( $uri, $self->_auth ) );
    if ( $res->code == 401 ) {
        $self->refresh_access_token;
        $res = WebService::Reddit::Response->new(
            raw => $self->ua->get( $uri, $self->_auth ) );
    }
    return $res;
}

sub _auth {
    my $self = shift;
    return ( Authorization => 'bearer ' . $self->access_token );
}

sub refresh_access_token {
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
    die 'Cannot refresh token: ' . $res->as_string unless $res->success;

    $self->_set_access_token( $auth->{access_token} );
    $self->_set_access_token_expiration( time + $auth->{expires_in} );
    $self->ua->clear_credentials;

    return 1;
}

1;

# ABSTRACT: Thin wrapper around the Reddit OAuth API

=pod

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WebService::Reddit ();

    my $client = WebService::Reddit->new(
        access_token  => 'secret-access-token',
        app_key       => 'my-app-id',
        app_secret    => 'my-app-secret',
        refresh_token => 'secret-refresh-token',
    );

    my $me = $client->get('/api/v1/me');

    # Dump HashRef of response
    use Data::Printer;
    p( $me->content );


=head1 DESCRIPTION

beta beta beta.  Interface is subject to change.

This is a very thin wrapper around the Reddit OAuth API.

=head1 CONSTRUCTOR AND STARTUP

=head2 new

=over 4

=item * C<< access_token >>

A (once) valid OAuth access token.  It's ok if it has expired.

=item * C<< app_key >>

The key which Reddit has assigned to your app.

=item * C<< app_secret >>

The secret which Reddit has assigned to your app.

=item * C<< refresh_token >>

A valid C<refresh_token> which the Reddit API has provided.

=item * C<< ua >>

Optional.  A useragent of the L<LWP::UserAgent> family.

=item * C<< base_uri >>

Optional.  Provide only if you want to route your requests somewhere other than
the Reddit OAuth endpoint.

=back

=head2 get

Returns a L<WebService::Reddit::Response> object.  Accepts an URL, which may or
may not include GET params.  You can provide a relative URL.  If you provide an
absolute URL, your scheme and host will get clobbered with the default C<host>
and C<scheme> values, which can also be set via the constructor.

=head2 access_token

Returns the current C<access_token>.  This may not be the token which you
originally supplied.  If your supplied token has been expired then this module
will try to get you a fresh C<access_token>.

=head2 access_token_expiration

Returns expiration time of access token in epoch seconds, if available.  Check the predicate before calling this method in order to avoid a possible exception.

    print $client->access_token_expiration
        if $client->has_access_token_expiration .

=head2 has_access_token_expiration

Predicate.  Returns true if C<access_token_expiration> has been set.

=head2 refresh_access_token

Tries to refresh the C<access_token>.  Returns true on success and dies on
failure.  Use the C<access_token> method to get the new token if this method
has returned C<true>.

=head2 ua

Returns the UserAgent which is being used to make requests.  Defaults to a
L<WWW::Mechanize> object.

=cut
