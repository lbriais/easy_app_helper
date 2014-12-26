module EasyAppHelper
  module Logging

    module Initializer

      def self.init_command_line_options
        EasyAppHelper.config.add_command_line_section('Debug and logging options') do |slop|
          slop.on :debug, 'Run in debug mode.', argument: false
          slop.on 'debug-on-err', 'Run in debug mode with output to stderr.', argument: false
          slop.on 'log-level', "Log level from 0 to 5, default #{Logger::Severity::WARN}.", argument: true, as: Integer
          slop.on 'log-file', 'File to log to.', argument: true, as: String
        end
      end

      def self.build_logger
        if EasyAppHelper.config[:debug]
          if EasyAppHelper.config[:'log-file']
            log_device = EasyAppHelper.config[:'log-file']
          elsif EasyAppHelper.config[:'debug-on-err']
            log_device = STDERR
          else
            log_device = STDOUT
          end
          log_level = EasyAppHelper.config[:'log-level'] ? EasyAppHelper.config[:'log-level'] : Logger::Severity::WARN

          Logger.new log_device
        else
          #Humm
        end
      end

      init_command_line_options




    end

  end
end





