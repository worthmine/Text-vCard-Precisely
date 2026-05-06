package Text::vCard::Precisely::V4::Node::Related;

use Carp;
use URI;

use Moo;
use Type::Utils qw(declare coerce from via as where message);
use Types::Standard qw(Str ArrayRef);

extends 'Text::vCard::Precisely::V4::Node';

has name => ( is => 'ro', default => 'RELATED', isa => Str );

my $RelatedType = declare 'RelatedType', as Str, where {
    m/^(?:contact|acquaintance|friend|met|co-worker|colleague|co-resident|neighbor|child|parent|sibling|spouse|kin|muse|crush|date|sweetheart|me|agent|emergency)$/is;

    # it needs tests
}, message {"The text you provided, $_, was not supported in 'RelatedType'"};

my $RelatedTypes = declare 'RelatedTypes', as ArrayRef[$RelatedType];
coerce $RelatedTypes, from $RelatedType, via { [$_] };
has types =>
    ( is => 'rw', isa => $RelatedTypes, default => sub { [] }, required => 1, coerce => 1 );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->pid();
    push @lines, 'TYPE="' . join( ',', map {uc} @{ $self->types() } ) . '"'
        if ref $self->types() eq 'ARRAY' and $self->types()->[0];
    push @lines, "MEDIATYPE=" . $self->media_type() if defined $self->media_type();

    my $string = join( ';', @lines ) . ':' . $self->content();
    return $self->fold( $string, -force => 1 );
}

no Moo;

1;
