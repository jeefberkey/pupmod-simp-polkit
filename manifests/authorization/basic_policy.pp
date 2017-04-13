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
  String                   $action_id,
  Polkit::Result           $result,
  Optional[String]         $group     = undef,
  Optional[String]         $user      = undef,
  Boolean                  $local     = false,
  Boolean                  $active    = false,
  Optional[String]         $condition = undef,
  Integer[0,99]            $priority  = 51,
  Stdlib::AbsolutePath     $rulesd    = '/etc/polkit-1/rules.d',
) {
  if !$condition and (!$user and !$group) {
    fail('One of $user or $group must be specified')
  }

  $_opts = {
    'group'  => $group,
    'user'   => $user,
    'local'  => $local,
    'active' => $active,
  }
  $_condition = $condition ? {
    String  => $condition,
    default => polkit::condition($action_id, $_opts)
  }

  $_content = @("EOF")
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
    content  => $_content,
  }

}