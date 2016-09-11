module EasyAppHelper
  module Scripts

    module SubCommandBase

      include EasyAppHelper
      include EasyAppHelper::Scripts::Common

      DEFAULT_PROVIDER = 'Main program'
      DEFAULT_ALIASES = []

      attr_writer :aliases, :plugin

      def self.included(base)
        EasyAppHelper::Scripts::SubCommandManager.register base
        base.extend ClassMethods
      end

      # def name
      #   self.class::NAME
      # end
      #
      # def description
      #   self.class::DESCRIPTION
      # end
      #
      # def category
      #   self.class::CATEGORY
      # end



      def do_process
        raise "Process for '#{name}' in '#{plugin}' not implemented !"
      end

      def display_help
        config.app_description = self.class::DESCRIPTION
        config.command_line_help
      end


      module ClassMethods

        attr_writer :aliases, :plugin

        def aliases
          @aliases ||DEFAULT_ALIASES
        end

        def plugin
          @plugin ||DEFAULT_PROVIDER
        end

        def help_line
          line = ' * %-10s : %s' % [self::NAME, self::DESCRIPTION]
          unless aliases.nil? or aliases.empty?
            line += ' (aliases: %s).' % [ aliases.join(', ') ]
          end
          line
        end

      end

    end

  end
end
