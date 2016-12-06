package Text::vCard::Precisely::V3::Node::Photo;
use Carp;
use MIME::Base64;

use Moose;
use Moose::Util::TypeConstraints;
use Data::Validate::URI qw(is_web_uri);
extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'PHOTO', isa => 'Str' );

subtype 'Photo'
    => as 'Str'
    => where { is_web_uri($_) or m|^[ a-zA-Z0-9+/]+[=]*$|m }
    => message { "The Unvalid value you provided, $_, was not supported in 'value'" };
coerce 'Photo'
    => from 'Str'
    => via { is_web_uri($_) && return $_ or encode_base64( $_, "\n " ) };
has value => (is => 'ro', default => '', isa => 'Photo', coerce => 1 );

subtype 'Media_type'
    => as 'Str'
    => where { m|^(:?[a-zA-z0-9\-]+/(:?X-)?[a-zA-z0-9\-]+)$|s }
    => message { "The Text you provided, $_, was not supported in 'Media_type'" };
has media_type => ( is => 'rw', isa => 'Media_type' );

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, "ENCODING=b" unless is_web_uri( $self->value );
    push @lines, "MEDIATYPE=" . $self->media_type if defined $self->media_type;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;

    return join(';', @lines ) . ':' . $self->value;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
