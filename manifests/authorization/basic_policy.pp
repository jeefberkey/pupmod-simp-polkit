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
  Polkit::Result           $result,
  Optional[String]         $action_id = undef,
  Optional[String]         $group     = undef,
  Optional[String]         $user      = undef,
  Boolean                  $local     = false,
  Boolean                  $active    = false,
  Optional[String]         $condition = undef,
  Integer[0,99]            $priority  = 10,
  Stdlib::AbsolutePath     $rulesd    = '/etc/polkit-1/rules.d',
) {
  if !$condition {
    if (!$user and !$group) {
      fail('One of $user or $group must be specified')
    }
    if !$action_id {
      fail('If $condition is not specified, $action_id must be')
    }
  }
  if $facts['os']['release']['major'] == '6' {
    fail('The version of Polkit available on EL6 does not support javascript configuration')
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