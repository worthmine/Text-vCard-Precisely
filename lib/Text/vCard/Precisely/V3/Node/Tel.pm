package Text::vCard::Precisely::V3::Node::Tel;

use Carp;

use Moo;
use Type::Utils qw(declare as where message);
use Types::Standard qw(Str Bool ArrayRef Maybe);

extends 'Text::vCard::Precisely::V3::Node';

has name      => ( is => 'ro', default => 'TEL', isa => Str );
has content   => ( is => 'rw', default => '',    isa => Str );
has preferred => ( is => 'rw', default => 0,     isa => Bool );

my $TelType = declare 'TelType', as Str, where {
    m/^(?:work|home|pref)$/is ||                                #common
        m/^(?:text|voice|fax|cell|video|pager|textphone)$/is    # for tel
}, message {"The text you provided, $_, was not supported in 'TelType'"};
has types => ( is => 'rw', isa => ArrayRef[Maybe[$TelType]], default => sub { [] } );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->can('altID') and $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->can('pid') and $self->pid();

    my @types = map {uc} grep {length} @{ $self->types() };
    push @types, 'PREF' if $self->preferred();
    my $types = 'TYPE="' . join( ',', @types ) . '"' if @types;
    push @lines, $types if $types;

    my $string = join( ';', @lines ) . ':' . $self->content();
    return $self->fold( $string, -force => 1 );
}

no Moo;

1;
