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
define polkit::authorization::basic_policy (
  Enum['present','absent'] $ensure,
  Optional[String]         $condition = undef,
  Optional[String]         $action_id = undef,
  Optional[Polkit::Result] $result    = undef,
  Optional[String]         $group     = undef,
  Optional[String]         $user      = undef,
  Boolean                  $local     = false,
  Boolean                  $active    = false,
  Integer[0,99]            $priority  = 50,
  Stdlib::AbsolutePath     $rulesd    = '/etc/polkit-1/rules.d',
) {
  if !$condition (!$user and !$group) {
    fail('One of $user or $group must be specified')
  }

  $_condition_action = ["(action.id == '${action_id}')"]
  $_condition_user   = $user   ? { String  => ["subject.user == ${user}"],       default => [] }
  $_condition_group  = $group  ? { String  => ["subject.isInGroup('${group}')"], default => [] }
  $_condition_local  = $local  ? { Boolean => ['subject.local'],                 default => [] }
  $_condition_active = $active ? { Boolean => ['subject.active'],                default => [] }
  $_condition = ($_condition_user + $_condition_group + $_condition_local + $_condition_active).flatten.join(' && ')
  $content = @("EOF")
  // This file is managed by Puppet
  polkit.addRule(function(action, subject) {
    if (${_condition}) {
        return polkit.Result.${result.upcase};
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