package Text::vCard::Precisely::V3::Node::Email;
use Carp;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Email qw/EmailAddress/;

extends 'Text::vCard::Precisely::V3::Node';

has name => (is => 'ro', default => 'EMAIL', isa => 'Str' );
has value => (is => 'ro', default => '', isa => EmailAddress );

subtype 'EmailType'
    => as 'Str'
    => where {
        m/^(:?work|home)$/so or #common
        m/^(:?contact|acquaintance|friend|met|co-worker|colleague|co-resident|neighbor|child|parent|sibling|spouse|kin|muse|crush|date|sweetheart|me|agent|emergency)$/so    # 本当にこれでいのか怪しい
    }
    => message { "The Email you provided, $_, was not supported in 'Type'" };

has types => ( is => 'rw', isa => 'ArrayRef[EmailType]', default => sub{[]} );


override 'as_string' => sub {
    my ($self) = @_;
    my @lines;
    push @lines, $self->name || croak "Empty name";
    push @lines, 'TYPE="' . join( ',', @{ $self->types } ). '"' if @{ $self->types  || [] } > 0;
    push @lines, 'ALTID=' . $self->altID if $self->altID;
    push @lines, 'PID=' . join ',', @{ $self->pid } if $self->pid;

    return join(';', @lines ) . ':' . $self->value;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
