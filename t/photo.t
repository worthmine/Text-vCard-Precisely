use strict;
use warnings;
use Path::Tiny;

use Test::More tests => 4;

use lib qw(./lib);

use Text::vCard::Precisely::V3;

my $vc = Text::vCard::Precisely::V3->new();
$vc->rev('2008-04-24T19:52:43Z');

my $img = <<'END';
iVBORw0KGgoAAAANSUhEUgAAAIgAAACIAQMAAAAGdDERAAAABlBMVEX///8AAABVwtN+AAAACXB
IWXMAAA7EAAAOxAGVKw4bAAACHElEQVRIie3UO5LcIBAGYEjgCpDA1VAirgCJHgm6AiToaiiRrg
CJ2Hbt7Li8M+3IzpZo6qtqGJpfTcjP+i9L9zXK29HTyV4RETRFH5VdZFsEIrJtp273HIXfIyqpD
lukxQ1/kUXp1reiKCpw+uLTeq1t/f1/vonu6Ws97/VdCGET3Pake3n247vAyQu9epyPMBpEaFGT
Xeskt+MUmKQ6BwuNNTwYTCrxhe5tg7sSRPTWtjAO29XTURAhTsch8BRH+9j5jczbFYxR816cQ0R
W2wrT6+lGJhDR181PMlyLMo+qVyHwS94cqpSuiKghCx+NXZTvERFZmNK3mxhTyiFC97UOi2JmUj
YiIpjNulVbnX107FXo3otPPc+tP9LyRqq+P9NSZUSE+GzokSAtLTtEaFTMrustt+c+L8L0bYPt6
Ta6FUR4FrIQ5Ys+GUGEtqjDUInt7SqIkNEu0DF+smdaXkTNGU6HeEZfHCaEJ3ggmCQ8CETktl0n
05AW/2jYG4nCyH5AWqahIqJkKj5zqLItIqKrP3Uvc2QTcYiw+YAvRW/nxHhEhEwzVB09TsIviDA
Onci82PCV8FfhxYzwdiMktGGi117p8Wva9JsgAndVf6blVTQEN9gEaZHZICJokIWue5jr5+O8Ed
n2Hoa+mBk+B1SyGIKjZeSPnd9JgqoMURiKQETQLAuvkBZ6YwJTfT9phikxfs2fF/lZ/3x9AO7aZ
lkCfGP0AAAAAElFTkSuQmCC
END
$img =~ s/\s//g;

my $in_file = path( 't', 'base64.vcf' );
my $expected_content = $in_file->slurp_utf8;

$vc->photo( { media_type => 'image/gif', value => $img } );
is $vc->as_string, $expected_content, 'photo()';

$vc->photo( [ { media_type => 'image/gif', value => $img } ] );
is $vc->as_string, $expected_content, 'photo([])';

$vc->photo($img);
is $vc->as_string, $expected_content, 'photo($value)';

$vc->photo([$img]);
is $vc->as_string, $expected_content, 'photo([$value])';

done_testing;
