#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'rspec'
require 'easy_app_helper'


#describe EasyAppHelper::Core::Logger
describe EasyAppHelper.logger do
  let (:config) {EasyAppHelper.config}

  context "to modify the log level" do

    it 'should be ok to use the config object' do
      Logger::Severity::DEBUG.upto(Logger::Severity::UNKNOWN) do |severity|
        config[:'log-level'] = severity
        expect(subject.level).to eq severity
      end
    end

    it 'should be ok to use the #log_level= method' do
      Logger::Severity::DEBUG.upto(Logger::Severity::UNKNOWN) do |severity|
        subject.level= severity
        expect(config[:'log-level']).to eq severity
      end
    end
  end

end