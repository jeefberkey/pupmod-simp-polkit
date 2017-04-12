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
class polkit::authorization::action_group (
  Enum['present','absent'] $ensure,
  String                   $group     = $name,
  Integer[0,99]            $priority  = 50,
  Stdlib::AbsolutePath     $rulesd    = '/etc/polkit-1/rules.d',
  Optional[Variant[String,Array[String]]] $action_id = undef,
) {

  $_action_id = $action_id ? {
    default => "action.id == '${action_id}'",
    Array   => $action_id.map { |$action| "action.id == '${action}' ||" }
  }

  $content = @("EOF")
  // Allow members of the `virshusers` group to use virsh with qemu:///system
  polkit.addRule(function(action, subject) {
    if (${_action_id}) {
      if (subject.local && subject.active && subject.isInGroup("${group}")) {
        return polkit.Result.YES;
      }
    }
  });
  |EOF

  polkit::authorization::rule { $name:
    ensure   => $ensure,
    priority => $priority,
    rulesd   => $rulesd,
    content  => $content,
  }

}