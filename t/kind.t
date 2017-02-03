use strict;
use warnings;
use Path::Tiny;
use Encode;

use Test::More tests => 2;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $in_file = path( 't', 'kind', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->kind('individual');
is $vc->as_string, $expected_content, 'kind(Str)';                      # 1

$in_file = path( 't', 'kind', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->kind([qw(individual org)]);
is $vc->as_string, $expected_content, 'kind(ArrayRef of Str)';          # 2

done_testing;
