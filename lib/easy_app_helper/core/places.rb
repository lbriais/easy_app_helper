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
    module Unix
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      POSSIBLE_PLACES = {

          system: ["/etc"],

          # Where could be stored global wide configuration
          global: ["/etc",
                   "/usr/local/etc"],

          # Where could be stored user configuration
          user:  ["#{ENV['HOME']}/.config"]
      }
    end

    module Windows
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      POSSIBLE_PLACES = {

          system: ["#{ENV['systemRoot']}/Config"],

          # Where could be stored global configuration
          global: ['C:/Windows/Config', "#{ENV['ALLUSERSPROFILE']}/Application Data"],

          # Where could be stored user configuration
          user: [ENV['APPDATA']]
      }
    end

    CONF ={
        mingw32: Windows
    }
    DEFAULT = Unix

    def self.get_OS_module
      conf = CONF[RbConfig::CONFIG['target_os'].to_sym]
      conf.nil? ? DEFAULT : conf
    end
  end
end
