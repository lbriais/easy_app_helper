module EasyAppHelper
  module Scripts

    module SubCommandManager

      def self.register(sub_command_class)
        raise 'Please specify a sub_command class when registering' if sub_command_class.nil?
        EasyAppHelper.logger.debug "Registering handler '#{sub_command_class.to_s}' for sub-command '#{sub_command_class::NAME}'"
        sub_commands[sub_command_class::NAME] ||= []
        sub_commands[sub_command_class::NAME] << sub_command_class
        sub_command_class::ALIASES.each do |command_alias|
          sub_commands[command_alias] ||= []
          sub_commands[command_alias] << sub_command_class
        end
      end

      def self.sub_commands
        @sub_commands ||= {}
      end

      def delegate_to_sub_command(provider = EasyAppHelper::Scripts::SubCommandBase::PROVIDER)
        # raise 'You have to specify a sub-command !' if extra_parameters.empty?
        sub_command_name = extra_parameters.shift
        candidates = EasyAppHelper::Scripts::SubCommandManager.sub_commands[sub_command_name]
        raise "Unknown sub-command '#{sub_command_name}' !" if candidates.nil?
        sub_command_class = nil
        if candidates.size == 1
          sub_command_class = candidates.first
        else
          candidates.select! {|candidate| candidate::PROVIDER == provider}
          raise "Cannot determine provider to use for '#{sub_command_name}'. Multiple providers exist !" unless candidates.size == 1
          sub_command_class = candidates.first
        end
        sub_command = sub_command_class.new
        raise 'You have to implement \'do_process\'' unless sub_command.respond_to? :do_process
        sub_command.pre_process
        sub_command.do_process
      end


      def display_help
        result = [default_header]

        EasyAppHelper::Scripts::SubCommandManager.sub_commands.group_by do |sub_command_name, sub_command_classes|
          sub_command_classes.first::CATEGORY
        end .each_pair do |category, sub_commands_for_category|
          result << ('  %s:' % category)
          result << ''
          sub_commands_for_category.each do |sub_command_name, sub_command_classes|
            sub_command_classes.each do |sub_command_class|
              result << sub_command_class.help_line
            end
            result << ''
          end
        end
        result
      end

      def default_header
        <<EOF

This is the '#{script_name}' tool version #{config.app_version} (AKA '#{self.class::NAME}').
#{self.class::DESCRIPTION}

It has some sub-commands, each taking its own options.

You can do '#{script_name} <sub-command> --help' for more information on sub-modules.

Options

  --help/-h    : This help.
  --version    : Echoes dm version

Sub-commands:

EOF
      end


    end

  end
end
