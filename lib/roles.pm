package roles;
# ABSTRACT: A simple pragma for composing roles.

use strict;
use warnings;

use MOP         ();
use Devel::Hook ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub import {
    shift;
    my $role = caller;
    my @roles = @_;

    {
        no strict   'refs';
        no warnings 'once';
        push @{ $role.'::DOES' } => @roles;
    }

    Devel::Hook->push_UNITCHECK_hook(sub {
        my $meta;
        {
            no strict   'refs';
            no warnings 'once';
            if ( @{ $role.'::ISA' } ) {
                $meta = MOP::Class->new( $role )
            }
            else {
                $meta = MOP::Role->new( $role )
            }
        }

        MOP::Util::APPLY_ROLES(
            $meta,
            [ $meta->roles ],
            to => ($meta->isa('MOP::Class') ? 'class' : 'role')
        );
    });
}

1;

__END__

=pod

=cut
