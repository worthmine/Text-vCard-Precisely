use strict;
use warnings;
use Encode qw(decode_utf8 encode_utf8);

use lib 'lib';

use Text::vCard::Precisely::V3;
use Text::vCard::Precisely::V4;
my $vc3 = Text::vCard::Precisely::V3->new();
my $vc4 = Text::vCard::Precisely::V4->new();

my $fn = "Först Last";
printf '%vX', $fn;
print "\n";
$vc3->fn($fn);
$vc4->fn($fn);

use Text::vCard::Precisely::Multiple;
my $vcm = Text::vCard::Precisely::Multiple->new( version => '4.0' );

$vcm->add_option($vc3);
$vcm->add_option($vc4);

$vcm->add_option($_) for $vcm->all_options();
$vcm->add_option( $vcm->all_options() );

print $vcm->as_string();
