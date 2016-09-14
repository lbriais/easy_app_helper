module EasyAppHelper
  module Scripts

    module ParametersHelper

      # Allows to specify a Ruby Symbol as a string. Supposed to be used to pass
      # symbols from the command line.
      # @param [String] param A string coming normally from the command line.
      # @return [String or Symbol] if param starts with a colon, then it the
      #        returns a symbol, ie: ':foo' returns :foo (the Symbol)
      #        Else it will return the param itself. 'bar' returns 'bar' (the String)
      def normalize_param(param)
        param.match(/^:(?<param>.+)$/) do |md|
          param = md['param'].to_sym
        end
        param
      end

    end

  end
end
