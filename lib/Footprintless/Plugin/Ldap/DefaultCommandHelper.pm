use strict;
use warnings;

package Footprintless::Plugin::Ldap::DefaultCommandHelper;

# ABSTRACT: The default implementation of command helper for ldap
# PODNAME: Footprintless::Plugin::Ldap::DefaultCommandHelper

use Carp;
use Footprintless::Plugin::Ldap::ApacheDsLdapUtil;

sub new {
    return bless({}, shift)->_init(@_);
}

sub allowed_destination {
    my ($self, $coordinate) = @_;
    return 1;
}

sub backup {
    my ($self, $ldap, $file, %options) = @_;
    Footprintless::Plugin::Ldap::ApacheDsLdapUtil::backup(
        $ldap, $file, %options);
}

sub copy {
    my ($self, $ldap_from, $ldap_to, %options) = @_;
    Footprintless::Plugin::Ldap::ApacheDsLdapUtil::copy(
        $ldap_from, $ldap_to, %options);
}

sub copy_user {
    my ($self, $ldap_from, $ldap_to, %options) = @_;
    Footprintless::Plugin::Ldap::ApacheDsLdapUtil::copy_user(
        $ldap_from, $ldap_to, %options);
}

sub _init {
    my ($self, $footprintless) = @_;
    $self->{footprintless} = $footprintless;
    return $self;
}

sub locate_file {
    my ($self, $file) = @_;
    croak("file not found [$file]") unless (-f $file);
    return $file;
}

sub restore {
    my ($self, $ldap, $file, %options) = @_;
    Footprintless::Plugin::Ldap::ApacheDsLdapUtil::restore(
        $ldap, $file, %options);
}

1;

__END__

=constructor new($footprintless)

Creates a new instance.

=method allowed_destination($coordinate)

Returns a I<truthy> value if C<$coordinate> is allowed as a destination.

=method backup($ldap, $file, %options)

See L<Footprintless::Plugin::Ldap::ApacheDsLdapUtil>.

=method copy($ldap_from, $ldap_to, %options)

See L<Footprintless::Plugin::Ldap::ApacheDsLdapUtil>.

=method copy_user($ldap_from, $ldap_to, %options)

See L<Footprintless::Plugin::Ldap::ApacheDsLdapUtil>.

=over 4

=back

=method locate_file($file)

Returns the path to C<$file>.  Croaks if the file cannot be found.

=method restore($ldap, $file, %options)

See L<Footprintless::Plugin::Ldap::ApacheDsLdapUtil>.

=over 4

=back

=head1 SEE ALSO

Footprintless::Plugin::Ldap
Footprintless::Plugin::Ldap::Ldap
Footprintless::Plugin::Ldap::ApacheDsLdapUtil
