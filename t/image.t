use strict;
use warnings;
use Path::Tiny;
use MIME::Base64;
use URI;

use Test::More tests => 8;

my $GD_ok = require_ok ('GD');
my ($img, $black, $red);

use lib qw(./lib);
use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

if($GD_ok){
    $img = new GD::Image(100,100);
    $black = $img->colorAllocate(0,0,0);
    $red = $img->colorAllocate(255,0,0);
    $img->rectangle(0,0,99,99,$black);
}

my $raw = $img->png if $GD_ok;
my $base64 = encode_base64( $raw, "" );

my $in_file = path( 't', 'Image', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->photo($raw);
$vc->logo($raw);
is $vc->as_string, $expected_content, 'photo(raw)';                 # test1

$vc->photo($base64);
is $vc->as_string, $expected_content, 'photo(Base64)';              # test2

$in_file = path( 't', 'Image', 'hash.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->photo( { media_type => 'image/png', value => $raw } );
$vc->logo( { media_type => 'image/png', value => $raw } );
is $vc->as_string, $expected_content, 'photo(Hashref of raw)';      # test3

$vc->photo( { media_type => 'image/png', value => $base64 } );
$vc->logo( { media_type => 'image/png', value => $base64 } );
is $vc->as_string, $expected_content, 'photo(HashRef of Base64)';   # test4

$in_file = path( 't', 'Image', 'uri.vcf' );
$expected_content = $in_file->slurp_utf8;

my $uri = URI->new('https://www.example.com/image.png');
$vc->photo($uri);
is $vc->as_string, $expected_content, 'photo(URL)';                 # test5

$in_file = path( 't', 'Image', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$img->fill(50,50,$red) if $GD_ok;
my $raw2 = $img->jpeg if $GD_ok;
$vc->photo([ $raw, $raw2 ]);
is $vc->as_string, $expected_content, 'photo(ArrayRef of raw)';     # test6

$in_file = path( 't', 'Image', 'maltiple2.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->photo([
    { media_type => 'image/png', value => $base64 },
    { media_type => 'image/jpeg', value => $raw2 },
]);
is $vc->as_string, $expected_content, 'photo(ArrayRef of HashRef)';     # test7

done_testing;
