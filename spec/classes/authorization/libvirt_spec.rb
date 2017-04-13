require 'spec_helper'

describe 'polkit::authorization::libvirt' do
  supported_os = on_supported_os.delete_if { |e| e =~ /6/ } #TODO do this right
  supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with minimal parameters' do
        let(:params) {{
          :ensure => 'present',
          :group  => 'administrators'
        }}
        it { is_expected.to create_class('polkit::authorization::libvirt') }
      end

      if facts[:os][:release][:major].to_i == 6
        next
        # context 'on EL6' do
        #   it { is.expected_to compile.and_raise_error(/EL6 does not support javascript/) }
        # end
      else
        context 'on EL7' do
          let(:params) {{
            :ensure => 'present',
            :group  => 'administrators'
          }}
          it { is_expected.to create_polkit__authorization__rule('Allow users to use libvirt').with({
            :ensure   => 'present',
            :priority => 50,
            :rulesd   => '/etc/polkit-1/rules.d',
            :content  => <<-EOF
// Allow members of the `administrators` group to use libvirt with qemu:///system
polkit.addRule(function(action, subject) {
  if (action.id == "org.libvirt.unix.manage") {
    if (subject.local && subject.active && subject.isInGroup("administrators")) {
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
end
