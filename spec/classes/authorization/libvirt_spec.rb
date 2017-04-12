require 'spec_helper'

describe 'polkit::authorization::libvirt' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with minimal parameters' do
        let(:params) {{
          :ensure => 'present',
          :group  => 'administrators'
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('polkit::authorization::libvirt') }
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
