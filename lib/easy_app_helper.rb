################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'easy_app_helper/version'

# When this module is included in any class, it mixes in automatically
# EasyAppHelper::ModuleManager methods both into the
# instance and the class of the instance that includes it.
# Thus to have access to the helper methods, the only requirement is to include
# this module...
module EasyAppHelper
  require 'easy_app_helper/module_manager'
  include ModuleManager
end


