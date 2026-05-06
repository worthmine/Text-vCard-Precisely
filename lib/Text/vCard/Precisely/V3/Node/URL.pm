package Text::vCard::Precisely::V3::Node::URL;

use Carp;
use URI;

use Moo;
use Type::Utils qw(declare coerce from via as);
use Types::Standard qw(Str);

extends 'Text::vCard::Precisely::V3::Node';

has name  => ( is => 'ro', default => 'URL', isa => Str );
has types => ( is => 'rw', isa => $Text::vCard::Precisely::V3::Node::Types,
    coerce => 1 );

my $URL_content = declare 'URL_content', as Str;
coerce $URL_content, from Str, via { URI->new($_)->as_string() };
has content => ( is => 'ro', default => '', isa => $URL_content, coerce => 1 );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->can('altID') and $self->altID();
    push @lines, 'PID=' . join ',',  @{ $self->pid() } if $self->can('pid') and $self->pid();
    push @lines, 'TYPE=' . join ',', map {uc} @{ $self->types() }
        if ref $self->types() eq 'ARRAY' and $self->types->[0];

    my $string = join( ';', @lines ) . ':' . $self->content();
    return $self->fold( $string, -force => 1 );
}

no Moo;

1;
