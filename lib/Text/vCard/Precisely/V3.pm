# ABSTRACT: turns baubles into trinkets
package Text::vCard::Precisely::V3;
$VERSION = 0.02;

use 5.12.5;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw(TimeZone);

use Carp;
use Data::UUID;
use Encode;
use Text::LineFold;
use URI;
use Text::vFile::asData;
my $vf = Text::vFile::asData->new;

use Text::vCard::Precisely::V3::Node;
use Text::vCard::Precisely::V3::Node::N;
use Text::vCard::Precisely::V3::Node::Address;
use Text::vCard::Precisely::V3::Node::Phone;
use Text::vCard::Precisely::V3::Node::Email;
use Text::vCard::Precisely::V3::Node::Photo;
use Text::vCard::Precisely::V3::Node::URL;
use Text::vCard::Precisely::V3::Node::SocialProfile;
use Text::vCard::Precisely::V3::Node::Related;

has encoding_in  => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has encoding_out => ( is => 'rw', isa => 'Str', default => 'UTF-8', );
has version => ( is => 'rw', isa => 'Str', default => '3.0' );

subtype 'N'
    => as 'Text::vCard::Precisely::V3::Node::N';
coerce 'N'
    => from 'HashRef[Maybe[Ref]|Maybe[Str]]'
    => via {
        my %param;
        while( my ($key, $value) = each %$_ ) {
            $param{$key} = $value if $value;
        }
        return Text::vCard::Precisely::V3::Node::N->new(\%param);
    };
coerce 'N'
    => from 'HashRef[Maybe[Str]]'
    => via { Text::vCard::Precisely::V3::Node::N->new({ value => $_ }) };
coerce 'N'
    => from 'ArrayRef[Maybe[Str]]'
    => via { Text::vCard::Precisely::V3::Node::N->new({ value => {
        family      => $_->[0] || '',
        given       => $_->[1] || '',
        additional  => $_->[2] || '',
        prefixes    => $_->[3] || '',
        suffixes    => $_->[4] || '',
    } }) };
coerce 'N'
    => from 'Str'
    => via { Text::vCard::Precisely::V3::Node::N->new({ value => [split /(?<!\\);/, $_] }) };
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

subtype 'Related' => as 'ArrayRef[Text::vCard::Precisely::V3::Node::Related]';
coerce 'Related'
    => from 'HashRef'
    => via { [ Text::vCard::Precisely::V3::Node::Related->new($_) ] };
    coerce 'Related'
    => from 'ArrayRef[HashRef]'
    => via { [ map { Text::vCard::Precisely::V3::Node::Related->new($_) } @$_ ] };
has related => ( is => 'rw', isa => 'Related', coerce => 1 );

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
    => where { m/^(:?individual|group|org|location|[a-z0-9\-]+|X-[a-z0-9\-]+)$/s }
    => message { "The KIND you provided, $_, was not supported" };
has kind => ( is => 'rw', isa => 'KIND' );

subtype 'TimeStamp'
    => as 'Str'
    => where { m/^\d{4}-?\d{2}-?\d{2}(:?T\d{2}:?\d{2}:?\d{2}Z)?$/is  }
    => message { "The TimeStamp you provided, $_, was not correct" };
coerce 'TimeStamp'
    => from 'Int'
    => via {
        my ( $s, $m, $h, $d, $M, $y ) = gmtime($_);
        return sprintf '%4d-%02d-%02dT%02d:%02d:%02dZ', $y + 1900, $M + 1, $d, $h, $m, $s
    };
coerce 'TimeStamp'
    => from 'ArrayRef[HashRef]'
    => via { $_->[0]{value} };
has rev => ( is => 'rw', isa => 'TimeStamp', coerce => 1  );

subtype 'UID'
    => as 'Str'
    => where { m/^urn:uuid:[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}$/is }
    => message { "The UID you provided, $_, was not correct" };
has uid => ( is => 'rw', isa => 'UID' );

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

subtype 'TimeZones' => as 'ArrayRef[DateTime::TimeZone]';
coerce 'TimeZones'
    => from 'ArrayRef'
    => via {[ map{ DateTime::TimeZone->new( name => $_ ) } @$_ ]};
coerce 'TimeZones'
    => from 'Str'
    => via {[ DateTime::TimeZone->new( name => $_ ) ]};
has tz =>  ( is => 'rw', isa => 'TimeZones', coerce => 1 );
# utc-offset format is NOT RECOMMENDED in vCard 4.0
# tz can be a URL, but there is no document in RFC2426 and RFC6350

has [qw|bday anniversary gender prodid sort_string|] => ( is => 'rw', isa => 'Str' );

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

sub parse_param {
    my ( $self, $value ) = @_;
    my $ref = {};
    $ref->{types} = [split /,/, $value->{param}{TYPE}] if $value->{param}{TYPE};
    $ref->{media_type} = $value->{param}{MEDIATYPE} if $value->{param}{MEDIATYPE};
    $ref->{pref} = $value->{param}{PREF} if $value->{param}{PREF};
    return $ref;
}

sub _make_hashref {
    my ( $self, $data ) = @_;
    my $hashref = {};
    while( my( $name, $values) = each $data->{properties} ){
        next if $name eq 'VERSION';
        foreach my $value (@$values) {
            if( $name eq 'N' ){
                my @names = split /(?<!\\);/, $value->{value};
                $hashref->{$name} ||= \@names;
            }elsif( $name eq 'REV' ){
                $hashref->{$name} ||= $value->{value};
            }elsif( $name eq 'ADR' ){
                my $ref = $self->parse_param($value);
                my @addesses = split /(?<!\\);/, $value->{value};
                $ref->{pobox}       = $addesses[0];
                $ref->{extended}    = $addesses[1];
                $ref->{street}      = $addesses[2];
                $ref->{city}        = $addesses[3];
                $ref->{region}      = $addesses[4];
                $ref->{post_code}   = $addesses[5];
                $ref->{country}     = $addesses[6];
                push @{$hashref->{$name}}, $ref;
            }else{
                my $ref = $self->parse_param($value);
                $ref->{value} = $value->{value};
                push @{$hashref->{$name}}, $ref;
            }
        }
    }
    return $hashref;
}

sub load_file {
    my ( $self, $filename ) = @_;
    open my $vcf, "<", $filename or croak "couldn't open vcf: $!";
    my $data = $vf->parse($vcf)->{objects}[0];
    close $vcf;
    croak "$filename is NOT a vCard file." unless $data->{type} eq 'VCARD';

    my $hashref = $self->_make_hashref($data);
    $self->load_hashref($hashref);
}

sub load_string {
    my ( $self, $string ) = @_;
    my @lines = split /\r\n/, $string;
    my $data = $vf->parse_lines(@lines);
    my $hashref = $self->_make_hashref($data->{objects}[0]);
    $self->load_hashref($hashref);
}

my @nodes = qw(
    FN N NICKNAME
    ADR LABEL TEL EMAIL IMPP LANG GEO
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
                    $string .= uc($node) . ":" . $item . $cr;
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

sub as_file {
    my ( $self, $filename ) = @_;
    my $file = $self->_path($filename);
    $file->spew( $self->_iomode_out, $self->as_string );
    return $file;
}

# Alias
sub address {
    my $self = shift;
    $self->adr(@_);
}

sub fullname {
    my $self = shift;
    $self->fn(@_);
}

sub full_name {
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
