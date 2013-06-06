################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require "easy_app_helper/version"
require "easy_app_helper/common"
require "easy_app_helper/base"
require 'easy_app_helper/places'
require "easy_app_helper/config"
require "easy_app_helper/logger"


# This module will provide helpers for your applications. Currently supported
# modules are:
# - EasyAppHelper::Base included by default.
# - EasyAppHelper::Logger adds logging capabilities to your scripts.
# - EasyAppHelper::Config provides a consistent configuration framework.
module EasyAppHelper
  include EasyAppHelper::Base
end


