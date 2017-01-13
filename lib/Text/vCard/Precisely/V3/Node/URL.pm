package Text::vCard::Precisely::V3::Node::URL;
use Carp;
use URI;

use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'URL', isa => 'Str' );
has types => ( is => 'rw', isa => 'ArrayRef[Str]');

subtype 'URL' => as 'Str';
coerce 'URL'
    => from 'Str'
    => via { [ URI->new($_)->as_string ] };
has value => (is => 'ro', default => '', isa => 'URL', coerce => 1 );

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'TYPE="' . join( ',', @{ $self->types } ) . '"' if @{ $self->types || [] } > 0;
    push @lines, "MEDIATYPE=" . $self->media_type if defined $self->media_type;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;

    return join(';', @lines ) . ':' . $self->value;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
