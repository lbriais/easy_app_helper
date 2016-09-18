module EasyAppHelper
  module Scripts

    module SubCommandBase

      include EasyAppHelper
      include EasyAppHelper::Scripts::Common

      PROVIDER = 'Core'
      NAME = ''
      DESCRIPTION = ''
      CATEGORY = ''
      ALIASES = []

      def self.included(base)
        EasyAppHelper::Scripts::SubCommandManager.register base
        base.extend ClassMethods
      end

      def command_parameters
        params = extra_parameters
        command = params.shift
        raise 'Something weird happened !!' unless command == self.class::NAME or self.class::ALIASES.include? command
        params
      end

      def do_process
        raise "Process for '#{name}' in '#{self::PROVIDER}' not implemented !"
      end

      def display_help
        config.app_description = self.class::DESCRIPTION
        config.command_line_help
      end

      module ClassMethods

        def help_line
          line = ' * %-10s : %s' % [self::NAME, self::DESCRIPTION]
          unless self::ALIASES.nil? or self::ALIASES.empty?
            line += ' (aliases: %s).' % [ self::ALIASES.join(', ') ]
          end
          unless self::PROVIDER == EasyAppHelper::Scripts::SubCommandBase::PROVIDER
            line += ' Provided by %s plugin.' % [ self::PROVIDER ]
          end
          line
        end

      end

    end

  end
end
