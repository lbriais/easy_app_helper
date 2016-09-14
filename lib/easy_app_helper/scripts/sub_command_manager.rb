module EasyAppHelper
  module Scripts

    module SubCommandManager

      def self.register(sub_command_class)
        raise 'Please specify a sub_command class when registering' if sub_command_class.nil?
        raise "Already registered sub_command '#{sub_command_class.to_s}' !" if sub_command_classes.include? sub_command_class
        EasyAppHelper.logger.debug "Registering handler '#{sub_command_class.to_s}' for sub-command '#{sub_command_class::NAME}'"
        sub_command_classes << sub_command_class
        by_provider[sub_command_class::PROVIDER] ||= []
        raise 'A provider cannot provide the same sub-command multiple times' if by_provider[sub_command_class::PROVIDER].include?(sub_command_class)
        by_provider[sub_command_class::PROVIDER] << sub_command_class
        by_name[sub_command_class::NAME] ||= []
        by_name[sub_command_class::NAME] << sub_command_class
        sub_command_class::ALIASES.each do |command_alias|
          by_name[command_alias] ||= []
          by_name[command_alias] << sub_command_class
        end
      end

      def self.sub_command_classes
        @sub_command_classes ||= []
      end

      def self.by_provider
        @by_provider ||= {}
      end

      def self.by_name
        @by_name ||= {}
      end

      def self.sub_command_class(command_name_or_alias, provider=EasyAppHelper::Scripts::SubCommandBase::PROVIDER)
        candidates = by_provider[provider]
        raise "There is no provider declared for command '#{command_name_or_alias}'" if candidates.nil?
        candidates.select! do |sub_command_class|
          command_classes_for_command = by_name[command_name_or_alias]
          raise "There is no provider declared for command '#{command_name_or_alias}'" if command_classes_for_command.nil?
          command_classes_for_command.include? sub_command_class
        end
        raise "Cannot determine provider to use for '#{command_name_or_alias}'. Multiple providers exist !" unless candidates.size == 1
        candidates.first
      end

      def delegate_to_sub_command(provider = EasyAppHelper::Scripts::SubCommandBase::PROVIDER)
        sub_command_name = extra_parameters.shift
        sub_command = EasyAppHelper::Scripts::SubCommandManager.sub_command_class(sub_command_name, provider).new
        sub_command.pre_process
        raise 'You have to implement \'do_process\'' unless sub_command.respond_to? :do_process
        sub_command.do_process
      end


      def display_help
        result = [default_header]

        EasyAppHelper::Scripts::SubCommandManager.sub_command_classes.group_by do |sub_command_classes|
          sub_command_classes::CATEGORY
        end .each_pair do |category, sub_command_classes_for_category|
          result << ('  %s:' % category)
          result << ''
          sub_command_classes_for_category.each do |sub_command_class|
            result << sub_command_class.help_line
          end
          result << ''
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
