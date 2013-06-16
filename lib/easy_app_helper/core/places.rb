#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------


# Possible places regarding the OS
# TODO: Add equivalent for Mac
class EasyAppHelper::Core::Config
  module Places
    module UnixPlaces
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      SYSTEM_CONFIG_POSSIBLE_PLACES = ["/etc"]

      # Where could be stored global wide configuration
      GLOBAL_CONFIG_POSSIBLE_PLACES = ["/etc",
                                       "/usr/local/etc"]

      # Where could be stored user configuration
      USER_CONFIG_POSSIBLE_PLACES = ["#{ENV['HOME']}/.config"]
    end

    module WindowsPlaces
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      SYSTEM_CONFIG_POSSIBLE_PLACES = ["#{ENV['systemRoot']}/Config"]

      # Where could be stored global configuration
      GLOBAL_CONFIG_POSSIBLE_PLACES = ['C:/Windows/Config', "#{ENV['ALLUSERSPROFILE']}/Application Data"]

      # Where could be stored user configuration
      USER_CONFIG_POSSIBLE_PLACES = [ENV['APPDATA']]
    end

    CONF ={
        mingw32: WindowsPlaces
    }
    DEFAULT = UnixPlaces

    def self.get_OS_module
      conf = CONF[RbConfig::CONFIG['target_os'].to_sym]
      conf.nil? ? DEFAULT : conf
    end
  end
end
