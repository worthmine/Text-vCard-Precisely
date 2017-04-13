use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 3;

use lib qw(./lib);

use Text::vCard::Precisely::V4;

my $vc = Text::vCard::Precisely::V4->new();

my $in_file = path( 't', 'V4', 'tel', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->tel('0120-000-000');
is $vc->as_string, $expected_content, 'tel(Str)';                    # test1

$vc->tel({ value => '0120-000-000' });
is $vc->as_string, $expected_content, 'tel(HashRef)';                # test2

$in_file = path( 't', 'V4', 'tel', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->tel([
    { types => ['home'], value => '0120-000-000' },
    { types => ['fax'], value => '0120-000-001' },
]);
is $vc->as_string, $expected_content, 'tel(ArrayRef of HashRef)';        # test3

done_testing;
