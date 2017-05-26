use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 6;

use lib qw(./lib);

use Text::vCard::Precisely::V4;

my $vc = Text::vCard::Precisely::V4->new();

my $in_file = path( 't', 'V4', 'address', 'base.vcf' );
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

$in_file = path( 't', 'V4', 'address', 'maltiple.vcf' );
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
    extended   => 'extended',
    street     => 'another street',
    city       => 'city',
    region     => 'region',
    post_code  => 'post_code',
    country    => 'country',
}]);
is $vc->as_string, $expected_content, 'adr(ArrayRef of HashRef)';       # 2

$in_file = path( 't', 'V4', 'address', 'utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->adr({
    types       => [qw(home work)],
    pobox       => '201号室',
    extended    => 'マンション',
    street      => '通り',
    city        => '市',
    region      => '都道府県',
    post_code   => '郵便番号',
    country     => '日本',
});
is $vc->as_string, $expected_content, 'adr(HashRef with utf8)';         # 3

$in_file = path( 't', 'V4', 'address', 'long_ascii.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->adr({
    types       => [qw(home work)],
    pobox      => 'pobox',
    extended   => 'long named extended',
    street     => 'long named street',
    city       => 'long named city',
    region     => 'long named region',
    post_code  => 'post_code',
    country    => 'United States of America',
});
is $vc->as_string, $expected_content, 'adr(HashRef with long ascii)';   # 4

$in_file = path( 't', 'V4', 'address', 'long_utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->adr({
    types       => [qw(home work)],
    pobox       => '201号室',
    extended    => '必要以上に長い名前のマンション',
    street      => '冗長化された通り',
    city        => '八王子市',
    region      => '都道府県',
    post_code   => '郵便番号',
    country     => '日本',
});
is $vc->as_string, $expected_content, 'adr(HashRef with long utf8)';    # 5

$in_file = path( 't', 'V4', 'address', 'label.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->adr({
    street     => '123 Main Street',
    city       => 'Any Town',
    region     => 'CA',
    post_code  => '91921-1234',
    country    => 'U.S.A.',
    label      => "Mr. John Q. Public, Esq.\nMail Drop: TNE QB\n123 Main Street\nAny Town, CA  91921-1234\nU.S.A."
});
is $vc->as_string, $expected_content, 'adr(HashRef with label)';        # 6

done_testing;
