require "spec_helper"
require "serverspec"

package = "netplan.io"
config_dir = "/etc/netplan"
config_mode = 644
default_user = "root"
default_group = "root"

config_files = ["60-bridge.yaml"]

describe package(package) do
  it { should be_installed }
end

config_files.each do |config|
  describe file("#{config_dir}/#{config}") do
    it { should exist }
    it { should be_file }
    it { should be_mode config_mode }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
    its(:content_as_yaml) { should include("network" => include("version" => 2)) }
  end
end

describe command("brctl show br0") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^br0\s+\S+\s+no\s+eth1/) }
  its(:stdout) { should match(/^\s+eth2/) }
end

describe command("ip addr") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\d+:\s+br0:.*,UP.*state UP/) }
  its(:stdout) { should match(/^\d+:\s+eth1:.*,UP.*br0 state UP/) }
  its(:stdout) { should match(/^\d+:\s+eth2:.*,UP.*br0 state UP/) }
end
