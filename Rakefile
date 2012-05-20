# -*- ruby -*-

require 'rubygems'
if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
  require 'hoe'

  Hoe.plugin :git
  Hoe.plugin :gemspec
  Hoe.plugin :bundler
  Hoe.plugin :gemcutter
  Hoe.plugins.delete :rubyforge

  Hoe.spec 'vagrant-ansible' do
    developer('Dominik Sander', 'git@dsander.de')
    self.description ="Develop & test your ansible playbooks with Vagrant" 
    self.summary = "Vagrant-ansible is a provisioning plugin for Vagrant, that makes developing and testing playbooks for ansible easy."
    
    self.readme_file = 'README.md'
    self.history_file = 'CHANGELOG.md'
    self.extra_deps << ["vagrant"]
  end
end

task :default => :spec
task :test => :spec

# vim: syntax=ruby
