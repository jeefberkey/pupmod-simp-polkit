require 'spec_helper'

describe 'polkit::authorization::basic_policy' do
  supported_os = on_supported_os.delete_if { |e| e =~ /-6-/ } #TODO do this right
  supported_os.each do |os, facts|
  # on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'authorize group to do an action' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :result    => 'yes',
          :action_id => 'an.action',
          :group     => 'developers',
        }}
        it { is_expected.to create_polkit__authorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
// This file is managed by Puppet
polkit.addRule(function(action, subject) {
  if ((action.id == 'an.action') && subject.isInGroup('developers')) {
      return polkit.Result.YES;
    }
  }
});
          EOF
        }) }
      end

    end
  end
end
