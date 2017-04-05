package Text::vCard::Precisely::V3::Node::Address;

use Carp;
use Moose;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'ADR', isa => 'Str' );
has value => (is => 'ro', default => '', isa => 'Str' );

my @order = qw( pobox extended street city region post_code country );
has \@order => ( is => 'rw', isa => 'Str' );

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'TYPE=' . join( ',', map { uc $_ } @{ $self->types } ) if @{ $self->types || [] } > 0;
    push @lines, 'PREF=' . $self->pref if $self->pref;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
    push @lines, 'CHARSET=' . $self->charset if $self->charset;

    my @values = ();
    map{ push @values, $self->_escape( $self->$_ ) } @order;
    my $string = join(';', @lines ) . ':' . join ';', @values;
    return $self->fold($string);

};

__PACKAGE__->meta->make_immutable;
no Moose;
    
1;
