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

  it 'should not log by default' do
    config[:debug] = false
    logger = double(subject)

  end

end