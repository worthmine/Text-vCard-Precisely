use strict;
use warnings;
use Path::Tiny;
use Encode;
use URI;

use Test::More tests => 2;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $in_file = path( 't', 'Social', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->socialprofile({ types => 'GitHub', value => 'https://github.com/worthmine' });
is $vc->as_string, $expected_content, 'socialprofile(HashRef)';                 # 1

$in_file = path( 't', 'Social', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->socialprofile([
    { types => 'twitter', value => 'https://twitter.com/worthmine' },
    { types => 'facebook', value => 'https://www.facebook.com/worthmine',
        displayname => 'worthmine',
        userid => '102074486543502',
    },
    { types => 'LinkedIn', value => 'https://jp.linkedin.com/in/worthmine' },
    { types => 'GitHub', value => 'https://github.com/worthmine' },
]);
is $vc->as_string, $expected_content, 'socialprofile(ArrayRef of HashRef)';     # 2

done_testing;
