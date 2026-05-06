package Text::vCard::Precisely::V3::Node::Email;

use Carp;

use Moo;
use Type::Utils qw(declare coerce enum from via as where message);
use Types::Standard qw(Str Bool ArrayRef);
use Email::Valid;

extends 'Text::vCard::Precisely::V3::Node';

my $EmailAddress = declare 'EmailAddress', as Str,
    where { Email::Valid->address($_) },
    message {"The email address you provided, $_, was not valid"};

has name    => ( is => 'ro', default => 'EMAIL', isa => Str );
has content => ( is => 'ro', default => '',      isa => $EmailAddress );

has preferred => ( is => 'rw', default => 0, isa => Bool );

my $EmailType = declare 'EmailType', as Str, where {
    m/^(?:work|home)$/is or    # common
        m/^(?:contact|acquaintance|friend|met|co-worker|colleague|co-resident|neighbor|child|parent|sibling|spouse|kin|muse|crush|date|sweetheart|me|agent|emergency)$/is # Are those correct?
}, message {"The EmailType you provided, $_, was not supported in 'EmailTypes'"};

my $EmailTypes = declare 'EmailTypes', as ArrayRef[$EmailType];
coerce $EmailTypes, from Str, via { [$_] };
has types => ( is => 'rw', isa => $EmailTypes, default => sub { [] }, coerce => 1 );

sub as_string {
    my ($self) = @_;
    my @lines = $self->name() || croak "Empty name";
    push @lines, 'ALTID=' . $self->altID() if $self->can('altID') and $self->altID();
    push @lines, 'PID=' . join ',', @{ $self->pid() } if $self->can('pid') and $self->pid();

    my @types = map {uc} grep {length} @{ $self->types() };
    push @types, 'PREF' if $self->preferred();
    my $types = 'TYPE="' . join( ',', @types ) . '"' if @types;
    push @lines, $types if $types;

    my $string = join( ';', @lines ) . ':' . $self->content();
    return $self->fold( $string, -force => 1 );
}

no Moo;

1;
