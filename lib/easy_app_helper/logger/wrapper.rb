module EasyAppHelper
  module Logger

    module Wrapper
      def puts_and_logs(*args)
        puts *args if EasyAppHelper.config[:verbose]
        info(*args)
      end
    end

  end
end