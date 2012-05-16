require 'tempfile'

module Vagrant
  module Provisioners
    class Ansible < Base
      VERSION = '0.0.1'
      include Util::SafeExec
      class Config < Vagrant::Config::Base
        attr_accessor :playbook
        attr_accessor :pattern

        def initialize
          @upload_path = "/tmp/vagrant-shell"
        end

        def validate(env, errors)
          # Validate that the parameters are properly set
          if playbook.nil?
            errors.add(I18n.t("vagrant.provisioners.ansible.no_playbook"))
          end
          if pattern.nil?
            errors.add(I18n.t("vagrant.provisioners.ansible.no_pattern"))
          end
        end
      end

      def self.config_class
        Config
      end

      # This methods yield the path to a temporally created inventory
      # file.
      def with_inventory_file(ssh)
        begin
          forward = env[:vm].config.vm.forwarded_ports.select do |x| 
            x[:guestport] == ssh.guest_port
          end.first[:hostport]
          file = Tempfile.new('inventory')
          file.write("[#{config.pattern}]\n")
          file.write("#{ssh.host}:#{forward}")
          file.fsync
          file.close
          yield file.path
        ensure
          file.unlink
        end
      end

      def provision!
        require 'pp'

        ssh = env[:vm].config.ssh
        
 
        with_inventory_file(ssh) do |inventory_file|
          puts ["ansible-playbook",
                    "--user=#{ssh.username}", 
                    "--inventory-file=#{inventory_file}", 
                    "--private-key=#{env[:vm].env.default_private_key_path}",
                    config.playbook].join(' ')
          safe_exec("ansible-playbook",
                    "--user=#{ssh.username}", 
                    "--inventory-file=#{inventory_file}", 
                    "--private-key=#{env[:vm].env.default_private_key_path}",
                    config.playbook)
        end
=begin
        with_script_file do |path|
          # Upload the script to the VM
          env[:vm].channel.upload(path.to_s, config.upload_path)

          # Execute it with sudo
          env[:vm].channel.sudo(command) do |type, data|
            if [:stderr, :stdout].include?(type)
              # Output the data with the proper color based on the stream.
              color = type == :stdout ? :green : :red

              # Note: Be sure to chomp the data to avoid the newlines that the
              # Chef outputs.
              env[:ui].info(data.chomp, :color => color, :prefix => false)
            end
          end
        end
=end
      end
    end
  end
end
