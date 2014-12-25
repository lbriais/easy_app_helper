
module EasyAppHelper
  Config = StackedConfig::Orchestrator.new

  extend self

  def config
    EasyAppHelper::Config
  end

end