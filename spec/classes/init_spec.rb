require 'spec_helper'

describe 'polkit' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('polkit') }
        it { is_expected.to contain_package('polkit').with_ensure('installed') }

        if facts[:os][:release][:major].to_i >= 7
          it { is_expected.to create_polkit__authorization__rule('Set administrators group to a policykit administrator').with({
            :ensure => 'present',
            :priority => 10,
            :content => /unix-group:administrators/
          }) }
        end
      end

      context 'with set_admin_group => false' do
        let(:params) {{ :set_admin_group => false }}
        it { is_expected.to create_polkit__authorization__rule('Set administrators group to a policykit administrator').with({
          :ensure => 'absent',
        }) }
      end

      context 'with admin_group => coolkids' do
        let(:params) {{ :admin_group => 'coolkids' }}
        if facts[:os][:release][:major].to_i >= 7
          it { is_expected.to create_polkit__authorization__rule('Set administrators group to a policykit administrator').with({
            :ensure => 'present',
            :priority => 10,
            :content => /unix-group:coolkids/
          }) }
        end
      end

    end
  end
end
