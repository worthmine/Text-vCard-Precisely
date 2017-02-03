# ABSTRACT: turns baubles into trinkets
package Text::vCard::Precisely::V3;
$VERSION = 0.01;

use 5.10.1;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw(TimeZone);

use Carp;
use Data::UUID;
use Encode;
use Text::LineFold;
use URI;

use Text::vCard::Precisely::V3::Node;
use Text::vCard::Precisely::V3::Node::N;
use Text::vCard::Precisely::V3::Node::Address;
use Text::vCard::Precisely::V3::Node::Phone;
use Text::vCard::Precisely::V3::Node::Email;
use Text::vCard::Precisely::V3::Node::Photo;
use Text::vCard::Precisely::V3::Node::URL;
use Text::vCard::Precisely::V3::Node::SocialProfile;

has encoding_in  => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has encoding_out => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has version => ( is => 'rw', isa => 'Str', default => '3.0' );

subtype 'N'
    => as 'ArrayRef[Text::vCard::Precisely::V3::Node::N]'
    => where { ref $_ eq 'ARRAY' }
    => message { 'N must be a ArrayRef you provided:' . ref $_  };
coerce 'N'
    => from 'HashRef[Maybe[Ref]|Maybe[Str]]'
    => via {
        my %param;
        while( my ($key, $value) = each %$_ ) {
            $param{$key} = $value if $value;
        }
        return [ Text::vCard::Precisely::V3::Node::N->new(\%param) ];
    };
coerce 'N'
    => from 'ArrayRef[HashRef[Maybe[Str]]]'
    => via {[ map{ Text::vCard::Precisely::V3::Node::N->new({ value => $_ }) } @$_ ]};
coerce 'N'
    => from 'ArrayRef[ArrayRef[Maybe[Str]]]'
    => via { [ map{ Text::vCard::Precisely::V3::Node::N->new({ value => $_ }) } @$_ ]};
coerce 'N'
    => from 'ArrayRef[Maybe[Str]]'
    => via {[ Text::vCard::Precisely::V3::Node::N->new({ value => {
        family => $_[0][0] || '',
        given => $_[0][1] || '',
        additional => $_[0][2] || '',
        prefixes => $_[0][3] || '',
        suffixes => $_[0][4] || '',
    } }) ]};
coerce 'N'
    => from 'Str'
    => via {[ Text::vCard::Precisely::V3::Node::N->new({ value => $_ }) ]};
has n => ( is => 'rw', isa => 'N', coerce => 1 );

subtype 'Address' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Address]';
coerce 'Address'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Address->new($_) ] };
coerce 'Address'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Address->new($_) } @$_ ] };
has adr => ( is => 'rw', isa => 'Address', coerce => 1 );

subtype 'Tel' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Phone]';
coerce 'Tel'
    => from 'Str'
    => via { [ Text::vCard::Precisely::V3::Node::Phone->new({ value => $_ }) ] };
coerce 'Tel'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Phone->new($_) ] };
coerce 'Tel'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Phone->new($_) } @$_ ] };
has tel => ( is => 'rw', isa => 'Tel', coerce => 1 );

subtype 'Email' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Email]';
coerce 'Email'
    => from 'Str'
    => via { [ Text::vCard::Precisely::V3::Node::Email->new({ value => $_ }) ] };
coerce 'Email'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Email->new($_) ] };
coerce 'Email'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Email->new($_) } @$_ ] };
has email => ( is => 'rw', isa => 'Email', coerce => 1 );

subtype 'URLs' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::URL]';
coerce 'URLs'
    => from 'Str'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [Text::vCard::Precisely::V3::Node::URL->new({ name => $name, value => $_ })]
    };
coerce 'URLs'
    => from 'HashRef[Str]'
    => via  {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V3::Node::URL->new({
            name => $name,
            value => $_->{'value'}
        }) ]
    };
coerce 'URLs'
    => from 'Object'    # Can't asign 'URI' or 'Object[URI]'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [Text::vCard::Precisely::V3::Node::URL->new({
            name => $name,
            value => $_->as_string,
        })]
    };
coerce 'URLs'
    => from 'ArrayRef[HashRef]'
    => via  { [ map{ Text::vCard::Precisely::V3::Node::URL->new($_) } @$_ ] };
has [qw|source sound url fburl caladruri caluri|]
    => ( is => 'rw', isa => 'URLs', coerce => 1 );

subtype 'Image' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Photo]';
coerce 'Image'
    => from 'HashRef'
    => via  {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V3::Node::Photo->new({
            name => $name,
            media_type => $_->{'media_type'},
            value => $_->{'value'},
        }) ] };
coerce 'Image'
    => from 'ArrayRef[HashRef]'
    => via  { [ map{ Text::vCard::Precisely::V3::Node::Photo->new($_) } @$_ ] };
coerce 'Image'
    => from 'Object'   # when parse from vCard::Addressbook, URI->new is called.
    => via  { [ Text::vCard::Precisely::V3::Node::Photo->new( { value => $_->as_string } ) ] };
coerce 'Image'
    => from 'Str'   # when parse BASE64 encoded strings
    => via  {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V3::Node::Photo->new({
            name => $name,
            value => $_,
        } ) ]
    };
coerce 'Image'
    => from 'ArrayRef[Str]'   # when parse BASE64 encoded strings
    => via  {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ map{ Text::vCard::Precisely::V3::Node::Photo->new({
            name => $name,
            value => $_,
        }) } @$_ ]
    };
has [qw| photo logo |] => ( is => 'rw', isa => 'Image', coerce => 1 );

subtype 'SocialProfile' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::SocialProfile]';
coerce 'SocialProfile'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::SocialProfile->new($_) ] };
coerce 'SocialProfile'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::SocialProfile->new($_) } @$_ ] };
has socialprofile => ( is => 'rw', isa => 'SocialProfile', coerce => 1 );

subtype 'Node' => as 'ArrayRef[Text::vCard::Precisely::V3::Node]';
coerce 'Node'
    => from 'Str'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V3::Node->new( { name => $name, value => $_ } ) ]
    };
coerce 'Node'
    => from 'HashRef'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ Text::vCard::Precisely::V3::Node->new({
            name => $_->{'name'} || $name,
            types => $_->{'types'} || [],
            value => $_->{'value'} || croak "No value in HashRef!",
        }) ]
    };
coerce 'Node'
    => from 'ArrayRef[HashRef]'
    => via {
        my $name = uc [split( /::/, [caller(2)]->[3] )]->[-1];
        return [ map { Text::vCard::Precisely::V3::Node->new({
            name => $_->{'name'} || $name,
            types => $_->{'types'} || [],
            value => $_->{'value'} || croak "No value in HashRef!",
        }) } @$_ ]
    };
has [qw|fn nickname org impp lang title role categories note xml key geo label|]
    => ( is => 'rw', isa => 'Node', coerce => 1 );

subtype 'KIND'
    => as 'Str'
    => where { m/^(:?individual|group|org|location|[a-zA-z0-9\-]+|X-[a-zA-z0-9\-]+)$/s}
    => message { "The KIND you provided, $_, was not supported" };
has kind => ( is => 'rw', isa => 'KIND' );

subtype 'Timestamp'
    => as 'Str'
    => where { m/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z?$/is  }
    => message { "The TimeStamp you provided, $_, was not correct" };
has rev => ( is => 'rw', isa => 'Timestamp' );

has [qw| uid clientpidmap |] => ( is => 'rw', isa => 'ArrayRef[Data::UUID]' );
has tz =>  ( is => 'rw', isa => 'ArrayRef[TimeZone] | ArrayRef[URI]' );
# utc-offset format is NOT RECOMMENDED in vCard 4.0

has [qw|bday anniversary gender prodid sort_string|] => ( is => 'rw', isa => 'Str' );

has related => ( is => 'rw', isa => 'ArrayRef[Str] | ArrayRef[URI]' );


with 'vCard::Role::FileIO';

__PACKAGE__->meta->make_immutable;
no Moose;

sub load_hashref {
    my ( $self, $hashref ) = @_;
    while ( my ( $key, $value ) = each %$hashref ) {
        my $method = $self->can( lc $key );
        next unless $method and $value;
        if ( ref $value eq 'Hash' ) {
            $self->$method( { name => uc($key), %$value } );
        }else{
            $self->$method($value);
        }
    }
    return $self;
}

use vCard::AddressBook;
sub load_file {
    my ( $self, $filename ) = @_;

    my $addressBook = vCard::AddressBook->new({
        encoding_in  => $self->encoding_in,
        encoding_out => $self->encoding_out,
    });
    my $vcard = $addressBook->load_file($filename)->vcards->[0];
    $self->load_hashref($vcard->_data);

    return $self;
}

=head2 load_string($string)

 Returns $self in case you feel like chaining.  This method assumes $string is
 decoded (but not MIME decoded).
=cut

sub load_string {
    my ( $self, $string ) = @_;

    my $addressBook = vCard::AddressBook->new({
        encoding_in  => $self->encoding_in,
        encoding_out => $self->encoding_out,
    });

    my $vcard = $addressBook->load_string($string)->vcards->[0];
    my $data = $vcard->_data;
    $self->load_hashref($data);

    return $self;
}

my @nodes = qw(
    N FN NICKNAME BDAY ANNIVERSARY GENDER
    ADR LABEL TEL EMAIL IMPP LANG TZ GEO
    ORG TITLE ROLE CATEGORIES
    NOTE SOUND UID URL FBURL CALADRURI CALURI
    XML KEY SOCIALPROFILE PHOTO LOGO SOURCE
);

sub as_string {
    my ($self) = @_;
    my $string = "BEGIN:VCARD\r\n";
    $string .= 'VERSION:' . $self->version . "\r\n";
    $string .= 'PRODID:' . $self->prodid . "\r\n" if $self->prodid;
#     $string .= 'SORT-STRING:' . decode_utf8($self->sort_string) . "\r\n"
     $string .= 'SORT-STRING:' . $self->sort_string . "\r\n"
    if $self->version ne '4.0' and $self->sort_string;

    foreach my $node ( @nodes ) {
        my $method = $self->can( lc $node );
        croak "the Method you provided, $node is not supported." unless $method;
        if ( ref $self->$method eq 'ARRAY') {
            foreach my $item ( @{ $self->$method } ){
                if ( $item->isa('Text::vCard::Precisely::V3::Node') ){
                    $string .= $item->as_string . "\r\n";
                }elsif($item) {
                    $string .= uc($node) . ":$item\r\n";
                }
            }
        }elsif( $self->$method and $self->$method->isa('Text::vCard::Precisely::V3::Node') ) {
            $string .= $self->$method->as_string . "\r\n";
        }
    }
    unless ( $self->rev ) {
        my ( $s, $m, $h, $d, $M, $y ) = gmtime();
        $self->rev( sprintf '%4d-%02d-%02dT%02d:%02d:%02dZ', $y + 1900, $M + 1, $d, $h, $m, $s );
    }

    $string .= 'REV:' . $self->rev . "\r\n";
    $string .= "END:VCARD";
    $string = decode( $self->encoding_out, $string );
    my $lf = Text::LineFold->new( CharMax => 74, ColMin => 50, Newline => "\r\n" );   # line break with 75bytes
    return $lf->fold( "", " ", $string );
}

sub as_file {
    my ( $self, $filename ) = @_;
    my $file = $self->_path($filename);
    $file->spew( $self->_iomode_out, $self->as_string );
    return $file;
}

# Alias
sub fullname {
    my $self = shift;
    $self->fn(@_);
}

sub birthday {
    my $self = shift;
    $self->bday(@_);
}

sub timezone {
    my $self = shift;
    $self->tz(@_);
}

1;
