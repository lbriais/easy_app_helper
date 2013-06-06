
module EasyAppHelper
  module Config
    module UnixPlaces
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      ADMIN_CONFIG_POSSIBLE_PLACES = ["/etc"]

      # Where could be stored system wide configuration
      SYSTEM_CONFIG_POSSIBLE_PLACES = ["/etc",
                                       "/usr/local/etc"]

      # Where could be stored user configuration
      USER_CONFIG_POSSIBLE_PLACES = ["#{ENV['HOME']}/.config"]
    end

    module WindowsPlaces
      # Where could be stored admin configuration that rules all EasyAppHelper
      # based applications.
      ADMIN_CONFIG_POSSIBLE_PLACES = ["#{ENV['systemRoot']}/Config"]

      # Where could be stored system wide configuration
      SYSTEM_CONFIG_POSSIBLE_PLACES = ['C:/Windows/Config', "#{ENV['ALLUSERSPROFILE']}/Application Data"]

      # Where could be stored user configuration
      USER_CONFIG_POSSIBLE_PLACES = [ENV['APPDATA']]
    end

    module Places
      CONF ={
        mingw32: EasyAppHelper::Config::WindowsPlaces
      }
      DEFAULT = EasyAppHelper::Config::UnixPlaces

      def self.get_OS_module
        conf = CONF[RbConfig::CONFIG['target_os'].to_sym]
        conf.nil? ? DEFAULT : conf
      end
    end
  end
end

