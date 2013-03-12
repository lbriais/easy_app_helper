################################################################################
# EasyAppHelper 
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'logger'

module EasyAppHelper::Common
  # Logger to nowhere
  DEFAULT_LOGGER = '/dev/null'
  # Default log-level
  DEFAULT_LOG_LEVEL = Logger::Severity::WARN
  # Default module priority
  MODULE_PRIORITY = 10000
  

  # Performs a merge at the second level of hashes.
  # simple entries and arrays are overriden.
  def override_config(original, override)
    override.each do |key, v|
      if original[key] and original[key].is_a?(Hash)
        original[key].merge! override[key] 
      else
        original[key] = override[key] unless override[key].nil?
      end
    end
    original
  end

end
