require "spec_helper"
require "serverspec"

package = "openssh-portable"
service = "openssh"
config_dir = "/etc/ssh"
config_mode = 644
user = "sshd"
group = "sshd"
log_dir = "/var/log"
log_file = "#{log_dir}/messages"
default_user = "root"
default_group = "wheel"
log_owner = default_user
log_group = default_group
log_mode = 644
log_dir_owner = default_user
log_dir_group = default_group
log_dir_mode = 755
log_mode = 644
ports = []
extra_groups = %w[]
extra_packages = []

case os[:family]
when "openbsd"
  service = "sshd"
  package = nil
  ports = [22, 10_022]
when "freebsd"
  config_dir = "/usr/local/etc/ssh"
  ports = [22, 10_022]
when "ubuntu"
  service = "ssh"
  group = "nogroup"
  default_group = "root"
  package = "openssh-server"
  ports = [22, 10_022]
  log_file = "#{log_dir}/syslog"
  log_owner = "syslog"
  log_group = "adm"
  log_mode = 640
  log_dir_owner = default_user
  log_dir_group = "syslog"
  log_dir_mode = 775
when "redhat"
  ports = [22]
  default_group = "root"
  service = "sshd"
  package = "openssh-server"
  config_mode = 600
  log_owner = default_group
  log_group = default_group
  log_mode = 600
  log_dir_owner = default_group
  log_dir_group = default_group
  log_dir_mode = 755
end

config = "#{config_dir}/sshd_config"

if os[:family] != "openbsd"
  describe package(package) do
    it { should be_installed }
  end
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe user(user) do
  it { should belong_to_group group }
  extra_groups.each do |g|
    it { should belong_to_group g }
  end
end

describe file(config_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode config_mode }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/Managed by ansible/) }
  its(:content) { should match(/UseDNS no/) }
  its(:content) { should match(/Port \d+/) }
end

describe file(log_dir) do
  it { should be_directory }
  it { should be_mode log_dir_mode }
  it { should be_owned_by log_dir_owner }
  it { should be_grouped_into log_dir_group }
end

case os[:family]
when "openbsd"
  describe file("/etc/rc.conf.local") do
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^#{Regexp.escape("#{service}_flags=-4")}/) }
  end
when "redhat"
  describe file("/etc/sysconfig/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end
when "ubuntu"
  describe file("/etc/default/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d") do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
  end

  describe file("/etc/rc.conf.d/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe file(log_file) do
  it { should be_file }
  it { should be_owned_by log_owner }
  it { should be_grouped_into log_group }
  it { should be_mode log_mode }
end
