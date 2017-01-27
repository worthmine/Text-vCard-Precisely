use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 6;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $in_file = path( 't', 'n.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->n({ charset => 'UTF-8', value => 'family;given;additional;prefixes;suffixes' });
is $vc->as_string, $expected_content, 'n(Str)';                         # test1

$vc->n({ charset => 'UTF-8', value =>[
    'family',
    'given',
    'additional',
    'prefixes',
    'suffixes'
]});
is $vc->as_string, $expected_content, 'n(ArrayRef)';                    # test2

$vc->n({ charset => 'UTF-8', value =>{
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
    suffixes => 'suffixes' },
});
is $vc->as_string, $expected_content, 'n(HashRef)';                     # test3

$in_file = path( 't', 'no_suffixes.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->n({ charset => 'UTF-8', value => 'family;given;additional;prefixes;' });
is $vc->as_string, $expected_content, 'n(Str with no suffixes)';        # test4

$vc->n({ charset => 'UTF-8', value =>[
    'family',
    'given',
    'additional',
    'prefixes',
]});
is $vc->as_string, $expected_content, 'n(ArrayRef with no suffixes)';   # test5

$vc->n({ charset => 'UTF-8', value =>{
    family => 'family',
    given => 'given',
    additional => 'additional',
    prefixes => 'prefixes',
}});
is $vc->as_string, $expected_content, 'n(HashRef with no suffixes)';    # test6



done_testing;
