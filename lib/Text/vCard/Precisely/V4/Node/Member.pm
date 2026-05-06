package Text::vCard::Precisely::V4::Node::Member;

use Carp;
use Moo;
use Type::Utils qw(declare as where message);
use Types::Standard qw(Str ArrayRef);

extends 'Text::vCard::Precisely::V4::Node';

has name    => ( is => 'ro', default => 'MEMBER', isa => Str );
has content => ( is => 'ro', default => '',       isa => Str );

my $MemberType = declare 'MemberType', as Str, where {
    m/^(?:contact|acquaintance|friend|met|co-worker|colleague|co-resident|neighbor|child|parent|sibling|spouse|kin|muse|crush|date|sweetheart|me|agent|emergency)$/is;

    # it needs tests
}, message {"The text you provided, $_, was not supported in 'MemberType'"};
has types => ( is => 'rw', isa => ArrayRef[$MemberType], default => sub { [] } );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->pid();
    push @lines, 'TYPE="' . join( ',', map {uc} @{ $self->types() } ) . '"'
        if ref $self->types() eq 'ARRAY' and $self->types->[0];
    push @lines, 'PREF=' . $self->pref() if $self->pref();

    my $string = join( ';', @lines ) . ':' . $self->_escape( $self->content() );
    return $self->fold($string);
}

no Moo;

1;
