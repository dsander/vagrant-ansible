## vagrant-ansible [![Build Status](https://secure.travis-ci.org/dsander/vagrant-ansible.png?branch=master)](http://travis-ci.org/dsander/vagrant-ansible)

https://github.com/dsander/vagrant-ansible

Vagrant-ansible is a provisioning plugin for [Vagrant](http://vagrantup.com/), that makes developing and testing [playbooks](http://ansible.github.com/playbooks.html) for [ansible](http://ansible.github.com/) easy.

vagrant-ansible was inspired by [Sous Chef](https://github.com/michaelklishin/sous-chef), and borrowed a bit of its documentation.


## How it works

With vagrant-ansible, you use Vagrant and a locally running VirtualBox VM to develop and test your playbooks. vagrant-ansible can use any collection of playbooks you are using for commercial projects or anything else.

With vagrant-ansible, you provision a locally running virtual machine managed by [Vagrant](http://vagrantup.com) in just one command. The process is
set up to shorten the feedback loop:

 * Modify your playbook plays (or templates/files in them)
 * Run provisioning
 * See and verify the result
 * Rinse and repeat

Once you are done with your playbooks, just push them to a source control repository or rsync them to your server. Then destroy VM environment
you were using in one command. Or just power off the VM and come back to work with it later.


## Dependencies

vagrant-ansible uses [Vagrant](http://vagrantup.com) and thus relies on [Virtual Box](http://virtualbox.org), you also need to have [ansible](http://ansible.github.com/gettingstarted.html) installed.


## Getting started with vagrant-ansible

First install [VirtualBox 4.1.x](https://www.virtualbox.org/wiki/Downloads):

* For [Mac OS X](http://dlc.sun.com.edgesuite.net/virtualbox/4.1.14/VirtualBox-4.1.14-77440-OSX.dmg)
* For [64-bit Linux distributions](http://download.virtualbox.org/virtualbox/4.1.14/)

Install ansible using the instructions on the ansible [homepage](http://ansible.github.com/gettingstarted.html)

Then install the vagrant gem:

    gem install vagrant --version ">= 1.0"

Then install the vagrant-ansible gem:

    gem install vagrant-ansible
    
If you installed vagrant using a package from [vagrant homepage](http://downloads.vagrantup.com/) you have to install vagrant-ansible via the vagrant command:

    vagrant gem install vagrant-ansible

Create a playbook or just clone an existing repository:

    git clone https://github.com/cocoy/ansible-playbooks.git

Now change into the ansible-playbooks directory and download the example Vagrantfile:

    cd ansible-playbooks
    wget https://raw.github.com/dsander/vagrant-ansible/master/Vagrantfile.sample -O Vagrantfile
    
Before you can run your playbook for the first time, you have to change the remote user to 'vagrant' in your playbook. This is necessary because the user specified in the playbook can not be overridden via command line options.

    ....
    - hosts: web-servers
      user: vagrant
    .....


Create a 32-bit Ubuntu virtual machine you will be developing playbooks in:

    vagrant up 

You will notice that the VM is automatically created, and nginx-ubuntu playbook is executed.


Have a look at your Vagrantfile, it will look like this:

    require 'vagrant-ansible'
    
    Vagrant::Config.run do |config|
      config.vm.box     = "oneiric32_base"
      config.vm.box_url = "http://files.travis-ci.org/boxes/bases/oneiric32_base.box"
      
      config.vm.customize ["modifyvm", :id, "--memory", "512"]

      # This is only necessary if your CPU does not support VT-x or you run virtualbox
      # inside virtualbox
      config.vm.customize ["modifyvm", :id, "--vtxvpid", "off"]

      # You can adjust this to the amount of CPUs your system has available
      config.vm.customize ["modifyvm", :id, "--cpus", "1"]

      config.vm.provision :ansible do |ansible|
        # point Vagrant at the location of your playbook you want to run
        ansible.playbook = "nginx-ubuntu.yml"

        # the Vagrant VM will be put in this host group change this should
        # match the host group in your playbook you want to test
        ansible.hosts = "web-servers"
      end
    end

You can now change the playbook to run, or create new tasks in it. To rerun, the provisioning just run:

    vagrant provision


Once provisioning finishes, ssh into the VM to check what the environment looks like:

    vagrant ssh

When you are done with your work on the cookbook you can either power off the VM to use it later with

    vagrant halt

or destroy it completely with

    vagrant destroy



## LICENSE:

(The MIT License)

Copyright (c) 2012 Dominik Sander

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
