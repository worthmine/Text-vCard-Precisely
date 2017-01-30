use strict;
use warnings;
use Path::Tiny;
use Encode;

use Test::More tests => 11;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $in_file = path( 't', 'n', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->n('family;given;additional;prefixes;suffixes');
is $vc->as_string, $expected_content, 'n(Str)';                             # test1

$vc->n([
    'family',
    'given',
    'additional',
    'prefixes',
    'suffixes'
]);
is $vc->as_string, $expected_content, 'n(ArrayRef)';                        # test2

$vc->n({
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
    suffixes => 'suffixes'
});
is $vc->as_string, $expected_content, 'n(HashRef)';                         # test3

$in_file = path( 't', 'n', 'no_suffixes.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->n('family;given;additional;prefixes');
is $vc->as_string, $expected_content, 'n(Str with no suffixes)';            # test4

$vc->n([
    'family',
    'given',
    'additional',
    'prefixes',
]);
is $vc->as_string, $expected_content, 'n(ArrayRef with no suffixes)';       # test5

$vc->n({
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
});
is $vc->as_string, $expected_content, 'n(HashRef with no suffixes)';        # test6

$vc->n([[
    'family',
    'given',
    'additional',
    'prefixes',
]]);
is $vc->as_string, $expected_content, 'n(ArrayRef with no suffixes)';       # test7

$vc->n([{
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
}]);
is $vc->as_string, $expected_content, 'n(HashRef with no suffixes)';        # test8

$in_file = path( 't', 'n', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->n([
    [ 'family', 'given', 'additional', 'prefixes', ],
    [ 'anoter family', 'anoter given', 'anoter additional', 'anoter prefixes', ],
]);
is $vc->as_string, $expected_content, 'n(ArrayRef of ArrayRef)';            # test9

$vc->n([
{
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
},
{
    family => 'anoter family',
    given => 'anoter given',
    additional => 'anoter additional',
    prefixes => 'anoter prefixes',
}]);
is $vc->as_string, $expected_content, 'n(ArrayRef of HashRef)';             # test10

$in_file = path( 't', 'n', 'utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->n({
    value => [ '姓', '名', '', '','様' ],
    charset => 'UTF-8',
});
is decode_utf8($vc->as_string), $expected_content, 'n(HashRef with utf8)';  # test11

done_testing;
