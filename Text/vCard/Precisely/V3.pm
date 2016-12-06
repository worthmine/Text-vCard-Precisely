package Text::vCard::Precisely::V3;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw(TimeZone);

use Carp;
use Data::UUID;
use Encode;
use Text::LineFold;

use Text::vCard::Precisely::V3::Node;
use Text::vCard::Precisely::V3::Node::Address;
use Text::vCard::Precisely::V3::Node::Phone;
use Text::vCard::Precisely::V3::Node::Email;
use Text::vCard::Precisely::V3::Node::Photo;
use Text::vCard::Precisely::V3::Node::URL;
use Text::vCard::Precisely::V3::Node::SocialProfile;

has encoding_in  => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has encoding_out => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has version => ( is => 'ro', isa => 'Str', default => '3.0' );

has kind => ( is => 'rw', isa => subtype 'KIND'
    => as 'Str'
    => where { m/^(:?individual|group|org|location|[a-zA-z0-9\-]+|X-[a-zA-z0-9\-]+)$/s}
    => message { "The KIND you provided, $_, was not supported" }
);

subtype 'Address' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Address]';
coerce 'Address'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Address->new(%$_) ] };
coerce 'Address'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Address->new(%$_) } @$_ ] };
has adr => ( is => 'rw', isa => 'Address', coerce => 1 );

subtype 'Tel' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Phone]';
coerce 'Tel'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Phone->new(%$_) ] };
coerce 'Tel'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Phone->new(%$_) } @$_ ] };
has tel => ( is => 'rw', isa => 'Tel', coerce => 1 );

subtype 'Email' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Email]';
coerce 'Email'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Email->new(%$_) ] };
coerce 'Email'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Email->new(%$_) } @$_ ] };
has email => ( is => 'rw', isa => 'Email', coerce => 1 );

subtype 'Timestamp'
    => as 'Str'
    => where { m/^\d{8}T\d{6}(:?z|-\d{2}\d{2})?$/s  }
    => message { "The TimeStamp you provided, $_, was not correct" };
has rev => ( is => 'rw', isa => 'Timestamp' );

has [qw| uid clientpidmap |] => ( is => 'rw', isa => 'ArrayRef[Data::UUID]' );
has tz =>  ( is => 'rw', isa => 'ArrayRef[TimeZone] | ArrayRef[URI]' );
# utc-offset format is NOT RECOMMENDED in vCard 4.0

has [qw|fn bday anniversary gender prodid sort_string|] => ( is => 'rw', isa => 'Str' );

subtype 'N'
    => as 'ArrayRef[Str]'
    => where { @$_ == 4 }
    => message { 'Unvalid length. the length of N must be 4. you provided: ' . scalar @$_ };
has n => ( is => 'rw', isa => 'N' );

has related => ( is => 'rw', isa => 'ArrayRef[Str] | ArrayRef[URI]' );

subtype 'Node' => as 'ArrayRef[Text::vCard::Precisely::V3::Node]';
coerce 'Node'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node->new(%$_) ] };
coerce 'Node'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node->new(%$_) } @$_ ] };
has [qw|nickname org impp lang title role categories note xml key geo|]
    => ( is => 'rw', isa => 'Node', coerce => 1 );

subtype 'URLs' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::URL]';
coerce 'URLs'
    => from 'HashRef'
    => via  { [ Text::vCard::Precisely::V3::Node::URL->new($_) ] };
coerce 'URLs'
    => from 'ArrayRef[HashRef]'
    => via  { [ map{ Text::vCard::Precisely::V3::Node::URL->new($_) } @$_ ] };
has [qw|source sound url fburl caladruri caluri x-socialprofile|]
    => ( is => 'rw', isa => 'URLs', coerce => 1 );

subtype 'Image' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Photo]';
coerce 'Image'
    => from 'HashRef'
    => via  { [ Text::vCard::Precisely::V3::Node::Photo->new(%$_) ] };
coerce 'Image'
    => from 'ArrayRef[HashRef]'
    => via  { [ map{ Text::vCard::Precisely::V3::Node::Photo->new(%$_) } @$_ ] };
has [qw| photo logo |] => ( is => 'rw', isa => 'Image', coerce => 1 );

subtype 'SocialProfile' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::SocialProfile]';
coerce 'SocialProfile'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::SocialProfile->new(%$_) ] };
coerce 'SocialProfile'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::SocialProfile->new(%$_) } @$_ ] };
has socialprofile => ( is => 'rw', isa => 'SocialProfile', coerce => 1 );

with 'vCard::Role::FileIO';

__PACKAGE__->meta->make_immutable;
no Moose;

sub _data {
    my ( $self, $data ) = @_;
    return unless defined $data;
    croak '$data must be HASHREF' unless ref $data eq 'HASH';
    while ( my ( $key, $value ) = each %$data ) {
        $key = lc($key);
        $self->$key($value) if defined $value and $self->can($key);
    }
}

sub load_hashref {
    my ( $self, $hashref ) = @_;
    $self->_data($hashref);
    $self->_data('version' => $self->version ) unless $self->version;
     $self->_data('photo' => URI->new( $self->_data->{photo} ) )
    if $self->_data->{photo}->isa('URI');# ?

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

    $self->_data($vcard->_data);

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

    $self->_data($vcard->_data);

    return $self;
}

my @nodes = qw(
    NICKNAME BDAY ADR TEL EMAIL IMPP TZ GEO ORG TITLE ROLE CATEGORIES
    NOTE SOUND UID URL KEY SOCIALPROFILE PHOTO LOGO SOURCE
);

sub as_string {
    my ($self) = @_;
    my $string = "BEGIN:VCARD\n";
    $string .= 'VERSION:' . $self->version . "\n";
    $string .= 'PRODID:' . $self->prodid . "\n" if $self->prodid;
     $string .= 'SORT-STRING:' . $self->sort_string . "\n"
    if $self->version ne '4.0' and $self->sort_string;
    $string .= 'N:' . join( ';', map{ _escape($_) } @{ $self->n } ) . "\n";
    $string .= 'FN:' . _escape($self->fn) . "\n" if $self->fn;

    foreach my $node ( @nodes ) {
        my $method = $self->can( lc $node );
        croak "the Method you provided, $node is not supported." unless $method;
        if ( ref $self->$method eq 'ARRAY') {
            foreach my $item ( @{ $self->$method } ){
                if ( $item->isa('Text::vCard::Precisely::V3::Node') ){
                    $string .= $item->as_string . "\n";
                }else{
                    $string .= uc($node) . ":$item\n";
                }
            }
        }else{
             $string .= $self->$method->as_string . "\n"
            if $self->$method and $self->$method->isa('Text::vCard::Precisely::V3::Node');
        }
    }
    my ( $s, $m, $h, $d, $M, $y ) = gmtime();
     $self->rev( sprintf '%4d%02d%02dT%02d%02d%02dz', $y + 1900, $M + 1, $d, $h, $m, $s )
    unless $self->rev;

    $string .= 'REV:' . $self->rev . "\n";
    $string .= "END:VCARD";

    my $lf = Text::LineFold->new( ColMax => 75 );   # 75バイトで改行する処理
    $string = $lf->fold( '', " ", $string );
    ( my $vcf = $string ) =~ s/^\n//mg; # なぜか空行ができるので排除する
    return $vcf;
}

sub as_file {
    my ( $self, $filename ) = @_;
    my $file = $self->_path($filename);
    $file->spew( $self->_iomode_out, $self->as_string );
    return $file;
}

sub _escape {
    my $txt = shift;
    ( my $r = $txt ) =~ s/([,;\\])/\\$1/sg;
    return $r;
}

1;
