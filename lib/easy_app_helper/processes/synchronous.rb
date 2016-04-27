module EasyAppHelper
  module Processes

    module Synchronous

      def execute
        self.exit_status = nil
        self.last_pid = nil
        self.process_state = :running
        self.start_time = Time.now
        EasyAppHelper.logger.debug "Starting process '#{command}'"
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
          stdin.close
          self.last_pid = wait_thread.pid
          begin
            monitored_streams = [stdout, stderr]
            loop do
              begin
                readables, writables = IO.select(monitored_streams)
                writables.each(&:close)
                readables.each do |io|
                  begin
                    buffer = ''
                    buffer << io.read_nonblock(1) while buffer[-1] != "\n"
                    report buffer, io == stdout
                  rescue IO::WaitReadable
                    next
                  rescue EOFError => e
                    monitored_streams.delete io
                    monitored_streams.empty? ? raise(e) : next
                  end
                end
              rescue EOFError
                report "End of process #{wait_thread.value.pid}"
                break
              end
            end
          rescue Errno::EAGAIN
            retry
          end
          self.exit_status = wait_thread.value
          return self.exit_status
        end
      ensure
        self.end_time = Time.now
        self.process_state = :terminated
      end

    end

  end
end