# NAME
Text::vCard::Precisely::V3 - Read, Write and Edit vCards 3.0 **not 4.0**

## SYNOPSIS

```
my $vc = Text::vCard::Precisely::V3->new();
$vc->n([ 'Gump', 'Forrest', , 'Mr', '' ]);
$vc->fn( 'Forrest Gump' );

my $img = GD->new( ... some param ... )->plot->png;
my $base64 = MIME::Base64::encode($img);

$vc->photo([
  { value => 'https://avatars2.githubusercontent.com/u/2944869?v=3&s=400',  media_type => 'image/jpeg' },
  { value => $img, media_type => 'image/png' }, # Now you can set a binary image directly
  { value => $base64, media_type => 'image/png' }, # Also accept the text encoded in Base64
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

A vCard is a digital business card. vCard and [vCard::AddressBook](https://metacpan.org/pod/vCard::AddressBook) provide an API for parsing, editing, and creating vCards.

This module is rebuilt from [Text::vCard](https://github.com/ranguard/text-vcard) because some reason bellow:

- Text::vCard doesn't provides some methods.
- Mac OS X and iOS can't parse vCard4.0 with UTF-8 precisely.
- Android 4.4.x can't parse vCard4.0.
- I want to learn about Moose, of course. 

To handle an address book with several vCard entries in it, start with
[vCard::AddressBook](https://metacpan.org/pod/vCard::AddressBook) and then come back to this module.

Note that the vCard RFC requires version() and full_name().  This module does
not check or warn if these conditions have not been met.

## METHODS

### as_string()

Returns the vCard as a string.
You have to use encode_utf8() if your vCard is written in utf8

### as_file($filename)

Write data in vCard format to $filename.

Dies if not successful.

## SIMPLE GETTERS/SETTERS

These methods accept and return strings.  

### version()

Version number of the vcard.  Defaults to **'3.0'**

### rev()

To specify revision information about the current vCard.

### kind()

To specify the kind of object the vCard represents.
It's the new method from vCard4.0 but I don't care!

### sort_string()

To specify the family name or given name text to be used for national-language-specific sorting of the FN and N types.
**It's DEPRECATED from vCard4.0** Use SORT-AS param instead of it. The both are supported.

## COMPLEX GETTERS/SETTERS

They are based on Moose with coercion.
So these methods accept not only Arrrayref[HashRef] but also ArrayRef[Str], HashRef or Str.
Read source if you were confused.

### n()

To specify the components of the name of the object the vCard represents.

### tel()

Accepts/returns an arrayref that looks like:

```
    [
      { type => ['work'], value => '651-290-1234', preferred => 1 },
      { type => ['home'], value => '651-290-1111' },
    ]
```

### adr(), address()

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
        pref      => 2,
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

or accept the string as email like bellow 

```
    'bbanner@timewarner.com'
```

### url()

Accepts/returns an arrayref that looks like:

```
    [
      { value => 'https://twitter.com/worthmine', types => ['twitter'] },
      { value => 'https://github.com/worthmine' },
    ]
```

or accept the string as URL like bellow 

```
    'https://github.com/worthmine'
```


### photo(), logo()

Accepts/returns an arrayref of URLs or Images: Whether it is a raw binary data or a text encoded in Base64 does not matter.

Attention! Mac OS X and iOS **ignore** the description beeing URL.  
use Base64 encoding or raw image if you have to show the image you want.

### note()

To specify supplemental information or a comment that is associated with the vCard.

### org(), title(), role(), categories()

To specify additional information for your jobs.

### tz(), timezone()

To specify information related to the time zone of the object the vCard represents.

### fn(), full_name()

A person's entire name as they would like to see it displayed.  

### nickname()

To specify the text corresponding to the nickname of the object the vCard represents.

### bday(), birthday()

To specify the birth date of the object the vCard represents.

### anniversary()

The date of marriage, or equivalent, of the object the vCard represents.

### gender()

To specify the components of the sex and gender identity of the object the vCard represents.

### source()
  
To identify the source of directory information contained in the content type.

### lang()

To specify the language(s) that may be used for contacting the entity associated with the vCard.

### geo(), impp(), prodid(), xml(), key(), uid(), member(), sound(), fburl(), caladruri(), caluri()

I don't think they are not popular paramater, but here are the methods!

## aroud UTF-8

if you want to send precisely the vCard3.0 with UTF-8 characters to the **ALMOST** of smartphones, you have to set Charset param for each values like bellow...

```
ADR;CHARSET=UTF-8:201号室;マンション;通り;市;都道府県;郵便番号;日本

```

## SEE ALOSO

[RFC6350](https://tools.ietf.org/html/rfc6350), [RFC2426](https://tools.ietf.org/html/rfc2426)

## AUTHOR

[Yuki Yoshida (worthmine)](https://github.com/worthmine)
