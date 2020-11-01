package Text::vCard::Precisely::V3::Node::MultiContent;

use Carp;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

enum 'Allows' => [qw|CATEGORIES NICKNAME|];
has name      => ( is => 'ro', required => 1, isa => 'Allows' );

subtype 'MultiContent' => as 'ArrayRef[Str]';
coerce 'MultiContent'  => from 'Str' => via { [$_] };
has content            => ( is => 'rw', required => 1, isa => 'MultiContent', coerce => 1 );

sub as_string {
    my ($self) = @_;
    return ( $self->name() || croak "Empty name" ) . ':' . join ',', @{ $self->content() };
}

__PACKAGE__->meta->make_immutable();
no Moose;

1;
