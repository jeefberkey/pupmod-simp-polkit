# Generate a condition for a policykit rule
Puppet::Functions.create_function(:'polkit::condition') do
  dispatch :condition do
    param 'String', :action_id
    param "Struct[{
      Optional[group]  => Optional[String],
      Optional[user]   => Optional[String],
      Optional[local]  => Boolean,
      Optional[active] => Boolean,
    }]", :opts
    # param 'Hash[Variant[String,Boolean],Variant[String,Boolean,Undef],0,4]', :opts
    # optional_param 'String', :group
    # optional_param 'String', :user
    # optional_param 'Boolean', :local
    # optional_param 'Boolean', :active

    return_type 'String'
  end

  def condition(action_id, opts)
    if opts['user'].nil? && opts['group'].nil?
      fail('polkit::condition: One of `user` or `group` must be specified')
    end

    cond = []
    cond << "(action.id == '#{action_id}')"
    cond << "subject.user == '#{opts['user']}'"     if opts['user']
    cond << "subject.isInGroup('#{opts['group']}')" if opts['group']
    cond << 'subject.local'                         if opts['local']
    cond << 'subject.active'                        if opts['active']
    cond.join(' && ')
  end
end