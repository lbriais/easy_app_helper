################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

# Possible places regarding the OS
# TODO: Add equivalent for Mac
class EasyAppHelper::Core::Config::Places

  module Helper

    def get_internal_config_place
      File.expand_path('../../etc', $PROGRAM_NAME)
    end

    def possible_config_places key
      POSSIBLE_PLACES[key]
    end

  end


  module Unix
    # Where could be stored admin configuration that rules all EasyAppHelper
    # based applications.
    extend Helper

    POSSIBLE_PLACES = {

        internal: ["#{self.get_internal_config_place}"],

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
    extend Helper

    POSSIBLE_PLACES = {

        internal: ["#{self.get_internal_config_place}"],

        system: ["#{ENV['systemRoot']}/Config"],

        # Where could be stored global configuration
        global: ["#{ENV['systemRoot']}/Config",
                 "#{ENV['ALLUSERSPROFILE']}/Application Data"],

        # Where could be stored user configuration
        user: [ENV['APPDATA']]
    }
  end

  CONF = {
      mingw32: Windows,
      linux: Unix
  }
  DEFAULT = Unix


  def self.get_os_module
    conf = CONF[RbConfig::CONFIG['target_os'].to_sym]
    conf.nil? ? DEFAULT : conf
  end


end