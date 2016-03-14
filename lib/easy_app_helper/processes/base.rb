require 'open3'

module EasyAppHelper
  module Processes

    class Base


      include EasyAppHelper::Processes::Command

      attr_reader :process_state, :exit_status, :synchronized, :creation_time, :start_time, :end_time, :last_pid

      def initialize(command=nil)
        self.command = command
        self.process_state = :not_started
        self.synchronized = true
        self.creation_time = Time.now
      end

      def execute
        self.exit_status = nil
        self.last_pid = nil
        self.process_state = :running
        self.start_time = Time.now
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
          stdin.close
          # self.last_pid = wait_thread.pid
          begin
            loop do
              readables, writeables = IO.select([stdout, stderr])
              readables.each do |io|
                begin
                  buffer = ''
                  buffer << io.read_nonblock(1) while buffer[-1] != "\n"
                  debug buffer
                rescue IO::WaitReadable
                  IO.select([io])
                  retry
                rescue IO::WaitWritable
                  IO.select(nil, [io])
                  retry
                end
              end
            end
          rescue Errno::EAGAIN
            retry
          rescue EOFError
            debug "End of process #{wait_thread.value.pid}"
          end
          self.exit_status = wait_thread.value
        end
      ensure
        self.end_time = Time.now
        self.process_state = :terminated
        return self.exit_status
      end

      def duration
        end_time - start_time
      end

      private

      attr_writer :process_state, :exit_status, :synchronized, :creation_time, :start_time, :end_time, :last_pid

      def debug(message)
        EasyAppHelper.logger.debug "PROCESS OUTPUT: '#{message}'"
      end

    end

  end
end