require 'spec_helper'

class Hash
  def method_missing(mn,*a)
    mn = mn.to_s
    if mn =~ /=$/
      super if a.size > 1
      self[mn[0...-1]] = a[0]
    else
      #super unless has_key?(mn) and a.empty?
      self[mn] || self[mn.to_sym]
    end
  end
end

describe "Provisioner" do

  # Vagrant config for a single host
  let(:e) { Vagrant::Config::ErrorRecorder.new }
  let(:config) {
    c = Vagrant::Provisioners::Ansible::Config.new
    c.playbook = "playbook"
    c.hosts    = "hosts"
    c
  }
  let(:env) {
    {:vm  =>
      {:config =>
        {:vm =>
          {:forwarded_ports => [{:guestport => 2222, :hostport => 22}]},
         :ssh => {:host => "localhost", :guest_port => 2222, :username => 'sshuser'}
        },
        :env => {:default_private_key_path => "private_key_path"}
      }
    }
  }
  let(:provisioner) { Vagrant::Provisioners::Ansible.new(env, config) }
  let(:filemock) {
    filemock = double(:tempfile)
    filemock.should_receive(:write).with("[#{config.hosts}]\n")
    filemock.should_receive(:write).with("localhost:22\n")
    filemock.should_receive(:write).with("\n")
    filemock.should_receive(:fsync)
    filemock.should_receive(:close)
    filemock.should_receive(:path).and_return("path")
    filemock.should_receive(:unlink)
    filemock
  }

  it "should provide the correct config class" do
    Vagrant::Provisioners::Ansible.config_class.should == Vagrant::Provisioners::Ansible::Config
  end

  it "should write the correct inventory to a temp file for a single host" do
    Tempfile.stub(:new).and_return(filemock)
    provisioner.with_inventory_file({:host => "localhost", :guest_port => 2222}) do |path|
      path.should == "path"
    end
  end

  it "should call ansible-playboot with the right arguments" do
    Tempfile.stub(:new).and_return(filemock)
    provisioner.should_receive(:safe_exec).with(
          "ansible-playbook",
          "--user=sshuser",
          "--inventory-file=path",
          "--private-key=private_key_path",
          "playbook")
    provisioner.provision!
  end

  it "should call ansible-playboot with the given inventory file" do
    config.inventory_file = "/tmp/ansible_hosts"
    provisioner.should_receive(:safe_exec).with(
      "ansible-playbook",
      "--user=sshuser",
      "--inventory-file=/tmp/ansible_hosts",
      "--private-key=private_key_path",
      "playbook")
    provisioner.provision!
  end

  it "should pass multiple extra-vars", :focus =>true do
    config.inventory_file = "/tmp/ansible_hosts"
    config.options  = '--extra-vars="user=vagrant test=true"', '-vv'
    provisioner = Vagrant::Provisioners::Ansible.new(env, config)
    provisioner.should_receive(:safe_exec).with(
      "ansible-playbook",
      "--user=sshuser",
      "--inventory-file=/tmp/ansible_hosts",
      "--private-key=private_key_path",
      '--extra-vars="user=vagrant test=true"',
      '-vv',
      "playbook")
    provisioner.provision!
  end

  # Vagrant config for multiple hosts
  let(:multiple_hosts_config) {
    c = Vagrant::Provisioners::Ansible::Config.new
    c.playbook = "playbook"
    c.hosts    = ["host1", "host2"]
    c
  }
  let(:multiple_hosts_env) {
    {:vm  =>
      {:config =>
        {:vm =>
          {:forwarded_ports => [{:guestport => 2222, :hostport => 22}]},
         :ssh => {:host => "localhost", :guest_port => 2222, :username => 'sshuser'}
        },
        :env => {:default_private_key_path => "private_key_path"}
      }
    }
  }
  let(:multiple_hosts_provisioner) { Vagrant::Provisioners::Ansible.new(multiple_hosts_env, multiple_hosts_config) }
  let(:multiple_hosts_filemock) {
    filemock = double(:multiple_hosts_tempfile)
    filemock.should_receive(:write).with("[#{multiple_hosts_config.hosts[0]}]\n")
    filemock.should_receive(:write).with("localhost:22\n")
    filemock.should_receive(:write).with("\n")
    filemock.should_receive(:write).with("[#{multiple_hosts_config.hosts[1]}]\n")
    filemock.should_receive(:write).with("localhost:22\n")
    filemock.should_receive(:write).with("\n")
    filemock.should_receive(:fsync)
    filemock.should_receive(:close)
    filemock.should_receive(:path).and_return("path")
    filemock.should_receive(:unlink)
    filemock
  }

  it "should write the correct inventory to a temp file for multiple hosts" do
    Tempfile.stub(:new).and_return(multiple_hosts_filemock)
    multiple_hosts_provisioner.with_inventory_file({:host => "localhost", :guest_port => 2222}) do |path|
      path.should == "path"
    end
  end

end
