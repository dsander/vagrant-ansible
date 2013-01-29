require 'spec_helper'

describe "Config" do
  
  describe "validating the config" do
    let(:e) { Vagrant::Config::ErrorRecorder.new }
    let(:config) { Vagrant::Provisioners::Ansible::Config.new }

    it "should require the playbook and hosts config value" do
      config.validate({}, e)
      e.errors.length.should == 2
    end

    it "should not add any errors if the playbook and hosts are configured" do
      config.playbook = "test"
      config.hosts    = "all"
      config.validate({}, e)
      e.errors.length.should == 0
    end

    it "should not add any errors if the hosts is an array" do
      config.playbook = "test"
      config.hosts    = ["webservers", "databases"]
      config.validate({}, e)
      e.errors.length.should == 0
    end
  end
end
