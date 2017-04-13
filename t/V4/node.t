use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 4;

use lib qw(./lib);

use Text::vCard::Precisely::V4;

my $vc = Text::vCard::Precisely::V4->new();

my $in_file = path( 't', 'V4', 'node', 'base.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->fn('Forrest Gump');
$vc->nickname('Gumpy');
$vc->org('Bubba Gump Shrimp Co.');
$vc->impp('aim:johndoe@aol.com');
$vc->lang('en-us');
$vc->title('Shrimp Man');
$vc->role('Section 9');
$vc->categories('fisher');
$vc->note("It's a note!");
$vc->xml('<b>Not an xCard XML element</b>');
$vc->geo('39.95;-75.1667');
is $vc->as_string, $expected_content, 'Node(Str)';                      # 1

$in_file = path( 't', 'V4', 'Node', 'hash.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->label({
    types => ['home'],
    value => '123 Main St.\nSpringfield, IL 12345\nUSA'
}); # DEPRECATED in vCard4.0
$vc->key({ types => ['PGP'], value => 'http://example.com/key.pgp' });
is $vc->as_string, $expected_content, 'Node(HashRef)';                  # 2

$in_file = path( 't', 'V4', 'node', 'maltiple.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->fn([{ value => 'Forrest Gump'}]);
$vc->nickname([{ value => 'Gumpy' }]);
$vc->org([{ value => 'Bubba Gump Shrimp Co.' }]);
$vc->impp([{ value => 'aim:johndoe@aol.com' }]);
$vc->lang([{ value => 'en-us' }, { value => 'ja-jp' }]);
$vc->title([{ value => 'Shrimp Man' }]);
$vc->role([{ value => 'Section 9' }]);
$vc->categories([{ value => 'fisher' }]);
$vc->note([{ value => "It's a note!" }]);
$vc->xml([{ value => '<b>Not an xCard XML element</b>' }]);
$vc->geo([{ value => '39.95;-75.1667' }]);
$vc->key([{ types => ['PGP'], value => 'http://example.com/key.pgp' }]);

is $vc->as_string, $expected_content, 'Node(ArrayRef of HashRef)';      # 3

$in_file = path( 't', 'V4', 'node', 'utf8.vcf' );
$expected_content = $in_file->slurp_utf8;

$vc->nickname([{ value => '一期一会' }]);
is $vc->as_string, $expected_content, 'Node(HashRef with utf8)';        # 4

done_testing;
