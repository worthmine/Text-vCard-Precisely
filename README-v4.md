# NAME
Text::vCard::Precisely::V4 - Read, Write and Edit vCards **4.0**

## SYNOPSIS

```
my $vc = Text::vCard::Precisely::V4->new();
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

This module is an additional version for reading/writing for vCard 4.0. it's just a wrapper from V3 with Moose.

**Caution!** It's NOT be recommended because some reason bellow: 
- Mac OS X and iOS can't parse vCard4.0 with UTF-8 precisely.
- Android 4.4.x can't parse vCard4.0.

Note that the vCard RFC requires version() and full_name().  This module does
not check or warn if these conditions have not been met.

## METHODS

### as_string()

Returns the vCard as a string.
You HAVE TO use encode_utf8() if your vCard is written in utf8

### as_file($filename)

Write data in vCard format to $filename.

Dies if not successful.

## SIMPLE GETTERS/SETTERS

These methods accept and return strings.  

### version()

Version number of the vcard.  Defaults to **'4.0'**

### rev()

To specify revision information about the current vCard.
The format is **different from 3.0.**.

### kind()

To specify the kind of object the vCard represents.
It's the new method from 4.0.

### ~~sort_string()~~
**It's DEPRECATED from 4.0** Use SORT-AS param instead of it.

## COMPLEX GETTERS/SETTERS

They are based on Moose with coercion.
So these methods accept not only Arrrayref[HashRef] but also ArrayRef[Str], HashRef or Str.
Read source if you were confused.

### n()

To specify the components of the name of the object the vCard represents.

### tel()
The format is **different from 3.0.**, but supported

Accepts/returns an arrayref that looks like:

```
    [
      { type => ['work'], value => '651-290-1234', preferred => 1 },
      { type => ['home'], value => '651-290-1111' },
    ]
```

### adr(), address()

The format is SAME as 3.0.

## email()

The format is SAME as 3.0.

### url()

The format is SAME as 3.0.


### photo(), logo()

The format is SAME as 3.0.

### note()

The format is SAME as 3.0.

### org(), title(), role(), categories()

The format is SAME as 3.0.

### tz(), timezone()

The format is SAME as 3.0.

### fn(), full_name(), fullname()

The format is SAME as 3.0.

### nickname()

The format is SAME as 3.0.

### bday(), birthday()

The format is SAME as 3.0.

### anniversary()

The date of marriage, or equivalent, of the object the vCard represents.
It's the new method from 4.0.

### gender()

To specify the components of the sex and gender identity of the object the vCard represents.
It's the new method from 4.0.

### source()
  
The format is SAME as 3.0.

### lang()

To specify the language(s) that may be used for contacting the entity associated with the vCard.
It's the new method from 4.0.

### geo(), prodid(), key(), uid(), sound()

The format is SAME as 3.0.

### impp(), xml(), member(), fburl(), caladruri(), caluri()

I don't think they are so popular paramater, but here are the methods!
They are the new methods from 4.0.

## aroud UTF-8

If you want to send precisely the vCard with UTF-8 characters to the **ALMOST** of smartphones, Use 3.0.
It seems to be TOO EARLY to use 4.0.

```
## for under perl-5.12.5
This module uses \P{ascii} in regexp so You have to use 5.12.5 and later.  
And this module uses Data::Validate::URI and it has bug on 5.8.x. so I can't support them.  

## SEE ALOSO
[README.md](https://github.com/worthmine/Text-vCard-Precisely/blob/master/README.md)
[RFC 6350](https://tools.ietf.org/html/rfc6350)
## AUTHOR

[Yuki Yoshida (worthmine)](https://github.com/worthmine)
