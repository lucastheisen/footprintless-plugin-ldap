use strict;
use warnings;

package Footprintless::Plugin::Ldap::Command::ldap::backup;

# ABSTRACT: backup an ldap directory
# PODNAME: Footprintless::Plugin::Ldap::Command::ldap::backup;

use parent qw(Footprintless::App::Action);

use Carp;
use Footprintless::App -ignore;
use Log::Any;

my $logger = Log::Any->get_logger();

sub execute {
    my ($self, $opts, $args) = @_;

    $logger->info('Performing backup...');
    $self->{footprintless}->ldap_command_helper()
        ->backup($self->{ldap}, $self->{file}, %{$self->{options}});

    if ($opts->{rotating}) {
        require File::Copy;
        foreach my $index (reverse(1 .. $opts->{rotating})) {
            my $index_file = $self->{rotating_file} . "_$index";
            if (-f $index_file) {
                if ($index == $opts->{rotating}) {
                    unlink($index_file);
                }
                else {
                    File::Copy::move($index_file, 
                        $self->{rotating_file} .  "_" . ($index + 1));
                }
            }
        }
        File::Copy::move($self->{rotating_file}, $self->{rotating_file} . "_1");
        File::Copy::move($self->{file}, $self->{rotating_file});
        chmod(0660, $self->{rotating_file});
    }

    $logger->info('Done!');
}

sub opt_spec {
    return (
        ['attr=s@', 'attributes to include'],
        ['base=s', 'base dn'],
        ['filter=s', 'filter'],
        ['file=s', 'output file'],
        ['rotating=i', 'number of backups to keep'],
        ['scope=s', 'search scope'],
        ['set-password=s', 'replaces all passwords']
    );
}

sub usage_desc {
    return 'fpl ldap LDAP_COORD backup %o';
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    eval {
        $self->{ldap} = $self->{footprintless}
            ->ldap($self->{coordinate});
    };
    $self->usage_error("invalid coordinate [$self->{coordinate}]: $@") if ($@);

    if ($opts->{rotating}) {
        $self->usage_error('--file required when using --rotating') 
            unless ($opts->{file});
        $self->{rotating_file} = $opts->{file};
        my ($volume, $directory, $filename) = 
            File::Spec->splitpath($self->{rotating_file});
        $self->{file} = File::Spec->catfile($directory, "._TEMP_$filename");
    }
    else {
        $self->{file} = $opts->{file} || \*STDOUT;
    }

    $self->{options} = { 
        attrs => $opts->{attr} || ['*', '+'],
        filter => $opts->{filter} || '(objectClass=*)',
        scope => $opts->{scope} || 'sub',
        ($opts->{base} ? (base => $opts->{base}) : ()),
        ($opts->{set_password} ? (set_password => $opts->{set_password}) : ()),
    };
}

1;

__END__

=for Pod::Coverage execute opt_spec usage_desc validate_args
