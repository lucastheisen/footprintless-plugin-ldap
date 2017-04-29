use strict;
use warnings;

package Footprintless::Plugin::Ldap::Command::ldap::restore;

# ABSTRACT: restore an ldap directory
# PODNAME: Footprintless::Plugin::Ldap::Command::ldap::restore;

use parent qw(Footprintless::App::Action);

use Carp;
use Footprintless::App -ignore;
use Log::Any;

my $logger = Log::Any->get_logger();

sub execute {
    my ($self, $opts, $args) = @_;

    $logger->info('Performing restore...');
    $self->{command_helper}
        ->restore($self->{ldap}, $self->{file}, %{$self->{options}});

    $logger->info('Done!');
}

sub opt_spec {
    return (
        ['base=s', 'base dn'],
        ['filter=s', 'filter'],
        ['file=s', 'input file'],
        ['scope=s', 'search scope'],
    );
}

sub usage_desc {
    return 'fpl ldap LDAP_COORD restore %o';
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    $self->{command_helper} = $self->{footprintless}->ldap_command_helper();
    croak("destination [$self->{coordinate}] not allowed")
        unless $opts->{ignore_deny}
            || $self->{command_helper}->allowed_destination($self->{coordinate});

    eval {
        $self->{ldap} = $self->{footprintless}
            ->ldap($self->{coordinate});
    };
    $self->usage_error("invalid coordinate [$self->{coordinate}]: $@") if ($@);

    $self->{file} = $opts->{file} || *STDIN{IO};

    $self->{options} = { 
        filter => $opts->{filter} || '(objectClass=*)',
        scope => $opts->{scope} || 'sub',
        ($opts->{base} ? (base => $opts->{base}) : ())
    };
}

1;

__END__

=for Pod::Coverage execute opt_spec usage_desc validate_args
