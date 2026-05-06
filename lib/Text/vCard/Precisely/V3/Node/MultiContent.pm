package Text::vCard::Precisely::V3::Node::MultiContent;

use Carp;
use Moo;
use Type::Utils qw(declare coerce enum from via as where);
use Types::Standard qw(Str ArrayRef);

extends 'Text::vCard::Precisely::V3::Node';

my $Allows = enum 'Allows', [qw|CATEGORIES NICKNAME|];
has name => ( is => 'ro', required => 1, isa => $Allows );

my $MultiContent = declare 'MultiContent', as ArrayRef[Str];
coerce $MultiContent, from Str, via { [$_] };
has content => ( is => 'rw', required => 1, isa => $MultiContent, coerce => 1 );

sub as_string {
    my ($self) = @_;
    return ( $self->name() || croak "Empty name" ) . ':' . join ',', @{ $self->content() };
}

no Moo;

1;
