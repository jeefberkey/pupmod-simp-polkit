# Add a rule file containing javascript Polkit configuration to the system
#
# @param ensure Create or destroy the rules file
#
# @param content An arbitrary string of javascript polkit configuration
#
# @param action_id The polkit action to operate on
#
#   * A list of available actions can be found by running `pkaction`
#
# @param priority Priority of the file to be created
#
# @param rulesd Location of the poklit rules directory
#
class polkit::authorization::libvirt (
  Enum['present','absent'] $ensure,
  String                   $group,
  Integer[0,99]            $priority,
  Stdlib::AbsolutePath     $rulesd,
) {
  if $facts['os']['release']['major'] == '6' {
    fail('The version of Polkit available on EL6 does not support javascript configuration')
  }

  $content = @("EOF")
  // Allow members of the `${group}` group to use libvirt with qemu:///system
  polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage") {
      if (subject.local && subject.active && subject.isInGroup("${group}")) {
        return polkit.Result.YES;
      }
    }
  });
  |EOF

  polkit::authorization::rule { 'Allow users to use libvirt':
    ensure   => $ensure,
    priority => $priority,
    rulesd   => $rulesd,
    content  => $content,
  }

}