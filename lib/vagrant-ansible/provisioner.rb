require 'tempfile'

module Vagrant
  module Provisioners
    class Ansible < Base
      VERSION = '0.0.2'
      include Util::SafeExec

      class Config < Vagrant::Config::Base
        attr_accessor :playbook
        attr_accessor :hosts
        attr_accessor :inventory_file
        attr_accessor :ask_sudo_pass
        attr_accessor :sudo

        def initialize

        end

        def validate(env, errors)
          # Validate that the parameters are properly set
          if playbook.nil?
            errors.add(I18n.t("vagrant.provisioners.ansible.no_playbook"))
          end
          if hosts.nil? and inventory_file.nil?
            errors.add(I18n.t("vagrant.provisioners.ansible.no_hosts"))
          end
        end
      end

      def self.config_class
        Config
      end

      # This methods yield the path to a temporally created inventory
      # file.
      def with_inventory_file(ssh)
        if not config.inventory_file.nil?
          yield config.inventory_file
        else
          begin
            forward = env[:vm].config.vm.forwarded_ports.select do |x|
              x[:guestport] == ssh.guest_port
            end.first[:hostport]
            file = Tempfile.new('inventory')
            file.write("[#{config.hosts}]\n")
            file.write("#{ssh.host}:#{forward}")
            file.fsync
            file.close
            yield file.path
          ensure
            file.unlink
          end
        end
      end

      def provision!
        ssh = env[:vm].config.ssh

        with_inventory_file(ssh) do |inventory_file|
          options = %W[--user=#{ssh.username}
                       --inventory-file=#{inventory_file}
                       --private-key=#{env[:vm].env.default_private_key_path}]

          options << "--ask-sudo-pass" if config.ask_sudo_pass
          options << "--sudo" if config.sudo

          cmd = (%w(ansible-playbook) << options << config.playbook).join(' ')

          puts cmd
          safe_exec cmd
        end
      end
    end
  end
end