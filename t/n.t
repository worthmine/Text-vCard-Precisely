use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 7;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();

my $in_file = path( 't', 'n', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->n('family;given;additional;prefixes;suffixes');
is $vc->as_string, $expected_content, 'n(Str)';                         # 1

$vc->n([
    'family',
    'given',
    'additional',
    'prefixes',
    'suffixes'
]);
is $vc->as_string, $expected_content, 'n(ArrayRef)';                    # 2

$vc->n({
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
    suffixes => 'suffixes'
});
is $vc->as_string, $expected_content, 'n(HashRef)';                     # 3

$in_file = path( 't', 'n', 'no_suffixes.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->n('family;given;additional;prefixes');
is $vc->as_string, $expected_content, 'n(Str with no suffixes)';        # 4

$vc->n([
    'family',
    'given',
    'additional',
    'prefixes',
]);
is $vc->as_string, $expected_content, 'n(ArrayRef with no suffixes)';   # 5

$vc->n({
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
});
is $vc->as_string, $expected_content, 'n(HashRef with no suffixes)';    # 6

$in_file = path( 't', 'n', 'utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->encoding_out('UTF-8');
$vc->n({
    value => [ '姓', '名', '', '','様' ],
    charset => 'UTF-8',
});
is $vc->as_string, $expected_content, 'n(HashRef with utf8)';           # 7

done_testing;
