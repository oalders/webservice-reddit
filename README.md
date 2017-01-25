# NAME

WebService::Reddit - Thin wrapper around the Reddit OAuth API

[![Build Status](https://travis-ci.org/oalders/webservice-reddit.png?branch=master)](https://travis-ci.org/oalders/webservice-reddit)

# VERSION

version 0.000001

# SYNOPSIS

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

# DESCRIPTION

beta beta beta.  Interface is subject to change.

This is a very thin wrapper around the Reddit OAuth API.

# CONSTRUCTOR AND STARTUP

## new

- `access_token`

    A (once) valid OAuth access token.  It's ok if it has expired.

- `app_key`

    The key which Reddit has assigned to your app.

- `app_secret`

    The secret which Reddit has assigned to your app.

- `refresh_token`

    A valid `refresh_token` which the Reddit API has provided.

- `ua`

    Optional.  A useragent of the [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) family.

- `base_uri`

    Optional.  Provide only if you want to route your requests somewhere other than
    the Reddit OAuth endpoint.

## get

Returns a [WebService::Reddit::Response](https://metacpan.org/pod/WebService::Reddit::Response) object.  Accepts an URL, which may or
may not include GET params.  You can provide a relative URL.  If you provide an
absolute URL, your scheme and host will get clobbered with the default `host`
and `scheme` values, which can also be set via the constructor.

## access\_token

Returns the current `access_token`.  This may not be the token which you
originally supplied.  If your supplied token has been expired then this module
will try to get you a fresh `access_token`.

## refresh\_access\_token

Tries to refresh the `access_token`.  Returns true on success and dies on
failure.  Use the `access_token` method to get the new token if this method
has returned `true`.

## ua

Returns the UserAgent which is being used to make requests.  Defaults to a
[WWW::Mechanize](https://metacpan.org/pod/WWW::Mechanize) object.

# AUTHOR

Olaf Alders <olaf@wundercounter.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Olaf Alders.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
