
# Implements different merge policies for the configs.
module EasyAppHelper::Core::HashesMergePolicies
  # Performs a merge at the second level of hashes.
  # simple entries and arrays are overridden.
  def hashes_second_level_merge(h1, h2)
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
  def simple_merge(h1, h2)
    h1.merge! h2
  end

  # Brutal override
  def override_merge(h1, h2)
    h1 = nil
    h1 = h2

  end
end
