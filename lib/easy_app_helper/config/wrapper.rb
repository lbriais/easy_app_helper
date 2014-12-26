module EasyAppHelper
  module Config

    module Wrapper
      def safely_exec(message, *args, &block)
        if self[:simulate]
          EasyAppHelper.puts_and_logs "SIMULATING: #{message}" unless message.nil?
        else
          EasyAppHelper.puts_and_logs message
          yield(*args)
        end
      end

      # For backward compatibility with EasyAppHelper v1.x
      def help
        command_line_help
      end

    end

  end
end