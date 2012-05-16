#$:.push File.expand_path("./lib")
require 'vagrant-ansible'

Vagrant::Config.run do |config|
  config.vm.box     = "oneiric32_base"
  config.vm.box_url = "http://files.travis-ci.org/boxes/bases/oneiric32_base.box"

  config.vm.provision :ansible do |ansible|
    # point Vagrant at the location of your playbook you want to run
    ansible.playbook = "../ansible-playbooks/nginx-ubuntu.yml"

    # the Vagrant VM will be put in this host group change this should
    # match the host group in your playbook you want to test
    ansible.pattern = "web-servers"

end