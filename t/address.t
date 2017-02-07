use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 3;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();

my $in_file = path( 't', 'address', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->adr({
    pobox      => 'pobox',
    extended   => 'extended',
    street     => 'street',
    city       => 'city',
    region     => 'region',
    post_code  => 'post_code',
    country    => 'country',
});
is $vc->as_string, $expected_content, 'adr(HashRef)';                   # 1

$in_file = path( 't', 'address', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->adr([{
    pobox      => 'pobox',
    extended   => 'extended',
    street     => 'street',
    city       => 'city',
    region     => 'region',
    post_code  => 'post_code',
    country    => 'country',
},{
    pobox      => 'another pobox',
    extended   => 'another extended',
    street     => 'another street',
    city       => 'another city',
    region     => 'another region',
    post_code  => 'another post_code',
    country    => 'another country',
}]);
is $vc->as_string, $expected_content, 'adr(ArrayRef of HashRef)';       # 2

$in_file = path( 't', 'address', 'utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->encoding_out('UTF-8');
$vc->adr({
    types       => [qw(home work)],
    pobox       => '201号室',
    extended    => 'マンション',
    street      => '通り',
    city        => '市',
    region      => '都道府県',
    post_code   => '郵便番号',
    country     => '日本',
    charset     => 'UTF-8',
});
is $vc->as_string, $expected_content, 'adr(HashRef with utf8)';         # 3

done_testing;
