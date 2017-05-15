package Text::vCard::Precisely::V3::Node;

use Carp;
use Encode;
use Text::LineFold;

use Moose;
use Moose::Util::TypeConstraints;

enum 'Name' => [qw( FN
    ADR LABEL TEL EMAIL PHOTO LOGO URL
    TZ GEO NICKNAME KEY NOTE
    ORG TITLE ROLE CATEGORIES
    SOURCE SOUND
    X-SOCIALPROFILE
)];
has name => ( is => 'rw', required => 1, isa => 'Name' );

subtype 'VALUE'
    => as 'Str'
    => where { use utf8; decode_utf8($_) =~  m|^[\w\p{ascii}\s]*$|s }
    # Does it need to be more strictly?
    => message { "The VALUE you provided, $_, was not supported" };
has value => ( is => 'rw', required => 1, isa => 'VALUE' );

subtype 'Preffered'
    => as 'Int'
    => where { $_ > 0 and $_ <= 100 }
    => message { "The number you provided, $_, was not supported in 'Preffered'" };
has pref => ( is => 'rw', isa => 'Preffered' );

subtype 'Type'
    => as 'Str'
    => where {
        m/^(:?work|home|PGP)$/is or #common
        m|^(:?[a-zA-z0-9\-]+/X-[a-zA-z0-9\-]+)$|s; # does everything pass?
    }
    => message { "The text you provided, $_, was not supported in 'Type'" };
has types => ( is => 'rw', isa => 'ArrayRef[Type]', default => sub{[]} );

subtype 'Language'
    => as 'Str'
    => where { m|^[a-z]{2}(:?-[a-z]{2})?$|s }  # does it need something strictly?
    => message { "The Language you provided, $_, was not supported" };
has language => ( is => 'rw', isa =>'Language' );

subtype 'MediaType'
    => as 'Str'
    => where { m{^(:?application|audio|example|image|message|model|multipart|text|video)/[\w+\-\.]+$}is }
    => message { "The MediaType you provided, $_, was not supported" };
has media_type => ( is => 'rw', isa => 'MediaType' );

=cut

subtype 'Charset'
    => as 'Str'
    => where { m|^[\w-]+$|s }    # does everything pass?
    => message { "The Charset you provided, $_, was not supported" };
has charset => ( is => 'rw', isa => 'Charset' );
# NOT RECOMMENDED parameter. but Android 4.4.x requires when there are UTF-8 characters

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

sub as_string {
    my ($self) = @_;
    my @lines;
    push @lines, uc( $self->name ) || croak "Empty name";
    push @lines, 'TYPE=' . join( ',', map { uc $_ } @{ $self->types } ) if @{ $self->types || [] } > 0;
    push @lines, 'PREF=' . $self->pref if $self->pref;
    push @lines, 'MEDIATYPE=' . $self->media_type if $self->media_type;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
#    push @lines, 'CHARSET=' . $self->charset if $self->charset;

    my $string = join(';', @lines ) . ':' . (
        ref $self->value eq 'Array'?
        map{ $self->name =~ /^(:?LABEL|GEO)$/s? $self->value : $self->_escape($_) } @{ $self->value }:
        $self->name =~ /^(:?LABEL|GEO)$/s? $self->value: $self->_escape( $self->value )
    );
    return $self->fold($string);
}

sub fold {
    my $self = shift;
    my $string = shift;
    my %arg = @_;
    my $lf = Text::LineFold->new(   # line break with 75bytes
    CharMax => 74,
    Newline => "\x0D\x0A",
    );
    my $decoded = decode_utf8($string);
    return $decoded =~ /\P{ascii}+/ || $arg{-force}?
    $lf->fold( "", " ", $string ):
    $lf->fold( "", "  ", $string );
}

sub _escape {
    my $self = shift;
    my $txt = shift;
    ( my $r = $txt ) =~ s/([,;\\])/\\$1/sg if $txt;
    return $r || '';
}

1;
