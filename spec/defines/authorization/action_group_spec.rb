require 'spec_helper'

describe 'polkit::authorization::basic_policy' do
  supported_os = on_supported_os.delete_if { |e| e =~ /6/ } #TODO do this right
  supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'authorize group to do an action' do
        let(:title) { 'test' }
        let(:params) {{
          :ensure    => 'present',
          :group     => 'developers',
          :action_id => 'some.jank'
        }}
        it { is_expected.to create_polkit__autorization__rule('test').with({
          :ensure => 'present',
          :content => <<-EOF
          
          EOF
        }) }
      end

    end
  end
end