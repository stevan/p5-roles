package roles;
# ABSTRACT: A simple pragma for composing roles.

use strict;
use warnings;

use MOP             ();
use Module::Runtime ();

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

sub import {
    shift;
    my $pkg   = caller(0);
    my $meta  = MOP::Util::get_meta( $pkg );
    my @roles = map Module::Runtime::use_package_optimistically( $_ ), @_;

    $meta->set_roles( @roles );

    MOP::Util::defer_until_UNITCHECK(sub {
        MOP::Util::compose_roles( MOP::Util::get_meta( $pkg ) )
    });
}

1;

__END__

=pod

=head1 SYNOPSIS

    package Eq {
        use strict;
        use warnings;

        sub equal_to;

        sub not_equal_to {
            my ($self, $other) = @_;
            not $self->equal_to($other);
        }
    }

    package Comparable {
        use strict;
        use warnings;

        use roles 'Eq';

        sub compare;

        sub equal_to {
            my ($self, $other) = @_;
            $self->compare($other) == 0;
        }

        sub greater_than {
            my ($self, $other) = @_;
            $self->compare($other) == 1;
        }

        sub less_than {
            my ($self, $other) = @_;
            $self->compare($other) == -1;
        }

        sub greater_than_or_equal_to {
            my ($self, $other) = @_;
            $self->greater_than($other) || $self->equal_to($other);
        }

        sub less_than_or_equal_to {
            my ($self, $other) = @_;
            $self->less_than($other) || $self->equal_to($other);
        }
    }

    package Printable {
        use strict;
        use warnings;

        sub to_string;
    }

    package US::Currency {
        use strict;
        use warnings;

        use roles 'Comparable', 'Printable';

        sub new {
            my ($class, %args) = @_;
            bless { amount => $args{amount} // 0 } => $class;
        }

        sub compare {
            my ($self, $other) = @_;
            $self->{amount} <=> $other->{amount};
        }

        sub to_string {
            my ($self) = @_;
            sprintf '$%0.2f USD' => $self->{amount};
        }
    }

=head1 DESCRIPTION

This is a very simple pragma which takes a list of roles as
package names, adds them to the C<@DOES> package variable
and then schedule for role composition to occur during the
next available UNITCHECK phase.

=cut
