################################################################################
# EasyAppHelper
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

# The goal of this class is to return a module containing the POSSIBLE_PLACES hash
# that provides a list of OS dependant paths.
# The only method that should be used is the #get_os_module method that returns this module.
# TODO: Add equivalent for Mac

module EasyAppHelper
  module Core
    class Config
      module Places

        OS_FLAVOURS = {
            mingw32: :windows,
            linux: :unix
        }
        DEFAULT_OS_FLAVOUR = :unix

        FLAVOUR_PLACES = {
            unix: {
                internal: [],

                system: ['/etc'],

                # Where could be stored global wide configuration
                global: %w(/etc /usr/local/etc),

                # Where could be stored user configuration
                user:  ["#{ENV['HOME']}/.config"]
            },
            windows: {
                internal: [],

                system: ["#{ENV['systemRoot']}/Config"],

                # Where could be stored global configuration
                global: ["#{ENV['systemRoot']}/Config",
                         "#{ENV['ALLUSERSPROFILE']}/Application Data"],

                # Where could be stored user configuration
                user: [ENV['APPDATA']]
            }
        }


        def self.os_flavour
          flavour = OS_FLAVOURS[RbConfig::CONFIG['target_os'].to_sym]
          flavour.nil? ? DEFAULT_OS_FLAVOUR : flavour
        end

        def self.gem_root_path(file=__FILE__)
          file=__FILE__ if file.nil?
          searcher = if Gem::Specification.respond_to? :find
                       # ruby 2.0
                       Gem::Specification
                     elsif Gem.respond_to? :searcher
                       # ruby 1.8/1.9
                       Gem.searcher.init_gemspecs
                     end
          spec = unless searcher.nil?
                   searcher.find do |spec|
                     File.fnmatch(File.join(spec.full_gem_path,'*'), file)
                   end
                 end

          spec.gem_dir
        end


        def self.possible_config_places(file_of_gem=nil)
          root = gem_root_path file_of_gem
          places = FLAVOUR_PLACES[os_flavour].dup
          places[:internal] = %w(etc config).map do |place|
            File.join root, place
          end
          places
        end

      end
    end
  end
end
