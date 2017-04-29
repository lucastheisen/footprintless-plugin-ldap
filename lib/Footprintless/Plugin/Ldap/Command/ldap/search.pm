use strict;
use warnings;

package Footprintless::Plugin::Ldap::Command::ldap::search;

# ABSTRACT: search an ldap directory
# PODNAME: Footprintless::Plugin::Ldap::Command::ldap::search;

use parent qw(Footprintless::App::Action);

use Footprintless::App -ignore;
use Log::Any;

my $logger = Log::Any->get_logger();

sub execute {
    my ($self, $opts, $args) = @_;

    $logger->info('Performing search...');
    $logger->debugf('options=%s', $self->{options});
    eval {
        $self->{ldap}->connect()->bind();
        my @entries = $self->{ldap}->search_for_list($self->{options});
        my $index = 0;
        foreach my $entry (@entries) {
            print("------------------------------------------------------------------------\n");
            print("Search Result Entry $index\n");
            $entry->dump();
            $index++;
        }
        print("------------------------------------------------------------------------\n");
        print("found $index matche(s).\n");
    };
    my $error = $@;
    eval{$self->{ldap}->disconnect()};
    die($error) if ($error);
}

sub opt_spec {
    return (
        ['attr=s@', 'attribute to include'],
        ['base=s', 'base dn'],
        ['filter=s', 'filter'],
        ['scope=s', 'search scope'],
    );
}

sub usage_desc {
    return 'fpl ldap LDAP_COORD search %o';
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    eval {
        $self->{ldap} = $self->{footprintless}
            ->ldap($self->{coordinate});
    };
    $self->usage_error("invalid coordinate [$self->{coordinate}]: $@") if ($@);

    $self->{options} = { 
        attrs => $opts->{attr} || ['*', '+'],
        filter => $opts->{filter} || '(objectClass=*)',
        scope => $opts->{scope} || 'one',
        ($opts->{base} ? (base => $opts->{base}) : ()),
    };
}

1;

__END__

=for Pod::Coverage execute opt_spec usage_desc validate_args
