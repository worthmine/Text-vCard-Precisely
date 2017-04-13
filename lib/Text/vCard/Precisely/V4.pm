# ABSTRACT: turns baubles into trinkets
package Text::vCard::Precisely::V4;
$VERSION = 0.01;

use 5.12.5;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw(TimeZone);

extends 'Text::vCard::Precisely::V3';

use Carp;
use Encode;

use Text::vCard::Precisely::V4::Node;
use Text::vCard::Precisely::V4::Node::Phone;
use Text::vCard::Precisely::V4::Node::Related;

has version => ( is => 'rw', isa => 'Str', default => '4.0' );

subtype 'v4Tel' => as 'ArrayRef[Text::vCard::Precisely::V4::Node::Phone]';
coerce 'v4Tel'
    => from 'Str'
    => via { [ Text::vCard::Precisely::V4::Node::Phone->new({ value => $_ }) ] };
coerce 'v4Tel'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V4::Node::Phone->new($_) ] };
coerce 'v4Tel'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V4::Node::Phone->new($_) } @$_ ] };
has tel => ( is => 'rw', isa => 'v4Tel', coerce => 1 );

has [qw|source sound url fburl caladruri caluri|]
    => ( is => 'rw', isa => 'URLs', coerce => 1 );

subtype 'Related' => as 'ArrayRef[Text::vCard::Precisely::V4::Node::Related]';
coerce 'Related'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V4::Node::Related->new($_) ] };
    coerce 'Related'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V4::Node::Related->new($_) } @$_ ] };
has related => ( is => 'rw', isa => 'Related', coerce => 1 );

subtype 'v4Node' => as 'ArrayRef[Text::vCard::Precisely::V4::Node]';
coerce 'v4Node'
    => from 'Str'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V4::Node->new( { name => $name, value => $_ } ) ]
    };
coerce 'v4Node'
    => from 'HashRef'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V4::Node->new({
            name => $_->{'name'} || $name,
            types => $_->{'types'} || [],
            value => $_->{'value'} || croak "No value in HashRef!",
        }) ]
    };
coerce 'v4Node'
    => from 'ArrayRef[HashRef]'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ map { Text::vCard::Precisely::V4::Node->new({
            name => $_->{'name'} || $name,
            types => $_->{'types'} || [],
            value => $_->{'value'} || croak "No value in HashRef!",
        }) } @$_ ]
    };
has [qw|fn nickname org impp lang title role categories note xml key geo label|]
    => ( is => 'rw', isa => 'v4Node', coerce => 1 );

subtype 'KIND'
    => as 'Str'
    => where { m/^(:?individual|group|org|location|[a-z0-9\-]+|X-[a-z0-9\-]+)$/s }
    => message { "The KIND you provided, $_, was not supported" };
has kind => ( is => 'rw', isa => 'KIND' );

subtype 'v4TimeStamp'
    => as 'Str'
    => where { m/^\d{8}T\d{6}(:?Z(:?-\d{2}(:?\d{2})?)?)?$/is  }
    => message { "The TimeStamp you provided, $_, was not correct" };
coerce 'v4TimeStamp'
    => from 'Str'
    => via { m/^(\d{4})-?(\d{2})-?(\d{2})(:?T(\d{2}):?(\d{2}):?(\d{2})Z)?$/is;
    return sprintf '%4d%02d%02dT%02d%02d%02dZ', $1, $2, $3, $4, $5, $6
};
coerce 'v4TimeStamp'
    => from 'Int'
    => via {
        my ( $s, $m, $h, $d, $M, $y ) = gmtime($_);
        return sprintf '%4d%02d%02dT%02d%02d%02dZ', $y + 1900, $M + 1, $d, $h, $m, $s
    };
coerce 'v4TimeStamp'
    => from 'ArrayRef[HashRef]'
    => via { $_->[0]{value} };
has rev => ( is => 'rw', isa => 'v4TimeStamp', coerce => 1  );

subtype 'MEMBER'
    => as 'ArrayRef[UID]';
coerce 'MEMBER'
    => from 'UID'
    => via { [$_] };
has member => ( is => 'rw', isa => 'MEMBER', coerce => 1 );

subtype 'CLIENTPIDMAP'
    => as 'Str'
    => where { m/^\d+;urn:uuid:[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}$/is }
    => message { "The CLIENTPIDMAP you provided, $_, was not correct" };
subtype 'CLIENTPIDMAPs'
    => as 'ArrayRef[CLIENTPIDMAP]';
coerce 'CLIENTPIDMAPs'
    => from 'Str'
    => via { [$_] };
has clientpidmap => ( is => 'rw', isa => 'CLIENTPIDMAPs', coerce => 1 );

has [qw|bday anniversary gender prodid|] => ( is => 'rw', isa => 'Str' );

__PACKAGE__->meta->make_immutable;
no Moose;

my @nodes = qw(
    FN N NICKNAME
    ADR TEL EMAIL IMPP LANG GEO
    ORG TITLE ROLE CATEGORIES RELATED
    NOTE SOUND UID URL FBURL CALADRURI CALURI
    XML KEY SOCIALPROFILE PHOTO LOGO SOURCE
);

sub as_string {
    my ($self) = @_;
    my $cr = "\x0D\x0A";
    my $string = "BEGIN:VCARD" . $cr;
    $string .= 'VERSION:' . $self->version . $cr;
    $string .= 'PRODID:' . $self->prodid . $cr if $self->prodid;
    $string .= 'KIND:' . $self->kind . $cr if $self->kind;
    foreach my $node ( @nodes ) {
        my $method = $self->can( lc $node );
        croak "the Method you provided, $node is not supported." unless $method;
        if ( ref $self->$method eq 'ARRAY' ) {
            foreach my $item ( @{ $self->$method } ){
                if ( $item->isa('Text::vCard::Precisely::V3::Node') ){
                    $string .= $item->as_string;
                }elsif($item) {
                    $string .= uc($node) . ":" . $item;
                }
            }
        }elsif( $self->$method and $self->$method->isa('Text::vCard::Precisely::V3::Node') ) {
            $string .= $self->$method->as_string;
        }
    }

     $string .= 'SORT-STRING:' . $self->sort_string . $cr
    if $self->version ne '4.0' and $self->sort_string;
    $string .= 'BDAY:' . $self->bday . $cr if $self->bday;
    $string .= 'ANNIVERSARY:' . $self->anniversary . $cr if $self->anniversary;
    $string .= 'GENDER:' . $self->gender . $cr if $self->gender;
    $string .= 'UID:' . $self->uid . $cr if $self->uid;
    map { $string .= "MEMBER:$_" . $cr } @{ $self->member || [] } if $self->member;
    map { $string .= "CLIENTPIDMAP:$_" . $cr } @{ $self->clientpidmap || [] } if $self->clientpidmap;
    map { $string .= "TZ:" . $_->name . $cr } @{ $self->tz || [] } if $self->tz;
    $string .= 'REV:' . $self->rev . $cr if $self->rev;
    $string .= "END:VCARD";

    my $lf = Text::LineFold->new(   # line break with 75bytes
        CharMax => 74,
        Charset => $self->encoding_in,
        OutputCharset => $self->encoding_out,
        Newline => $cr,
    );
    $string = $lf->fold( "", "  ", $string );
    return decode( $self->encoding_out, $string ) unless $self->encoding_out eq 'none';
    return $string;
}

1;
