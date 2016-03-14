require 'open3'

module EasyAppHelper
  module Processes

    class Base

      include EasyAppHelper::Processes::Command
      include EasyAppHelper::Processes::TimeManagement

      attr_reader :process_state, :exit_status, :synchronized, :last_pid

      def initialize(command = nil, synchronized = true)
        self.command = command
        self.process_state = :not_started
        self.synchronized = synchronized
        self.extend EasyAppHelper::Processes::Sync if synchronized
        self.creation_time = Time.now
      end

      private

      attr_writer :process_state, :exit_status, :synchronized, :last_pid

      def debug(message)
        EasyAppHelper.logger.debug "PROCESS OUTPUT: '#{message}'"
      end

    end

  end
end