################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'singleton'
require 'logger'

##
# This contains very basic default values and methods.
#
module EasyAppHelper::Common
  # Default log-level
  DEFAULT_LOG_LEVEL = Logger::Severity::WARN
  # Default module priority
  MODULE_PRIORITY = 10000
  
  def override_config(h1, h2)
    EasyAppHelper::Common::HashesMergePolicies.merge_hashes_second_level h1, h2
  end

end

# This guy will never log something anywhere... :)
class EasyAppHelper::Common::DummyLogger
  include Singleton
  def method_missing(method_name, *args, &block)
    # Do nothing !
  end  
end

module EasyAppHelper::Common::HashesMergePolicies
  # Performs a merge at the second level of hashes.
  # simple entries and arrays are overriden.
  def self.merge_hashes_second_level(h1, h2)
    h2.each do |key, v|
      if h1[key] and h1[key].is_a?(Hash)
      # Merges hashes 
        h1[key].merge! h2[key] 
      else
        # Overrides the rest
        h1[key] = h2[key] unless h2[key].nil?
      end
    end
    h1
  end

  # Uses the standard "merge!" method
  def self.simple_merge(h1, h2)
    h1.merge! h2
  end

  # Brutal override
  def self.complete_override(h1, h2)
    h1 = nil
    h1 = h2

  end

end
