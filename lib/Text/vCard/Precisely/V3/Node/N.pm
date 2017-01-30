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
    push @lines, 'CHARSET=' . $self->charset if $self->charset;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'LANGUAGE=' . $self->language if $self->language;
    push @lines, 'SORT-AS=' . $self->sort_as if $self->sort_as;

    ( my $family        = $self->family     || $self->value->[0] || '' ) =~ s/([,;\\])/\\$1/sg;
    ( my $given         = $self->given      || $self->value->[1] || '' ) =~ s/([,;\\])/\\$1/sg;
    ( my $additional    = $self->additional || $self->value->[2] || '' ) =~ s/([,;\\])/\\$1/sg;
    ( my $prefixes      = $self->prefixes   || $self->value->[3] || '' ) =~ s/([,;\\])/\\$1/sg;
    ( my $suffixes      = $self->suffixes   || $self->value->[4] || '' ) =~ s/([,;\\])/\\$1/sg;

    my $line = join(';', @lines ) . ':' . join ';',
        $family,
        $given,
        $additional,
        $prefixes,
        $suffixes;
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
