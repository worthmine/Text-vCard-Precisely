package Text::vCard::Precisely::V3::Node::Phone;
$VERSION = 0.01;

use Carp;

use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'TEL', isa => 'Str' );

subtype 'Phone'
    => as 'Str'
    => where { m/^(:?tel:)?(:?[+]?\d{1,2}|\d*)[\(\s\-]?\d{1,3}[\)\s\-]?[\s]?\d{1,3}[\s\-]?\d{3,4}$/s }
    => message { "The Number you provided, $_, was not supported in Phone" };
has value => (is => 'ro', default => '', isa => 'Phone' );

subtype 'PhoneType'
    => as 'Str'
    => where {
        m/^(:?work|home)$/is or #common
        m/^(:?text|voice|fax|cell|video|pager|textphone)$/is # for tel
    }
    => message { "The text you provided, $_, was not supported in 'PhoneType'" };
has types => ( is => 'rw', isa => 'ArrayRef[Maybe[PhoneType]]');

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'TYPE=' . join( ',', map { uc $_ } @{ $self->types } ) if @{ $self->types || [] } > 0;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;

    ( my $value = $self->value ) =~ s/[-+()\s]+/ /sg;
    $value =~ s/^ //s;
    my $string = join(';', @lines ) . ':' . $value;
    return $self->fold( $string, -force => 1 );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
