module EasyAppHelper
  module Logger

    module Wrapper
      def puts_and_logs(msg)
        puts msg if EasyAppHelper.config[:verbose]
        info(msg)
      end
    end

  end
end