package WebService::Reddit::Response;

use Moo;

use JSON::MaybeXS qw( decode_json );
use Types::Standard qw( Bool InstanceOf Maybe HashRef );

has content => (
    is      => 'ro',
    isa     => Maybe [HashRef],
    lazy    => 1,
    builder => '_build_content',
);

has raw => (
    is       => 'ro',
    isa      => InstanceOf ['HTTP::Response'],
    handles  => { as_string => 'as_string', code => 'code', },
    required => 1,
    clearer  => '_clear_raw',
    writer   => '_set_raw',
);

has success => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    clearer => '_clear_success',
    builder => '_build_success',
);

sub _build_content {
    my $self    = shift;
    my $content = $self->raw->decoded_content;

    return $content ? decode_json($content) : undef;
}

sub _build_success {
    my $self = shift;
    return $self->raw->is_success && !$self->raw->header('X-Died');
}

1;
