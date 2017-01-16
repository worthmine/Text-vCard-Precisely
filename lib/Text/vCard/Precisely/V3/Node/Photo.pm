package Text::vCard::Precisely::V3::Node::Photo;
use Carp;
use MIME::Base64;

use Moose;
use Moose::Util::TypeConstraints;
use Data::Validate::URI qw(is_web_uri);
extends 'Text::vCard::Precisely::V3::Node';

has name => ( is => 'ro', default => 'PHOTO', isa => 'Str' );

subtype 'Photo'
    => as 'Str'
    => where { is_web_uri($_) or
        s/\s//g || 1 and    #force remove spaces and returns
        m!^([A-Za-z0-9+/]{4})*(:?[A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$!
    }
    => message { "The Unvalid value you provided, $_, was not supported in 'value'" };
coerce 'Photo'
    => from 'Str'
    => via { is_web_uri($_) && return $_->as_string or encode_base64( $_, "" ) };
has value => (is => 'ro', default => '', isa => 'Photo', coerce => 1 );

subtype 'Media_type'
    => as 'Str'
    => where { m|^image/(:?X-)?[a-zA-z0-9\-]+$|s }
    => message { "The Text you provided, $_, was not supported in 'Media_type'" };
has media_type => ( is => 'rw', isa => 'Media_type' );#, default => 'image/gif' );
override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, "MEDIATYPE=" . $self->media_type if defined $self->media_type;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;
    push @lines, "ENCODING=b" unless is_web_uri( $self->value );

    return join(';', @lines ) . ':' . $self->value;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
