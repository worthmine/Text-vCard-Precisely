package Text::vCard::Precisely::V3::Node;
use Carp;
use Encode;

use overload (
    q{""}	=> \&as_string,
);

use Moose;
use Moose::Util::TypeConstraints;

enum 'Name' => [qw( VERSION PRODID N FN NICKNAME BDAY
    ADR TEL EMAIL IMPP TZ GEO ORG TITLE ROLE CATEGORIES
    NOTE REV SOUND UID URL KEY X-SOCIALPROFILE PHOTO LOGO SOURCE
)];
has name => ( is => 'rw', required => 1, isa => 'Name' );

subtype 'VALUE'
    => as 'Str'
    => where { use utf8; decode_utf8($_) =~  m|^[\w\W\s]*$|is }# 本来は厳密にチェックすべき
    => message { "The VALUE you provided, $_, was not supported" };
has value => ( is => 'rw', required => 1, isa => 'VALUE' );

has pref => ( is => 'rw', isa => subtype 'Preffered'
    => as 'Int'
    => where { $_ > 0 and $_ <= 100 }
    => message { "The number you provided, $_, was not supported in 'Preffered'" }
);

subtype 'Type'
    => as 'Str'
    => where {
        m/^(:?work|home)$/is or #common
        m/^(:?contact|acquaintance|friend|met|co-worker|colleague|co-resident|neighbor|child|parent|sibling|spouse|kin|muse|crush|date|sweetheart|me|agent|emergency)$/is or    # 本当にこれでいのか怪しい
        m|^(:?[a-zA-z0-9\-]+/X-[a-zA-z0-9\-]+)$|s; # 結局何でも通る恐れあり
    }
    => message { "The text you provided, $_, was not supported in 'Type'" };
has types => ( is => 'rw', isa => 'ArrayRef[Type]', default => sub{ [] } );

subtype 'PIDNum'
    => as 'Num'
    => where { m/^\d(:?.\d)?$/s }
    => message { "The PID you provided, $_, was not supported" };
has pid => ( is => 'rw', isa => subtype 'PID' => as 'ArrayRef[PIDNum]' );

has altID => ( is => 'rw', isa => subtype 'ALTID'
    => as 'Int'
    => where { $_ > 0 and $_ <= 100 }
    => message { "The number you provided, $_, was not supported in 'ALTID'" }
);


has language => ( is => 'rw', isa => subtype 'Language'
    => as 'Str'
    => where { m|^[a-z]{2}(:?-[a-z]{2})?$|s }  # 厳密な照会が必要？
    => message { "The Language you provided, $_, was not supported" }
);

has media_type => ( is => 'rw', isa => subtype 'MediaType'
    => as 'Str'
    => where { m{^(:?application|audio|example|image|message|model|multipart|text|video)/[\w+\-\.]+$}s }
    => message { "The MediaType you provided, $_, was not supported" }
);

has sort_as => ( is => 'rw', isa => subtype 'SortAs' # from vCard 4.0
    => as 'Str'
    => where { use utf8; decode_utf8($_) =~  m|^[\w\s\W]*$|s }# 本来は厳密にチェックすべき
    => message { "The SortAs you provided, $_, was not supported" }
);

__PACKAGE__->meta->make_immutable;
no Moose;

sub as_string {
    my ($self) = @_;
    my @lines;
    push @lines, uc( $self->name ) || croak "Empty name";
    push @lines, 'TYPE=' . join( ',', @{ $self->types } ) if @{ $self->types || [] } > 0;
    push @lines, 'PREF=' . $self->pref if $self->pref;
    push @lines, 'MEDIATYPE=' . $self->media_type if $self->media_type;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;
    push @lines, 'SORT-AS="' . $self->sort_as . '"' if $self->sort_as and $self->name =~ /^(:?N|ORG)$/is;

    return join(';', @lines ) . ':' . ( ref $self->value eq 'Array'?
        map{ Text::vCard::Precisely::V3::_escape($_) } @{ $self->value }:
        Text::vCard::Precisely::V3::_escape($self->value)
    );
}

1;
