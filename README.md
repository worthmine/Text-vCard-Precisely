# Text-vCard-Precisely-V3

#SYNOPUS
```
my $vc = Text::vCard::Precisely::V3->new();
$vc->n([ 'Gump', 'Forrest', , 'Mr' ]);
$vc->fn( 'Forrest Gump' );

my $img = GD->new( ... some param ... )->plot->png;
$vc->photo([
  { value => 'https://avatars2.githubusercontent.com/u/2944869?v=3&s=400',  media_type => 'image/jpeg' },
  { value => $img, media_type => 'image/png' }, # Now you can set image directly
]);

$vc->org({ name => 'ORG', value => 'Bubba Gump Shrimp Co.' }); # Now you can set/get org!

$vc->tel({ value => '+1-111-555-1212', types => ['work'], pref => 1 });

$vc->email({ value => 'forrestgump@example.com', types => ['work'] });

$vc->adr( {
  types => ['work'],
  pobox     => '109',
  extended  => 'Shrimp Bld.',
  street    => 'Waters Edge',
  city      => 'Baytown',
  region    => 'LA',
  post_code => '30314,
  country   => 'United States of America',
});

$vc->url({ value => 'https://twitter.com/worthmine', types => ['twitter'] }); # for URL param

use Facebook::Graph;
my $fb = Facebook::Graph->new(
  app_id => 'your app id',
  secret => 'your secret key',
);
$fb->authorize;
$fb->access_token( $fb->app_id . '|' . $fb->secret );
my $q = $fb->query->find( $hash->{'facebookID'} )
  ->select_fields(qw( id name ))
  ->request
  ->as_hashref;

$vc->socialprofile({ # Now you can set X-Social-Profile 
  value => 'https://www.facebook.com/worthmine',
  types => 'facebook',
  displayname => encode_utf8( $q->{'name'} ),
  userid => $q->{'id'},
});

print $vc->as_string();
```
