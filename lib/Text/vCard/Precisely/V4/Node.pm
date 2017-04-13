package Text::vCard::Precisely::V4::Node;

use Carp;
use Encode;

use overload (
    q{""}	=> \&as_string,
);

use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

enum 'Name' => [qw( FN
    ADR LABEL TEL EMAIL PHOTO LOGO URL
    TZ GEO NICKNAME IMPP LANG XML KEY NOTE
    ORG TITLE ROLE CATEGORIES
    SOURCE SOUND FBURL CALADRURI CALURI
    RELATED X-SOCIALPROFILE SORT_STRING
)];
has name => ( is => 'rw', required => 1, isa => 'Name' );

has sort_as => ( is => 'rw', isa => subtype 'SortAs' # from vCard 4.0
    => as 'Str'
    => where { use utf8; decode_utf8($_) =~  m|^[\w\s\W]+$|s }   # does everything pass?
    => message { "The SortAs you provided, $_, was not supported" }
);

sub as_string {
    my ($self) = @_;
    my @lines;
    push @lines, uc( $self->name ) || croak "Empty name";
    push @lines, 'TYPE=' . join( ',', map { uc $_ } @{ $self->types } ) if @{ $self->types || [] } > 0;
    push @lines, 'PREF=' . $self->pref if $self->pref;
    push @lines, 'MEDIATYPE=' . $self->media_type if $self->media_type;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;
    push @lines, 'CHARSET=' . $self->charset if $self->charset;
    push @lines, 'SORT-AS=' . $self->sort_as if $self->sort_as and $self->name eq 'ORG';

    my $string = join(';', @lines ) . ':' . (
        ref $self->value eq 'Array'?
            map{ $self->name =~ /^(:?LABEL|GEO)$/s? $self->value : $self->_escape($_) } @{ $self->value }:
            $self->name =~ /^(:?LABEL|GEO)$/s? $self->value: $self->_escape( $self->value )
    );
    return $self->fold($string);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
