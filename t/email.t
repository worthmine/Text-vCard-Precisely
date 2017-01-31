use strict;
use warnings;
use Path::Tiny;
use Encode;

use Test::More tests => 3;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $in_file = path( 't', 'email', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->email('tester@example.com');
is $vc->as_string, $expected_content, 'email(Str)';                    # test1

$vc->email({ value => 'tester@example.com' });
is $vc->as_string, $expected_content, 'email(HashRef)';                # test2

$in_file = path( 't', 'email', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->email([
    { types => ['home'], value => 'tester@example.com' },
    { types => ['work'], value => 'tester2@example.com' },
]);
is $vc->as_string, $expected_content, 'email(ArrayRef of HashRef)';        # test2

done_testing;
