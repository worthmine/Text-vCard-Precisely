package Text::vCard::Precisely::V3::Node::N;
use Carp;
use Moose;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'N', isa => 'Str' );
has [qw( family given additional prefixes suffixes )] => ( is => 'rw', isa => 'Str' );

has value => ( is => 'rw', default => sub{[ (undef) x 5 ]}, isa => 'ArrayRef[Str]|ArrayRef[Undef]' );

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
