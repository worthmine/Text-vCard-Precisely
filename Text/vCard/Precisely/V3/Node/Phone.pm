package Text::vCard::Precisely::V3::Node::Phone;
use Carp;

use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'TEL', isa => 'Str' );

subtype 'Phone'
    => as 'Str'
    => where { m/^\d+(:?[ \-]*\d*[ \-]*\d*)$/so }
    => message { "The Phone you provided, $_, was not supported" };
coerce 'Phone'
    => from 'Str'
    => via { $_ =~ s/[-+\s]+/ /go };
has value => (is => 'ro', default => '', isa => 'Phone', coerce => 1 );

subtype 'PhoneType'
    => as 'Str'
    => where {
        m/^(:?work|home)$/so or #common
        m/^(:?text|voice|fax|cell|video|pager|textphone)$/so # for tel
    }
    => message { "The text you provided, $_, was not supported in 'Type'" };
has types => ( is => 'rw', isa => 'ArrayRef[PhoneType] | Undef');

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'TYPE="' . join( ',', @{ $self->types } ). '"' if @{ $self->types || [] } > 0;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;

    return join(';', @lines ) . ':' . $self->value;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
