module EasyAppHelper
  module Scripts

    class Master

      include EasyAppHelper
      include EasyAppHelper::Scripts::Common
      include EasyAppHelper::Scripts::Completion

      attr_reader :script_name

      def initialize(app_name, app_version, app_description, config_file_base_name=nil)
        @script_name = File.basename $0
        config.config_file_base_name = config_file_base_name.nil? ? script_name : config_file_base_name
        config.describes_application app_name: app_name,
                                     app_version: app_version,
                                     app_description: app_description
      end

      def run
        safe_execution do
          if sub_command_mode?
            if ARGV.length == 1
              %w(--help -h --version).each do |option|
                if ARGV.include? option
                  if option == '--version'
                    puts DeploymentManager::VERSION
                  else
                    puts display_help
                  end
                  exit 0
                end
              end
            end
            if ARGV.empty?
              puts display_help
              exit 0
            end
            delegate_to_sub_command
          else
            pre_process
            do_process
          end
          logger.info 'Application terminates successfully...'
          exit 0
        end
      end

      def display_help
        config.command_line_help
      end

      def do_process
        raise 'Please implement do_process in your action !'
      end

      private

      def sub_command_mode?
        self.class.included_modules.include? EasyAppHelper::Scripts::SubCommandManager
      end

    end

  end
end
