use strict;
use warnings;

package Footprintless::Plugin::Ldap::Command::ldap::copy_user_to;

# ABSTRACT: copy an ldap user
# PODNAME: Footprintless::Plugin::Ldap::Command::ldap::copy_user_to;

use parent qw(Footprintless::App::Action);

use Carp;
use Footprintless::App -ignore;
use Log::Any;

my $logger = Log::Any->get_logger();

sub execute {
    my ($self, $opts, $args) = @_;

    $logger->info('Performing copy...');
    $self->{command_helper}
        ->copy_user($self->{ldap}, $self->{destination}, %{$self->{options}});
    $logger->info('Done!');
}

sub opt_spec {
    return (
        ['filter=s', 'filter'],
        ['email=s@', 'users email address'],
        ['set-password=s', 'replaces all passwords']
    );
}

sub usage_desc {
    return 'fpl ldap LDAP_COORD copy-user-to %o';
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    eval {
        $self->{ldap} = $self->{footprintless}
            ->ldap($self->{coordinate});
    };
    $self->usage_error("invalid coordinate [$self->{coordinate}]: $@") if ($@);

    my ($destination_coordinate) = @$args;
    $self->usage_error('destination coordinate required for copy') 
        unless ($destination_coordinate);
    $self->{command_helper} = $self->{footprintless}->ldap_command_helper();
    croak("destination [$destination_coordinate] not allowed")
        unless $opts->{ignore_deny}
            || $self->{command_helper}->allowed_destination($destination_coordinate);

    eval {
        $self->{destination} = $self->{footprintless}
            ->ldap($destination_coordinate);
    };
    $self->usage_error("invalid destination coordinate [$destination_coordinate]: $@")
        if ($@);

    $self->usage_error('email or filter required')
        unless ($opts->{filter} || $opts->{email});

    $self->{options} = { 
        attrs => ['*', '+'],
        scope => 'sub',
        ($opts->{filter} ? (filter => $opts->{filter}) : ()),
        ($opts->{email} ? (email_list => $opts->{email}) : (email_list => [])),
        ($opts->{set_password} ? (set_password => $opts->{set_password}) : ()),
    };
}

1;

__END__

=for Pod::Coverage execute opt_spec usage_desc validate_args
