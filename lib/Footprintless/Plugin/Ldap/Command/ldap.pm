use strict;
use warnings;

package Footprintless::Plugin::Ldap::Command::ldap;

# ABSTRACT: Provides support for LDAP directories
# PODNAME: Footprintless::Plugin::Ldap::Command::ldap;

use parent qw(Footprintless::App::ActionCommand);

sub _actions {
    return (
        'backup' => 'Footprintless::Ldap::LdapPlugin::Command::ldap::backup',
        'copy-to' => 'Footprintless::Ldap::LdapPlugin::Command::ldap::copy_to',
        'copy-user-to' => 'Footprintless::Ldap::LdapPlugin::Command::ldap::copy_user_to',
        'restore' => 'Footprintless::Ldap::LdapPlugin::Command::ldap::restore',
        'search' => 'Footprintless::Ldap::LdapPlugin::Command::ldap::search'
    );
}

sub usage_desc {
    return 'fpl ldap LDAP_COORD ACTION';
}

1;

=head1 SYNOPSIS

    fpl ldap proj.env.ldap backup
    fpl ldap proj.env.ldap restore
    fpl ldap proj.env.ldap search

=head1 DESCRIPTION

Performs actions on an LDAP directory instance.

