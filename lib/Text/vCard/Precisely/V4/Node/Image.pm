package Text::vCard::Precisely::V4::Node::Image;

use Carp;
use Data::Validate::URI qw(is_web_uri);

use Moo;
use Types::Standard qw(Str);

extends qw(Text::vCard::Precisely::V3::Node::Image Text::vCard::Precisely::V4::Node);

has name       => ( is => 'rw', default => 'PHOTO', isa => Str, required => 1 );
has content    => ( is => 'rw', isa => $Text::vCard::Precisely::V3::Node::Image::Images,
    required => 1, coerce => 1 );
has media_type => ( is => 'rw',
    isa => $Text::vCard::Precisely::V3::Node::Image::Media_type );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->pid();
    push @lines, "MEDIATYPE=" . $self->media_type() if defined $self->media_type();
    push @lines, "ENCODING=b" unless is_web_uri( $self->content() );

    my $string = join( ';', @lines ) . ':' . $self->content();
    return $self->fold( $string, -force => 1 );
}

no Moo;

1;
