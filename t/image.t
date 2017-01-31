use strict;
use warnings;
use Path::Tiny;
use MIME::Base64;
use URI;

use lib qw(./lib);
use Text::vCard::Precisely::V3;

use Test::More tests => 7;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $img = <<'EOL';
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAABlBMVEUAAAD/AAAb/
40iAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAFElEQVQ4jWNgGAWjYBSMglFATwAABXgAAfmlXsc
AAAAASUVORK5CYII=
EOL
$img =~ s/\s//g;

my $in_file = path( 't', 'Image', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->photo($img);
$vc->logo($img);
is $vc->as_string, $expected_content, 'photo(Base64)';              # test2

$in_file = path( 't', 'Image', 'uri.vcf' );
$expected_content = $in_file->slurp_utf8;

my $uri = URI->new('https://www.example.com/image.png');
$vc->photo($uri);
is $vc->as_string, $expected_content, 'photo(URL)';                 # test3

$in_file = path( 't', 'Image', 'hash.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->photo( { media_type => 'image/png', value => $img } );
$vc->logo( { media_type => 'image/png', value => $img } );
is $vc->as_string, $expected_content, 'photo(HashRef of Base64)';   # test4


$in_file = path( 't', 'Image', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

my $img2 = <<'EOL';
/9j/4AAQSkZJRgABAQEAYABgAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkc
gSlBFRyB2ODApLCBkZWZhdWx0IHF1YWxpdHkK/9sAQwAIBgYHBgUIBwcHCQkICgwUDQwLCwwZEh
MPFB0aHx4dGhwcICQuJyAiLCMcHCg3KSwwMTQ0NB8nOT04MjwuMzQy/9sAQwEJCQkMCwwYDQ0YM
iEcITIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy/8AA
EQgAZABkAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAI
BAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGB
kaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk
5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz
9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQ
EAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKS
o1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZm
qKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/a
AAwDAQACEQMRAD8A4uiiivmT9xCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAC
iiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAK
KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAo
oooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/2Q==
EOL
$img2 =~ s/\s//g;

$vc->photo([ $img, $img2 ]);
is $vc->as_string, $expected_content, 'photo(ArrayRef of base64)';  # test5

$in_file = path( 't', 'Image', 'maltiple_base64.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->photo([
    { media_type => 'image/png', value => $img },
    { media_type => 'image/jpeg', value => $img2 },
]);
is $vc->as_string, $expected_content, 'photo(ArrayRef of HashRef)'; # test6

SKIP: {
    eval { require GD::Image };
    skip "GD::Image not installed", 2 if $@;

    my $gd = GD::Image(100,100)->new unless $@;
    my $black = $gd->colorAllocate(0,0,0);
    $gd->rectangle(0,0,99,99,$black);
    my $raw = $gd->png;

    $in_file = path( 't', 'Image', 'base.vcf' );
    $expected_content = $in_file->slurp_utf8;

    $vc->photo($raw);
    $vc->logo($raw);
    is $vc->as_string, $expected_content, 'photo(raw)';             # test7

    my $red = $gd->colorAllocate(255,0,0);
    $gd->fill(50,50,$red);
    my $raw2 = $gd->jpeg;

    $in_file = path( 't', 'Image', 'maltiple_base64.vcf' );
    $expected_content = $in_file->slurp_utf8;

    $vc->photo([
        { media_type => 'image/png', value => $raw },
        { media_type => 'image/jpeg', value => $raw2 },
    ]);
    $vc->logo( { media_type => 'image/png', value => $raw } );
    is $vc->as_string, $expected_content, 'photo(ArrayRef of Hashref of raw)';  # test8
}

done_testing;
