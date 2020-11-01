use strict;
use warnings;

use Path::Tiny;
use MIME::Base64;
use URI;
use List::Util qw(first);

use Text::vCard::Precisely::V3;

use Test::More tests => 7;

my $vc = Text::vCard::Precisely::V3->new();

my $img = <<'EOL';
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAABlBMVEUAAAD/AAAb/
40iAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAFElEQVQ4jWNgGAWjYBSMglFATwAABXgAAfmlXsc
AAAAASUVORK5CYII=
EOL
$img =~ s/\s//g;

my $in_file          = path( 't', 'V3', 'Image', 'base.vcf' );
my $expected_content = $in_file->slurp_raw;

$vc->photo($img);
$vc->logo($img);
is $vc->as_string, $expected_content, 'photo(Base64)';    # 1

$in_file          = path( 't', 'V3', 'Image', 'uri.vcf' );
$expected_content = $in_file->slurp_raw;

my $uri = URI->new('https://www.example.com/image.png');
$vc->photo($uri);
is $vc->as_string, $expected_content, 'photo(URL)';       # 2

$in_file          = path( 't', 'V3', 'Image', 'hash.vcf' );
$expected_content = $in_file->slurp_raw;

$vc->photo( { media_type => 'image/png', content => $img } );
$vc->logo( { media_type => 'image/png', content => $img } );
is $vc->as_string, $expected_content, 'photo(HashRef of Base64)';    # 3

$in_file          = path( 't', 'V3', 'Image', 'maltiple.vcf' );
$expected_content = $in_file->slurp_raw;

my $img2 = <<'EOL';
/9j/4AAQSkZJRgABAQEAYABgAAD//gA
+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2ODApLCBkZWZhdWx0IHF1Y
WxpdHkK/
9sAQwAIBgYHBgUIBwcHCQkICgwUDQwLCwwZEhMPFB0aHx4dGhwcICQuJyAiLCMcHCg3KSwwMTQ
0NB8nOT04MjwuMzQy/
9sAQwEJCQkMCwwYDQ0YMiEcITIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI
yMjIyMjIyMjIyMjIy/8AAEQgAZABkAwEiAAIRAQMRAf/
EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//
EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNic
oIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4S
FhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5
ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//
EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0
QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoK
DhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5
OXm5+jp6vLz9PX29/j5+v/
aAAwDAQACEQMRAD8A4uiiivmT9xCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKK
ACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooo
oAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACii
igAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/2Q==
EOL
$img2 =~ s/\s//g;

$vc->photo( [ $img, $img2 ] );
is $vc->as_string, $expected_content, 'photo(ArrayRef of base64)';    # 4

$in_file          = path( 't', 'V3', 'Image', 'maltiple_base64.vcf' );
$expected_content = $in_file->slurp_raw;

$vc->photo(
    [   { media_type => 'image/png',  content => $img },
        { media_type => 'image/jpeg', content => $img2 },
    ]
);
is $vc->as_string, $expected_content, 'photo(ArrayRef of HashRef)';    # 5

SKIP: {
    eval { require GD };
    skip "GD is not installed: $@", 2 if $@;

    my $gd    = new GD::Image( 100, 100 );
    my $black = $gd->colorAllocate( 0, 0, 0 );
    $gd->rectangle( 0, 0, 99, 99, $black );

    my $raw = $gd->png;

    my @expected = ();
    $in_file = path( 't', 'V3', 'Image', 'gd.vcf' );
    push @expected, $in_file->slurp_raw;
    $in_file = path( 't', 'V3', 'Image', 'gd2.vcf' );
    push @expected, $in_file->slurp_raw;

    $vc->photo($raw);
    $vc->logo($raw);
    my $got = $vc->as_string;
    if ( first { $got eq $_ } @expected ) {    # 6
        pass 'photo(raw)';
    } else {

        # this will fail, to have $got & $expect printed out for diagnostics
        is $got, $expected[1], 'photo(raw)';
    }

    my $red = $gd->colorAllocate( 255, 0, 0 );
    $gd->fill( 50, 50, $red );
    my $raw2 = $gd->jpeg;

    $vc->photo(
        [   { media_type => 'image/png',  content => $raw },
            { media_type => 'image/jpeg', content => $raw2 },
        ]
    );
    $vc->logo( { media_type => 'image/png', content => $raw } );
    $got = $vc->as_string;

    my $parse = $vc->load_string($got);

    @expected = ();
    $in_file  = path( 't', 'V3', 'Image', 'maltiple_gd.vcf' );
    push @expected, $in_file->slurp_raw;
    $in_file = path( 't', 'V3', 'Image', 'maltiple_gd2.vcf' );
    push @expected, $in_file->slurp_raw;

    #    $in_file = path( 't', 'V3', 'Image', 'maltiple_gd3.vcf' );
    #    push @expected, $in_file->slurp_raw;

    $vc->photo(
        [   { media_type => 'image/png',  content => $raw },
            { media_type => 'image/jpeg', content => $raw2 },
        ]
    );
    $vc->logo( { media_type => 'image/png', content => $raw } );
    $got = $vc->as_string;
    $got
        =~ s|\Q+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2NjIpLCBkZWZhdWx0IHF1Y|+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2ODApLCBkZWZhdWx0IHF1Y|m;
    $got
        =~ s|\Q+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2OTApLCBkZWZhdWx0IHF1Y|+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2ODApLCBkZWZhdWx0IHF1Y|m;

    if ( first { $got eq $_ } @expected ) {    # 7
        pass 'photo(ArrayRef of Hashref of raw)';
    } else {

        # this will fail, to have $got & $expect printed out for diagnostics
        is $got, $expected[1], 'photo(ArrayRef of Hashref of raw)';
    }
}

done_testing;
