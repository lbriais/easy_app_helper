require 'open3'

module EasyAppHelper
  module Processes

    class Base

      include EasyAppHelper::Processes::Command
      include EasyAppHelper::Processes::TimeManagement

      attr_reader :process_state, :exit_status, :last_pid, :mode
      attr_accessor :show_output, :log_output

      def initialize(command = nil, mode = :synchronous)
        self.command = command
        self.process_state = :not_started
        self.mode = mode
        self.creation_time = Time.now
      end

      def mode=(mode)
        mode_processor = Object.const_get "EasyAppHelper::Processes::#{mode.to_s.capitalize}"
        self.extend mode_processor
        @mode = mode.to_sym
      rescue
        raise "Invalid process mode '#{mode}'"
      end

      private

      attr_writer :process_state, :exit_status, :last_pid

      def report(message, to_stdout = true)
        if show_output
          to_stdout ? puts(message) : STDERR.puts(message)
        end
        if log_output
            log_line = "[subprocess #{last_pid}] - #{message}"
            if to_stdout
              EasyAppHelper.logger.debug log_line
            else
              EasyAppHelper.logger.warn log_line
            end
        end

      end

    end

  end
end