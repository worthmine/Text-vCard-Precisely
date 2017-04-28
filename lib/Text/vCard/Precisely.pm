# ABSTRACT: turns baubles into trinkets
package Text::vCard::Precisely;
$VERSION = 0.01;

use 5.12.5;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3';

enum 'Version' => [qw( 3.0 4.0 )];
has version => ( is => 'ro', isa => 'Version', default => '3.0', required => 1 );

__PACKAGE__->meta->make_immutable;
no Moose;

sub BUILD {
    my $self = shift;
    return Text::vCard::Precisely::V3->new(@_) unless $self->version eq '4.0';

    require Text::vCard::Precisely::V4;
    return Text::vCard::Precisely::V4->new(@_);
}

1;
