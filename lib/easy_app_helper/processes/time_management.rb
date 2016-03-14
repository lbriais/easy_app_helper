require 'open3'

module EasyAppHelper
  module Processes

    module TimeManagement

      attr_reader :creation_time, :start_time, :end_time

      def duration
        end_time - start_time
      end

      private

      attr_writer :creation_time, :start_time, :end_time

    end

  end
end