# Set up PolicyKit
#
# Allows you to set up and manipulate PolicyKit objects
#
# @see http://www.freedesktop.org/software/polkit/docs/latest/ PolicyKit Documentation
#
# @param package_ensure The ensure status of packages
#
# @author Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class polkit (
  Polkit::PackageEnsure $package_ensure,
  Boolean               $set_admin_group,
  String                $admin_group,
) {
  package { 'polkit': ensure => $package_ensure }

  $_ensure = $set_admin_group ? {
    true    => 'present',
    default => 'absent'
  }
  $_content = @("EOF")
    polkit.addAdminRule(function(action, subject) {
      return ["unix-group:${admin_group}"];
    });
    |EOF

  polkit::authorization::rule { 'Set administrators group to a policykit administrator':
    ensure   => $_ensure,
    priority => 10,
    content  => $_content,
  }
}
