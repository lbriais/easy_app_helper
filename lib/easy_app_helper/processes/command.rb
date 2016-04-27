module EasyAppHelper
  module Processes

    module Command

      attr_accessor :command

      def valid?
        File.exists? self.command.split(' ').first
      end

    end

  end
end