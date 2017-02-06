use strict;
use warnings;
use Path::Tiny;
use Encode;
use Data::UUID;

use Test::More tests => 1;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
my $uuid = Data::UUID->new->create_from_name_str( NameSpace_URL, 'www.exsample.com' );
$vc->uid("urn:uuid:$uuid");

my $in_file = path( 't', 'uid.vcf' );
my $expected_content = $in_file->slurp_utf8;

is $vc->as_string, $expected_content, 'uid(Data::UUID)';                # 1

done_testing;
