# NAME
Text::vCard::Precisely::V3 - Read, Write and Make vCards 3.0 **not 4.0**

## SYNOPSIS

```
my $vc = Text::vCard::Precisely::V3->new();
$vc->n([ 'Gump', 'Forrest', , 'Mr', '' ]);
$vc->fn( 'Forrest Gump' );

my $img = GD->new( ... some param ... )->plot->png;
$vc->photo([
  { value => 'https://avatars2.githubusercontent.com/u/2944869?v=3&s=400',  media_type => 'image/jpeg' },
  { value => $img, media_type => 'image/png' }, # Now you can set a binary image directly
]);

$vc->org('Bubba Gump Shrimp Co.'); # Now you can set/get org!

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
use Encode;

my $fb = Facebook::Graph->new(
  app_id => 'your app id',
  secret => 'your secret key',
);
$fb->authorize;
$fb->access_token( $fb->{'app_id'} . '|' . $fb->{'secret'} );
my $q = $fb->query->find( 'some facebookID' )
  ->select_fields(qw( id name ))
  ->request
  ->as_hashref;

$vc->socialprofile({ # Now you can set X-Social-Profile but Android ignore it
  value => 'https://www.facebook/' . 'some facebookID',
  types => 'facebook',
  displayname => encode_utf8( $q->{'name'} ),
  userid => $q->{'id'},
});

print $vc->as_string();
```

## DESCRIPTION

A vCard is a digital business card.  vCard and [vCard::AddressBook](https://metacpan.org/pod/vCard::AddressBook) provide an
API for parsing, editing, and creating vCards.

This module is rebuilt from [Text::vCard](https://github.com/ranguard/text-vcard) because It doesn't provides some methods.

To handle an address book with several vCard entries in it, start with
[vCard::AddressBook](https://metacpan.org/pod/vCard::AddressBook) and then come back to this module.

Note that the vCard RFC requires version() and full\_name().  This module does
not check or warn if these conditions have not been met.

## METHODS

### as\_string()
Returns the vCard as a string.

### as\_file($filename)
Write data in vCard format to $filename.

Dies if not successful.

## SIMPLE GETTERS/SETTERS
These methods accept and return strings.  

### version()
Version number of the vcard.  Defaults to **'3.0'**

### fn(), fullname()
A person's entire name as they would like to see it displayed.  

### kind()
To specify the kind of object the vCard represents.

### rev()
To specify revision information about the current vCard.

### bday(), birthday()
To specify the birth date of the object the vCard represents.

### anniversary()
The date of marriage, or equivalent, of the object the vCard represents.

### gender()
To specify the components of the sex and gender identity of the object the vCard represents.

### prodid() 
To specify the identifier for the product that created the vCard object.

### sort_string()
To specify the family name or given name text to be used for national-language-specific sorting of the FN and N types.

## ArrayRef GETTERS/SETTERS

### n()
To specify the components of the name of the object the vCard represents.

## COMPLEX GETTERS/SETTERS
it's based on Moose with coercion. So These methods accept Arrrayref[HashRef] or HashRef.

### photo(), logo()
Accepts/returns an arrayref of URLs or Image. it's include encoding Base64.

Attention! Mac OS X and iOS **ignore** the description beeing URL.  
use Base64 encoding or raw image if you have to show the image you want.

### tz(), timezone()
To specify information related to the time zone of the object the vCard represents.

### geo(), nickname(), impp(), lang(), xml(), key()
I don't think they are not popular paramater but here are the methods!

### note()
To specify supplemental information or a comment that is associated with the vCard.

### org(), title(), role(), categories()
To specify additional information for your jobs.

### tel()
Accepts/returns an arrayref that looks like:
```
    [
      { type => ['work'], value => '651-290-1234', preferred => 1 },
      { type => ['home'], value => '651-290-1111' },
    ]
```

### adr()
Accepts/returns an arrayref that looks like:
```
    [
      { types => ['work'], street => 'Main St', pref => 1 },
      { types     => ['home'], 
        pobox     => 1234,
        extended  => 'asdf',
        street    => 'Army St',
        city      => 'Desert Base',
        region    => '',
        post_code => '',
        country   => 'USA',
        pref      => 1,
      },
    ]
```

## email()
Accepts/returns an arrayref that looks like:
```
    [
      { type => ['work'], value => 'bbanner@ssh.secret.army.mil' },
      { type => ['home'], value => 'bbanner@timewarner.com', pref => 1 },
    ]
```
### url()
Accepts/returns an arrayref that looks like:
```
    [
      { value => 'https://twitter.com/worthmine', types => ['twitter'] },
      { value => 'https://github.com/worthmine' },
    ]
```

### source(), sound(), fburl(), caladruri(), caluri()
I don't think they are not popular paramater but here are the methods!

## SEE ALOSO
[RFC6350](https://tools.ietf.org/html/rfc6350), [RFC2426](https://tools.ietf.org/html/rfc2426)

## AUTHOR
[Yuki Yoshida (worthmine)](https://github.com/worthmine)
