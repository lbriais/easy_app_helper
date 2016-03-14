module EasyAppHelper
  module Processes

    module Sync

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

    end

  end
end