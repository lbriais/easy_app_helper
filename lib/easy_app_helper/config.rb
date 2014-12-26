
module EasyAppHelper
  ManagedConfig = EasyAppHelper::Config::Initializer.build_config

  extend self

  def config
    EasyAppHelper::ManagedConfig
  end

end