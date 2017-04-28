# NAME
Text::vCard::Precisely - Read, Write and Edit the vCards 3.0 and/or 4.0 precisely

## SYNOPSIS

```
my $vc = Text::vCard::Precisely->new();
# or now you can write like bellow if you want to use 4.0:
#my $vc = Text::vCard::Precisely->new( version => '4.0' );

$vc->n([ 'Gump', 'Forrest', , 'Mr', '' ]);
$vc->fn( 'Forrest Gump' );

use GD;
use MIME::Base64;

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

A vCard is a digital business card. vCard and [Text::vFile::asData](https://github.com/richardc/perl-text-vfile-asdata) provide an API for parsing vCards.

This module is forked from [Text::vCard](https://github.com/ranguard/text-vcard) because some reason bellow:

- Text::vCard **doesn't provide** full methods based on [RFC2426](https://tools.ietf.org/html/rfc2426)  
- Mac OS X and iOS can't parse vCard4.0 with UTF-8 precisely. they cause some Mojibake
- Android 4.4.x can't parse vCard4.0
- I wanted to learn Moose, of course 

To handle an address book with several vCard entries in it, start with
[Text::vFile::asData](https://github.com/richardc/perl-text-vfile-asdata) and then come back to this module.

Note that the vCard RFC requires version() and full_name().  This module does
not check or warn if these conditions have not been met.

## Constructors

### load_hashref($HashRef)

Accepts an HashRef that looks like below:


```
my $hashref = {
  N   => [ 'Gump', 'Forrest', '', 'Mr.', '' ],
  FN  => 'Forrest Gump',
  SORT_STRING => 'Forrest Gump',
  ORG => 'Bubba Gump Shrimp Co.',
  TITLE => 'Shrimp Man',
  PHOTO => { media_type => 'image/gif', value => 'http://www.example.com/dir_photos/my_photo.gif' },
  TEL => [
    { types => ['WORK','VOICE'], value => '(111) 555-1212' },
    { types => ['HOME','VOICE'], value => '(404) 555-1212' },
  ],
  ADR =>[{
    types       => ['work'],
    pref        => 1,
    extended    => 100,
    street      => 'Waters Edge',
    city        => 'Baytown',
    region      => 'LA',
    post_code   => '30314',
    country     => 'United States of America'
  },{
    types       => ['home'],
    extended    => 42,
    street      => 'Plantation St.',
    city        => 'Baytown',
    region      => 'LA',
    post_code   => '30314',
    country     => 'United States of America'
  }],
  URL => 'http://www.example.com/dir_photos/my_photo.gif',
  EMAIL => 'forrestgump@example.com',
  REV => '2008-04-24T19:52:43Z',
};
```

### load_file($file_name)

Accepts a file name 

### load_string($vCard)

Accepts a vCard string

## METHODS

### as_string()

Returns the vCard as a string.
You have to use Encode::encode_utf8() if your vCard is written in utf8

### as_file($filename)

Write data in vCard format to $filename.
Dies if not successful.

## SIMPLE GETTERS/SETTERS

These methods accept and return strings

### version()

returns Version number of the vcard.  Defaults to **'3.0'** and this method is **READONLY** 

### rev()

To specify revision information about the current vCard3.0

### sort_string()

To specify the family name, given name or organization text to be used for national-language-specific sorting of the FN, N and ORG
**This method will be DEPRECATED in vCard4.0** Use SORT-AS param instead of it. (Text::vCard::Precisely::V4 supports it)

## COMPLEX GETTERS/SETTERS

They are based on Moose with coercion.
So these methods accept not only ArrayRef[HashRef] but also ArrayRef[Str], single HashRef or single Str.
Read source if you were confused.

### n()

To specify the components of the name of the object the vCard represents.

### tel()

Accepts/returns an ArrayRef that looks like:

```
    [
      { type => ['work'], value => '651-290-1234', preferred => 1 },
      { type => ['home'], value => '651-290-1111' },
    ]
```

### adr(), address()

Accepts/returns an ArrayRef that looks like:

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

Accepts/returns an ArrayRef that looks like:

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

Accepts/returns an ArrayRef that looks like:

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

Accepts/returns an ArrayRef of URLs or Images: Even if they are raw image binary or text encoded in Base64, it does not matter.

Attention! Mac OS X and iOS **ignore** the description beeing URL.  
use Base64 encoding or raw image binary if you have to show the image you want.

### note()

To specify supplemental information or a comment that is associated with the vCard

### org(), title(), role(), categories()

To specify additional information for your jobs

### tz(), timezone()

To specify information related to the time zone of the object the vCard represents

### fn(), full_name(), fullname()

A person's entire name as they would like to see it displayed

### nickname()

To specify the text corresponding to the nickname of the object the vCard represents

### bday(), birthday()

To specify the birth date of the object the vCard represents

### source()
  
To identify the source of directory information contained in the content type

### geo(), prodid(), key(), uid(), sound()

I don't think they are so popular paramater, but here are the methods!

## aroud UTF-8

if you want to send precisely the vCard3.0 with UTF-8 characters to the **ALMOST** of smartphones, you have to set Charset param for each values like bellow:


```
ADR;CHARSET=UTF-8:201号室;マンション;通り;市;都道府県;郵便番号;日本

```

## for under perl-5.12.5

This module uses \P{ascii} in regexp so You have to use 5.12.5 and later.  
And this module uses Data::Validate::URI and it has bug on 5.8.x. so I can't support them.  

## SEE ALOSO

- [RFC 2426](https://tools.ietf.org/html/rfc2426)
- [RFC 2425](https://tools.ietf.org/html/rfc2425)
- [Text::vFile::asData](https://github.com/richardc/perl-text-vfile-asdata)
- [README-v4.md](https://github.com/worthmine/Text-vCard-Precisely/blob/master/README-v4.md)

## AUTHOR

[Yuki Yoshida(worthmine)](https://github.com/worthmine)
