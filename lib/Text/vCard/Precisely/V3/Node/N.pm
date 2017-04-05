package Text::vCard::Precisely::V3::Node::N;

use Carp;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Text::vCard::Precisely::V3::Node';

my @order = qw( family given additional prefixes suffixes );

has name => (is => 'ro', default => 'N', isa => 'Str' );
has \@order => ( is => 'rw', isa => 'Str|Undef', default => undef );

subtype 'Values'
    => as 'ArrayRef[Maybe[Str]]'
    => where { scalar @$_ == 5 }
    => message {
        my $length = ref $_ eq'Array'? scalar @$_ : return ref $_;
        return "Unvalid length. the length of N->value must be 5. you provided:$length" };
coerce 'Values'
    => from 'ArrayRef[Maybe[Str]]'
    => via { my @value = @$_; $value[4] ||= ''; return \@value };
coerce 'Values'
    => from 'HashRef[Maybe[Str]]'
    => via {my @value = @$_{@order}; $value[4] ||= ''; return \@value };
coerce 'Values'
    => from 'Str'
    => via { my @value = split( /;/, $_ ); $value[4] ||= ''; return \@value };
has value => ( is => 'rw', default => sub{[ (undef) x 5 ]}, isa => 'Values', coerce => 1 );

override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
    push @lines, 'CHARSET=' . $self->charset if $self->charset;

    my @values = ();
    my $num = 0;
    map{ push @values, $self->_escape( $self->$_ || $self->value->[$num++] ) } @order;
    my $string = join(';', @lines ) . ':' . join ';', @values;
    return $self->fold( $string, -force => 1 );
};

__PACKAGE__->meta->make_immutable;
no Moose;

sub _length {
    my $self = shift;
    return scalar @{ $self->value };
}

#Alias
sub family_name {
    family(@_);
}

sub surname {
    family(@_);
}

sub given_name {
    given(@_);
}

sub additional_name {
    additional(@_);
}

sub honorific_prefixes {
    prefixes(@_);
}

sub honorific_suffixes {
    suffixes(@_);
}

1;
