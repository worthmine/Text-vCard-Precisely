use strict;
use warnings;
use Path::Tiny;
use URI;

use Test::More tests => 4;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();

my $in_file = path( 't', 'URI', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->url('https://www.example.com');
$vc->source('https://www.example.com');
$vc->fburl('https://www.example.com');
$vc->caladruri('https://www.example.com');
$vc->caluri('https://www.example.com');
is $vc->as_string, $expected_content, 'url(Str)';                    # test1

$vc->url({ value => 'https://www.example.com' });
$vc->source({ value => 'https://www.example.com' });
$vc->fburl({ value => 'https://www.example.com' });
$vc->caladruri({ value => 'https://www.example.com' });
$vc->caluri({ value => 'https://www.example.com' });
is $vc->as_string, $expected_content, 'url(HashRef)';                # test2

my $url = URI->new('https://www.example.com');
$vc->url($url);
$vc->source($url);
$vc->fburl($url);
$vc->caladruri($url);
$vc->caluri($url);
is $vc->as_string, $expected_content, 'url(URI)';                    # test3

$in_file = path( 't', 'URI', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->url([
    { types => ['home'], value => 'https://www.example.com' },
    { types => ['work'], value => 'https://blog.example.com' },
]);
$vc->source('https://www.example.com');
$vc->fburl('https://www.example.com');
$vc->caladruri('https://www.example.com');
$vc->caluri('https://www.example.com');
is $vc->as_string, $expected_content, 'url(ArrayRef of HashRef)';        # test4

done_testing;
