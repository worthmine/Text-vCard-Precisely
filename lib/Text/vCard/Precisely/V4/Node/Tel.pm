package Text::vCard::Precisely::V4::Node::Tel;

use Carp;

use Moose;
use Moose::Util::TypeConstraints;

extends qw|Text::vCard::Precisely::V3::Node::Tel Text::vCard::Precisely::V4::Node|;

has content => ( is => 'ro', default => '', isa => 'Str' );

override 'as_string' => sub {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'VALUE=uri';
    push @lines, 'ALTID=' . $self->altID() if $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->pid();
    push @lines, 'TYPE="' . join( ',', map {uc} grep {length} @{ $self->types() } ) . '"'
        if ref $self->types() eq 'ARRAY' and $self->types()->[0];

    my $colon  = ( $self->content() =~ /^tel:/ ) ? ':' : ':tel:';
    my $string = join( ';', @lines ) . $colon . $self->content();
    return $self->fold( $string, -force => 1 );
};

__PACKAGE__->meta->make_immutable();
no Moose;

1;
